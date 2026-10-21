<?php

namespace App\Services;

use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PersonalService
{
    public const EVENTOS = ['ENTRADA', 'SALIDA_REFRIGERIO', 'RETORNO_REFRIGERIO', 'SALIDA'];

    public function fail(string $m): never
    {
        throw ValidationException::withMessages(['operacion' => $m]);
    }

    public function audit(string $action, string $ref, array $detail = []): void
    {
        DB::table('auditoria')->insert(['usuario_id' => auth()->id(), 'accion' => $action, 'referencia' => $ref, 'detalle' => json_encode($detail, JSON_UNESCAPED_UNICODE)]);
    }

    public function plan(int $id, string $fecha): array
    {
        $assignment = DB::table('asignaciones_horario')->where('desde', '<=', $fecha)->where('colaborador_id', $id)->orderByDesc('desde')->first()
         ?? DB::table('asignaciones_horario')->where('desde', '<=', $fecha)->whereNull('colaborador_id')->orderByDesc('desde')->first();
        if (! $assignment) {
            return ['turno' => null, 'trabaja' => false, 'motivo' => 'SIN HORARIO'];
        }
        $turn = DB::table('turnos')->find($assignment->turno_id);
        $works = in_array(Carbon::parse($fecha)->dayOfWeekIso, json_decode($assignment->dias_semana, true));
        $reason = $works ? 'JORNADA LABORAL' : 'DESCANSO SEMANAL';
        $holiday = DB::table('feriados')->where('fecha', $fecha)->first();
        if ($holiday) {
            $works = false;
            $reason = $holiday->motivo;
        }
        $exception = DB::table('excepciones_calendario')->where('fecha', $fecha)->where('colaborador_id', $id)->first()
         ?? DB::table('excepciones_calendario')->where('fecha', $fecha)->whereNull('colaborador_id')->first();
        if ($exception) {
            $works = (bool) $exception->trabaja;
            $reason = $exception->motivo;
        }
        $vac = DB::table('solicitud_dias as d')->join('solicitudes_vacaciones as s', 's.id', '=', 'd.solicitud_id')->join('periodos_vacacionales as p', 'p.id', '=', 's.periodo_id')->where('p.colaborador_id', $id)->where('s.estado', 'APROBADA')->where('d.fecha', $fecha)->exists();
        if ($vac) {
            $works = false;
            $reason = 'VACACIONES';
        }

        return ['turno' => $turn, 'trabaja' => $works, 'motivo' => $reason];
    }

    public function jornada(int $id, string $fecha): ?object
    {
        $existing = DB::table('asistencias')->where('colaborador_id', $id)->where('fecha', $fecha)->first();
        if ($existing) {
            return $existing;
        }
        $plan = $this->plan($id, $fecha);
        if (! $plan['turno']) {
            return null;
        }
        DB::table('asistencias')->insertOrIgnore(['colaborador_id' => $id, 'fecha' => $fecha, 'turno_id' => $plan['turno']->id, 'requiere_marca' => $plan['trabaja']]);

        return DB::table('asistencias')->where('colaborador_id', $id)->where('fecha', $fecha)->first();
    }

    public function sync(): void
    {
        $today = now()->toDateString();
        foreach (DB::table('colaboradores')->whereNull('deleted_at')->pluck('id') as $id) {
            $start = DB::table('asignaciones_horario')->min('desde');
            if (! $start) {
                continue;
            }
            $last = DB::table('asistencias')->where('colaborador_id', $id)->max('fecha');
            $from = $last ? Carbon::parse($last) : Carbon::parse($start);
            // Bounded recovery; never create a person's records before a confirmed hiring date.
            $person = DB::table('colaboradores')->find($id);
            $hired = $person->fecha_ingreso ?? substr($person->created_at, 0, 10);
            if ($hired && $from->lt(Carbon::parse($hired))) {
                $from = Carbon::parse($hired);
            }
            for ($date = $from->copy(); $date->lte(Carbon::parse($today)); $date->addDay()) {
                $this->jornada($id, $date->toDateString());
            }
        }
        DB::table('asistencias')->whereNull('cerrada_en')->where('fecha', '<', $today)->update(['cerrada_en' => DB::raw("TIMESTAMP(fecha,'23:59:59')")]);
    }

    public function refreshToday(?int $id = null): void
    {
        $query = DB::table('asistencias')->where('fecha', today()->toDateString())->whereNull('cerrada_en')->whereNotExists(function ($q) {
            $q->selectRaw('1')->from('eventos_asistencia')->whereColumn('asistencia_id', 'asistencias.id');
        });
        if ($id) {
            $query->where('colaborador_id', $id);
        }
        foreach ($query->get() as $a) {
            DB::transaction(function () use ($a) {
                $row = DB::table('asistencias')->where('id', $a->id)->lockForUpdate()->first();
                if ($row->cerrada_en || DB::table('eventos_asistencia')->where('asistencia_id', $a->id)->exists()) {
                    return;
                }
                $p = $this->plan($a->colaborador_id, $a->fecha);
                if ($p['turno']) {
                    DB::table('asistencias')->where('id', $a->id)->update(['turno_id' => $p['turno']->id, 'requiere_marca' => $p['trabaja']]);
                }
            });
        }
    }

    public function marcar(int $id, string $ip): string
    {
        $a = $this->jornada($id, today()->toDateString());
        if (! $a) {
            $this->fail('No tiene un horario vigente. Consulte a RRHH.');
        }

        return DB::transaction(function () use ($a, $ip, $id) {
            DB::table('colaboradores')->where('id', $id)->lockForUpdate()->first();
            $a = DB::table('asistencias')->where('id', $a->id)->lockForUpdate()->first();
            if ($a->cerrada_en) {
                $this->fail('La jornada ya está cerrada.');
            }
            $events = DB::table('eventos_asistencia')->where('asistencia_id', $a->id)->orderBy('id')->get();
            if ($events->isEmpty()) {
                $plan = $this->plan($id, $a->fecha);
                if ($plan['turno']) {
                    $a->turno_id = $plan['turno']->id;
                    $a->requiere_marca = $plan['trabaja'];
                    DB::table('asistencias')->where('id', $a->id)->update(['turno_id' => $a->turno_id, 'requiere_marca' => $a->requiere_marca]);
                }
            }
            if (! $a->requiere_marca) {
                $this->fail('Hoy no tiene una jornada laboral programada.');
            }
            if (count($events) >= 4) {
                $this->fail('Ya completó las cuatro marcas.');
            }
            if ($events->last() && now()->diffInSeconds(Carbon::parse($events->last()->marca_tiempo), true) < 30) {
                $this->fail('La última marca se registró hace unos segundos. Espere antes de marcar nuevamente.');
            }
            $event = self::EVENTOS[count($events)];
            DB::table('eventos_asistencia')->insert(['asistencia_id' => $a->id, 'tipo_evento' => $event, 'marca_tiempo' => now(), 'ip_origen' => $ip, 'dispositivo' => 'KIOSCO_SEDE']);
            if ($event === 'SALIDA') {
                DB::table('asistencias')->where('id', $a->id)->update(['cerrada_en' => now()]);
            }
            $this->audit('MARCACION', (string) $a->id, ['evento' => $event]);

            return $event;
        }, 3);
    }

    public function calendar(int $id, string $month): array
    {
        $date = Carbon::createFromFormat('!Y-m', $month);
        $end = $date->copy()->endOfMonth();
        $rows = DB::table('v_asistencias_reporte')->where('colaborador_id', $id)->whereBetween('fecha', [$date->toDateString(), $end->toDateString()])->get()->keyBy('fecha');
        $days = [];
        for ($day = $date->copy(); $day->lte($end); $day->addDay()) {
            $f = $day->toDateString();
            $plan = $this->plan($id, $f);
            $row = $rows->get($f);
            if ($row) {
                $plan['turno'] = DB::table('turnos')->find($row->turno_id);
            }
            $status = $row?->estado_jornada ?? ($day->isPast() && ! $day->isToday() ? 'SIN REGISTRO' : ($plan['trabaja'] ? 'PROGRAMADO' : 'DESCANSO'));
            if ($plan['motivo'] === 'VACACIONES') {
                $status = 'V';
            }
            $days[] = ['fecha' => $f, 'dia' => $day->day, 'estado' => $status, 'plan' => $plan, 'registro' => $row];
        }

        return $days;
    }

    public function solicitarVacaciones(int $actor, int $periodId, string $from, string $to): void
    {
        $user = DB::table('usuarios')->find($actor);
        DB::transaction(function () use ($user, $periodId, $from, $to) {
            DB::table('colaboradores')->where('id', $user->colaborador_id)->lockForUpdate()->first();
            $p = DB::table('periodos_vacacionales')->where('id', $periodId)->where('colaborador_id', $user->colaborador_id)->lockForUpdate()->first();
            if (! $p || ! $p->confirmado) {
                $this->fail('RRHH debe confirmar el periodo y su saldo inicial.');
            }
            if ($p->fecha_fin >= today()->toDateString()) {
                $this->fail('El periodo de servicios aún no ha concluido.');
            }
            $n = (int) Carbon::parse($from)->diffInDays(Carbon::parse($to)) + 1;
            if ($n > 366 || $n < 1) {
                $this->fail('El rango de fechas no es válido.');
            }
            $saldo = DB::table('v_saldos_vacacionales')->where('periodo_id', $periodId)->first();
            if ($n > $saldo->saldo_disponible) {
                $this->fail('No tiene saldo suficiente.');
            }
            $overlap = DB::table('solicitud_dias as d')->join('solicitudes_vacaciones as s', 's.id', '=', 'd.solicitud_id')->join('periodos_vacacionales as p', 'p.id', '=', 's.periodo_id')->where('p.colaborador_id', $user->colaborador_id)->whereIn('s.estado', ['PENDIENTE', 'APROBADA'])->whereBetween('d.fecha', [$from, $to])->exists();
            if ($overlap) {
                $this->fail('Ya tiene una solicitud pendiente o aprobada en esas fechas.');
            }
            $sid = DB::table('solicitudes_vacaciones')->insertGetId(['periodo_id' => $periodId, 'solicitada_en' => now(), 'estado' => 'PENDIENTE']);
            for ($d = Carbon::parse($from); $d->lte(Carbon::parse($to)); $d->addDay()) {
                DB::table('solicitud_dias')->insert(['solicitud_id' => $sid, 'fecha' => $d->toDateString()]);
            }
            $this->audit('SOLICITAR_VACACIONES', (string) $sid);
        }, 3);
    }

    public function resolverVacaciones(int $id, string $estado, string $comentario): void
    {
        DB::transaction(function () use ($id, $estado, $comentario) {
            $pre = DB::table('solicitudes_vacaciones as s')->join('periodos_vacacionales as p', 'p.id', '=', 's.periodo_id')->where('s.id', $id)->select('p.colaborador_id', 'p.id as pid')->first();
            if (! $pre) {
                abort(404);
            }
            DB::table('colaboradores')->where('id', $pre->colaborador_id)->lockForUpdate()->first();
            $p = DB::table('periodos_vacacionales')->where('id', $pre->pid)->lockForUpdate()->first();
            $s = DB::table('solicitudes_vacaciones')->where('id', $id)->lockForUpdate()->first();
            if ($s->estado !== 'PENDIENTE') {
                $this->fail('Esta solicitud ya fue resuelta.');
            }
            if ($estado === 'APROBADA') {
                if (! $p->confirmado || $p->fecha_fin >= today()->toDateString()) {
                    $this->fail('Periodo pendiente de confirmar o aún no devengado.');
                }
                $dates = DB::table('solicitud_dias')->where('solicitud_id', $id)->pluck('fecha');
                if (DB::table('eventos_asistencia as e')->join('asistencias as a', 'a.id', '=', 'e.asistencia_id')->where('a.colaborador_id', $pre->colaborador_id)->whereIn('a.fecha', $dates)->exists()) {
                    $this->fail('No se aprueban vacaciones en días que ya tienen marcaciones.');
                }
                $used = DB::table('solicitud_dias as d')->join('solicitudes_vacaciones as s', 's.id', '=', 'd.solicitud_id')->where('s.periodo_id', $p->id)->where('s.estado', 'APROBADA')->count();
                if (! $dates->count() || $dates->min() < today()->toDateString() || $used + $p->usados_iniciales + $dates->count() > $p->dias_devengados) {
                    $this->fail('Fechas vencidas o saldo insuficiente para aprobar.');
                }
                $over = DB::table('solicitud_dias as d')->join('solicitudes_vacaciones as s', 's.id', '=', 'd.solicitud_id')->join('periodos_vacacionales as p', 'p.id', '=', 's.periodo_id')->where('p.colaborador_id', $pre->colaborador_id)->where('s.estado', 'APROBADA')->whereIn('d.fecha', $dates)->exists();
                if ($over) {
                    $this->fail('Existe otra vacación aprobada en esas fechas.');
                }
            }
            DB::table('solicitudes_vacaciones')->where('id', $id)->update(['estado' => $estado, 'evaluado_por' => auth()->id(), 'evaluada_en' => now(), 'comentario_revision' => $comentario]);
            $this->audit('RESOLVER_VACACIONES', (string) $id, ['estado' => $estado]);
        }, 3);
    }
}
