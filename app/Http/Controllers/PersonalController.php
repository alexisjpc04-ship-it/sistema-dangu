<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Services\PersonalService;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class PersonalController extends Controller
{
    public function __construct(private PersonalService $service) {}

    private function ok(string $m)
    {
        return back()->with('success', $m);
    }

    private function month(Request $r): string
    {
        $r->validate(['mes' => ['nullable', 'date_format:Y-m']]);

        return $r->input('mes', now()->format('Y-m'));
    }

    public function loginForm()
    {
        return auth()->check() ? redirect('/inicio') : view('nuevo.login');
    }

    public function login(Request $r)
    {
        $d = $r->validate(['username' => 'required|string|max:120', 'password' => 'required|string|regex:/^[0-9]{4}$/']);
        $u = User::where('username', mb_strtoupper(trim($d['username']), 'UTF-8'))->where('activo', 1)->whereHas('colaborador', fn ($q) => $q->whereNull('deleted_at'))->first();
        if (! $u || ! Hash::check($d['password'], $u->password)) {
            return back()->withErrors(['username' => 'Usuario o contraseña incorrectos.'])->onlyInput('username');
        }
        Auth::login($u, false);
        $r->session()->regenerate();
        $r->session()->put('version_sesion', $u->version_sesion);

        return redirect('/inicio');
    }

    public function logout(Request $r)
    {
        Auth::logout();
        $r->session()->invalidate();
        $r->session()->regenerateToken();

        return redirect('/login');
    }

    public function claveForm()
    {
        return view('nuevo.clave');
    }

    public function clave(Request $r)
    {
        $r->validate(['actual' => ['required', 'current_password'], 'password' => ['required', 'string', 'regex:/^[0-9]{4}$/', 'confirmed', 'different:actual']]);
        DB::table('usuarios')->where('id', auth()->id())->update(['password' => Hash::make($r->password), 'debe_cambiar_clave' => false, 'version_sesion' => DB::raw('version_sesion+1'), 'remember_token' => null]);
        $r->session()->regenerate();
        $r->session()->put('version_sesion', User::find(auth()->id())->version_sesion);
        $this->service->audit('CAMBIO_CLAVE', (string) auth()->id());

        return redirect('/inicio')->with('success', 'Contraseña actualizada.');
    }

    public function inicio(Request $r)
    {
        $this->service->sync();
        $month = $this->month($r);
        $admin = auth()->user()->isAdmin();
        $people = DB::table('colaboradores as c')->join('usuarios as u', 'u.colaborador_id', '=', 'c.id')->select('c.*', 'u.username', 'u.activo')->orderBy('c.nombres')->get();
        $id = (int) ($admin ? $r->input('persona', auth()->user()->colaborador_id) : auth()->user()->colaborador_id);
        $person = DB::table('colaboradores')->find($id);
        abort_unless($person, 404);
        $days = $this->service->calendar($id, $month);
        $balances = DB::table('v_saldos_vacacionales')->where('colaborador_id', $id)->get();
        $vac = DB::table('v_solicitudes_vacaciones')->where('colaborador_id', $id)->orderByDesc('id')->get();
        $just = DB::table('justificaciones as j')->join('asistencias as a', 'a.id', '=', 'j.asistencia_id')->where('a.colaborador_id', $id)->select('j.*', 'a.fecha')->orderByDesc('j.id')->get();
        $metrics = ['Cuentas activas' => $people->where('activo', 1)->count(), 'Marcas de hoy' => DB::table('eventos_asistencia')->whereDate('marca_tiempo', today())->count(), 'Vacaciones por revisar' => DB::table('solicitudes_vacaciones')->where('estado', 'PENDIENTE')->count(), 'Justificaciones por revisar' => DB::table('justificaciones')->where('estado', 'PENDIENTE')->count()];

        return view('nuevo.inicio', compact('month', 'admin', 'people', 'person', 'days', 'balances', 'vac', 'just', 'metrics'));
    }

    public function personal()
    {
        return view('nuevo.personal', ['people' => DB::table('colaboradores as c')->join('usuarios as u', 'u.colaborador_id', '=', 'c.id')->select('c.*', 'u.username', 'u.activo', 'u.id as uid')->orderBy('c.nombres')->get(), 'areas' => DB::table('areas')->get(), 'cargos' => DB::table('cargos')->get()]);
    }

    public function personaForm(int $id)
    {
        $person = DB::table('colaboradores as c')->join('usuarios as u', 'u.colaborador_id', '=', 'c.id')->where('c.id', $id)->select('c.*', 'u.username', 'u.activo', 'u.id as uid')->first();
        abort_unless($person, 404);

        return view('nuevo.persona', ['person' => $person, 'cargos' => DB::table('cargos')->get(), 'periodos' => DB::table('periodos_vacacionales')->where('colaborador_id', $id)->get()]);
    }

    public function persona(Request $r, ?int $id = null)
    {
        $uid = $id ? DB::table('usuarios')->where('colaborador_id', $id)->value('id') : null;
        if ($id && ! $uid) {
            abort(404);
        }
        if (!$id && !$r->filled('password')) { $r->merge(['password'=>'1234']); }
        $r->merge(['username' => mb_strtoupper(trim((string) $r->username), 'UTF-8'), 'nombres' => mb_strtoupper(trim((string) $r->nombres), 'UTF-8')]);
        $d = $r->validate(['nombres' => 'required|string|max:100', 'username' => ['required', 'string', 'max:120', 'regex:/^[\pL]+\.[\pL]+$/u', Rule::unique('usuarios', 'username')->ignore($uid)], 'dni' => ['nullable', 'digits:8', Rule::unique('colaboradores', 'dni')->ignore($id)], 'fecha_ingreso' => 'nullable|date|before_or_equal:today', 'cargo_id' => 'required|exists:cargos,id', 'telefono' => 'nullable|string|max:20', 'correo_contacto' => 'nullable|email|max:120', 'regimen' => 'required|in:POR CONFIRMAR,REMYPE,GENERAL', 'password' => ($id ? 'nullable' : 'required').'|string|regex:/^[0-9]{4}$/']);
        DB::transaction(function () use ($d, $id, $uid) {
            $fields = collect($d)->except(['username', 'password'])->all();
            $fields['apellidos'] = '';
            if ($id) {
                DB::table('colaboradores')->where('id', $id)->update($fields);
                DB::table('usuarios')->where('id', $uid)->update(['username' => $d['username']]);
            } else {
                $fields['turno_id'] = DB::table('turnos')->min('id');
                $fields['pin_hash'] = Hash::make(bin2hex(random_bytes(20)));
                $id = DB::table('colaboradores')->insertGetId($fields);
                $uid = DB::table('usuarios')->insertGetId(['colaborador_id' => $id, 'username' => $d['username'], 'email' => 'cuenta'.$id.'@dangu.invalid', 'password' => Hash::make($d['password']), 'activo' => 1]);
                DB::table('usuario_rol')->insert(['usuario_id' => $uid, 'rol_id' => DB::table('roles')->where('nombre', 'COLABORADOR')->value('id')]);
            }
            if (! empty($d['password'])) {
                DB::table('usuarios')->where('id', $uid)->update(['password' => Hash::make($d['password']), 'debe_cambiar_clave' => true, 'version_sesion' => DB::raw('version_sesion+1'), 'remember_token' => null]);
            }
            $this->service->audit('GUARDAR_PERSONAL', (string) $id);
        });

        return redirect('/personal')->with('success', 'Datos guardados. Las claves temporales se cambian al ingresar.');
    }

    public function activar(int $id)
    {
        abort_if($id == auth()->user()->colaborador_id, 422, 'No puede desactivar su propia cuenta.');
        DB::transaction(function () use ($id) {
            $u = DB::table('usuarios')->where('colaborador_id', $id)->lockForUpdate()->first();
            abort_unless($u, 404);
            $active = ! $u->activo;
            DB::table('usuarios')->where('id', $u->id)->update(['activo' => $active, 'version_sesion' => DB::raw('version_sesion+1')]);
            DB::table('colaboradores')->where('id', $id)->update(['deleted_at' => $active ? null : now()]);
            $this->service->audit('ESTADO_CUENTA', (string) $id, ['activo' => $active]);
        });

        return $this->ok('Estado del trabajador actualizado.');
    }

    public function periodo(Request $r, int $id)
    {
        abort_unless(DB::table('colaboradores')->where('id', $id)->exists(), 404);
        $d = $r->validate(['periodo_id' => 'nullable|integer', 'fecha_inicio' => 'required|date', 'fecha_fin' => 'required|date|after_or_equal:fecha_inicio', 'dias_devengados' => 'required|integer|min:1|max:366', 'usados_iniciales' => 'required|integer|min:0|lte:dias_devengados', 'nota' => 'required|string|max:1000']);
        DB::transaction(function () use ($d, $id) {
            DB::table('colaboradores')->where('id', $id)->lockForUpdate()->first();
            $p = empty($d['periodo_id']) ? null : DB::table('periodos_vacacionales')->where('id', $d['periodo_id'])->where('colaborador_id', $id)->lockForUpdate()->first();
            if (! empty($d['periodo_id']) && ! $p) {
                abort(404);
            }
            $q = DB::table('periodos_vacacionales')->where('colaborador_id', $id)->where('fecha_inicio', '<=', $d['fecha_fin'])->where('fecha_fin', '>=', $d['fecha_inicio']);
            if ($p) {
                $q->where('id', '!=', $p->id);
            }if ($q->exists()) {
                $this->service->fail('El periodo se superpone con otro ciclo.');
            }
            if ($p && ($p->fecha_inicio !== $d['fecha_inicio'] || $p->fecha_fin !== $d['fecha_fin']) && DB::table('solicitudes_vacaciones')->where('periodo_id', $p->id)->exists()) {
                $this->service->fail('Un periodo con solicitudes conserva sus fechas de servicios.');
            }
            if ($p) {
                $used = DB::table('solicitud_dias as sd')->join('solicitudes_vacaciones as s', 's.id', '=', 'sd.solicitud_id')->where('s.periodo_id', $p->id)->where('s.estado', 'APROBADA')->count();
                if ($used + $d['usados_iniciales'] > $d['dias_devengados']) {
                    $this->service->fail('El derecho no cubre los días iniciales y aprobados.');
                }
            }
            $data = collect($d)->except(['periodo_id', 'nota'])->all();
            $data['confirmado'] = 1;
            $data['nota_origen'] = $d['nota'];
            if ($p) {
                DB::table('periodos_vacacionales')->where('id', $p->id)->update($data);
            } else {
                $data['colaborador_id'] = $id;
                $data['numero_periodo'] = (DB::table('periodos_vacacionales')->where('colaborador_id', $id)->max('numero_periodo') ?? 0) + 1;
                DB::table('periodos_vacacionales')->insert($data);
            }$this->service->audit('CONFIRMAR_PERIODO', (string) $id, ['nota' => $d['nota']]);
        });

        return $this->ok('Periodo confirmado y saldo actualizado.');
    }

    public function horarios()
    {
        return view('nuevo.horarios', ['people' => DB::table('colaboradores')->whereNull('deleted_at')->orderBy('nombres')->get(), 'items' => DB::table('asignaciones_horario as a')->join('turnos as t', 't.id', '=', 'a.turno_id')->leftJoin('colaboradores as c', 'c.id', '=', 'a.colaborador_id')->select('a.*', 't.hora_entrada', 't.hora_salida', 't.inicio_refrigerio', 't.fin_refrigerio', 't.tolerancia_min', 'c.nombres')->orderByDesc('a.desde')->get()]);
    }

    public function horario(Request $r)
    {
        $d = $r->validate(['colaborador_id' => 'nullable|exists:colaboradores,id', 'desde' => 'required|date|after_or_equal:today', 'hora_entrada' => 'required|date_format:H:i', 'inicio_refrigerio' => 'required|date_format:H:i|after:hora_entrada', 'fin_refrigerio' => 'required|date_format:H:i|after:inicio_refrigerio', 'hora_salida' => 'required|date_format:H:i|after:fin_refrigerio', 'tolerancia_min' => 'required|integer|min:0|max:60', 'dias' => 'required|array|min:1', 'dias.*' => 'integer|between:1,7|distinct']);
        DB::transaction(function () use ($d) {
            DB::table('areas')->where('id', 1)->lockForUpdate()->first();
            $turn = DB::table('turnos')->insertGetId(['nombre' => 'HORARIO '.bin2hex(random_bytes(8)), 'hora_entrada' => $d['hora_entrada'], 'inicio_refrigerio' => $d['inicio_refrigerio'], 'fin_refrigerio' => $d['fin_refrigerio'], 'hora_salida' => $d['hora_salida'], 'tolerancia_min' => $d['tolerancia_min']]);
            DB::table('asignaciones_horario')->updateOrInsert(['colaborador_id' => $d['colaborador_id'] ?? null, 'desde' => $d['desde']], ['turno_id' => $turn, 'dias_semana' => json_encode(array_map('intval', $d['dias']))]);
            $this->service->audit('CONFIGURAR_HORARIO', (string) ($d['colaborador_id'] ?? 'TODOS'), ['desde' => $d['desde']]);
        });
        $this->service->refreshToday(isset($d['colaborador_id']) ? (int) $d['colaborador_id'] : null);

        return $this->ok('Horario guardado. Las jornadas con marcas conservan su horario original.');
    }

    public function calendario()
    {
        return view('nuevo.calendario', ['people' => DB::table('colaboradores')->whereNull('deleted_at')->orderBy('nombres')->get(), 'holidays' => DB::table('feriados')->orderBy('fecha')->get(), 'exceptions' => DB::table('excepciones_calendario as e')->leftJoin('colaboradores as c', 'c.id', '=', 'e.colaborador_id')->select('e.*', 'c.nombres')->orderByDesc('fecha')->get()]);
    }

    public function dia(Request $r)
    {
        $d = $r->validate(['clase' => 'required|in:feriado,excepcion', 'colaborador_id' => 'nullable|exists:colaboradores,id', 'fecha' => 'required|date|after_or_equal:today', 'motivo' => 'required|string|max:120', 'trabaja' => 'required|boolean']);
        DB::transaction(function () use ($d) {
            if ($d['clase'] === 'feriado') {
                DB::table('feriados')->updateOrInsert(['fecha' => $d['fecha']], ['motivo' => $d['motivo'], 'tipo' => 'CORPORATIVO']);
            } else {
                DB::table('excepciones_calendario')->updateOrInsert(['colaborador_id' => $d['colaborador_id'] ?? null, 'fecha' => $d['fecha']], ['trabaja' => $d['trabaja'], 'motivo' => $d['motivo']]);
            }$this->service->audit('CONFIGURAR_DIA', $d['fecha'], ['tipo' => $d['clase']]);
        });
        $this->service->refreshToday();

        return $this->ok('Calendario actualizado.');
    }

    public function borrarDia(string $tipo, int $id)
    {
        abort_unless(in_array($tipo, ['feriado', 'excepcion']), 404);
        $table = $tipo === 'feriado' ? 'feriados' : 'excepciones_calendario';
        $row = DB::table($table)->find($id);
        abort_unless($row, 404);
        if ($row->fecha < today()->toDateString()) {
            $this->service->fail('No se modifica el calendario histórico.');
        }DB::transaction(function () use ($table, $id) {
            DB::table($table)->where('id', $id)->delete();
            $this->service->audit('QUITAR_DIA', $table.':'.$id);
        });
        $this->service->refreshToday();

        return $this->ok('Día retirado del calendario.');
    }

    public function solicitarVacaciones(Request $r)
    {
        $d = $r->validate(['periodo_id' => 'required|integer', 'fecha_inicio' => 'required|date|after_or_equal:today', 'fecha_fin' => 'required|date|after_or_equal:fecha_inicio']);
        $this->service->solicitarVacaciones(auth()->id(), $d['periodo_id'], $d['fecha_inicio'], $d['fecha_fin']);

        return $this->ok('Solicitud enviada a RRHH.');
    }

    public function justificar(Request $r)
    {
        $d = $r->validate(['asistencia_id' => 'required|integer', 'tipo' => 'required|in:S,P', 'motivo' => 'required|string|max:500', 'adjunto' => ['required_if:tipo,S', 'nullable', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120']]);
        $path = null;
        try {
            DB::transaction(function () use ($d, $r, &$path) {
                $a = DB::table('asistencias')->where('id', $d['asistencia_id'])->where('colaborador_id', auth()->user()->colaborador_id)->lockForUpdate()->first();
                abort_unless($a, 403);
                $entry = DB::table('eventos_asistencia')->where('asistencia_id', $a->id)->where('tipo_evento', 'ENTRADA')->value('marca_tiempo');
                $ref = $entry ?? $a->cerrada_en;
                if (! $ref || now()->gt(Carbon::parse($ref)->addHours(48))) {
                    $this->service->fail('La jornada aún no permite justificar o venció el plazo de 48 horas.');
                }if (DB::table('justificaciones')->where('asistencia_id', $a->id)->exists()) {
                    $this->service->fail('Esta jornada ya tiene una justificación.');
                }if ($r->hasFile('adjunto')) {
                    $path = $r->file('adjunto')->store('sustentos', 'local');
                }$id = DB::table('justificaciones')->insertGetId(['asistencia_id' => $a->id, 'tipo' => $d['tipo'], 'motivo' => $d['motivo'], 'ruta_adjunto' => $path, 'solicitada_en' => now(), 'estado' => 'PENDIENTE']);
                $this->service->audit('JUSTIFICACION', (string) $id);
            });
        } catch (\Throwable $e) {
            if ($path) {
                Storage::disk('local')->delete($path);
            }throw $e;
        }

return $this->ok('Justificación enviada. El documento es privado.');
    }

    public function solicitudes()
    {
        return view('nuevo.solicitudes', ['vac' => DB::table('v_solicitudes_vacaciones as s')->join('colaboradores as c', 'c.id', '=', 's.colaborador_id')->select('s.*', 'c.nombres')->orderByDesc('s.id')->get(), 'just' => DB::table('justificaciones as j')->join('asistencias as a', 'a.id', '=', 'j.asistencia_id')->join('colaboradores as c', 'c.id', '=', 'a.colaborador_id')->select('j.*', 'a.fecha', 'c.nombres')->orderByDesc('j.id')->get()]);
    }

    public function resolver(Request $r, string $tipo, int $id)
    {
        $d = $r->validate(['estado' => 'required|in:APROBADA,RECHAZADA', 'comentario' => 'required|string|max:500']);
        if ($tipo === 'vacaciones') {
            $this->service->resolverVacaciones($id, $d['estado'], $d['comentario']);
        } elseif ($tipo === 'justificacion') {
            DB::transaction(function () use ($id, $d) {
                $s = DB::table('justificaciones')->where('id', $id)->lockForUpdate()->first();
                abort_unless($s, 404);
                if ($s->estado !== 'PENDIENTE') {
                    $this->service->fail('La solicitud ya fue resuelta.');
                }DB::table('justificaciones')->where('id', $id)->update(['estado' => $d['estado'], 'evaluado_por' => auth()->id(), 'evaluada_en' => now(), 'comentario_revision' => $d['comentario']]);
                $this->service->audit('RESOLVER_JUSTIFICACION', (string) $id, ['estado' => $d['estado']]);
            });
        } else {
            abort(404);
        }$this->service->refreshToday();

        return $this->ok('Resolución registrada.');
    }

    public function adjunto(int $id)
    {
        $j = DB::table('justificaciones as j')->join('asistencias as a', 'a.id', '=', 'j.asistencia_id')->where('j.id', $id)->select('j.*', 'a.colaborador_id')->first();
        abort_unless($j, 404);
        abort_unless(auth()->user()->isAdmin() || $j->colaborador_id == auth()->user()->colaborador_id, 403);
        abort_unless($j->ruta_adjunto && Storage::disk('local')->exists($j->ruta_adjunto), 404);

        return Storage::disk('local')->download($j->ruta_adjunto);
    }

    public function kiosco()
    {
        return view('nuevo.kiosco');
    }

    public function marcar(Request $r)
    {
        $r->validate(['username' => 'required|string|max:120', 'password' => 'required|string|regex:/^[0-9]{4}$/']);
        if (app()->isProduction()) {
            $ips = array_filter(array_map('trim', explode(',', config('dangu.kiosco_ips', ''))));
            abort_unless(in_array($r->ip(), $ips, true), 403, 'Marcación habilitada únicamente desde la sede autorizada.');
        }$u = User::where('username', mb_strtoupper(trim($r->username), 'UTF-8'))->where('activo', 1)->whereHas('colaborador', fn ($q) => $q->whereNull('deleted_at'))->first();
        if (! $u || ! Hash::check($r->password, $u->password)) {
            return back()->withErrors(['acceso' => 'Usuario o contraseña incorrectos.'])->onlyInput('username');
        }if ($u->debe_cambiar_clave) {
            return back()->withErrors(['acceso' => 'Ingrese primero al portal para cambiar su contraseña temporal.']);
        }$event = $this->service->marcar($u->colaborador_id, $r->ip());

        return back()->with('success', $u->colaborador->nombres.' · '.str_replace('_', ' ', $event).' · '.now()->format('H:i:s'));
    }

    public function reportes(Request $r)
    {
        $this->service->sync();
        $month = $this->month($r);
        $r->validate(['persona' => 'nullable|integer|exists:colaboradores,id']);
        $query = DB::table('v_asistencias_reporte as a')->join('colaboradores as c', 'c.id', '=', 'a.colaborador_id')->where('a.fecha', 'like', $month.'%')->select('a.*', 'c.nombres')->orderBy('a.fecha')->orderBy('c.nombres');
        if ($r->persona) {
            $query->where('c.id', $r->persona);
        }$rows = $query->get();
        if ($r->input('formato') === 'csv') {
            return response()->streamDownload(function () use ($rows) {
                $f = fopen('php://output', 'w');
                fwrite($f, "\xEF\xBB\xBF");
                fputcsv($f, ['TRABAJADOR', 'FECHA', 'ENTRADA', 'REFRIGERIO', 'RETORNO', 'SALIDA', 'ESTADO', 'MINUTOS TARDANZA', 'HORAS TRABAJADAS'], ';');
                foreach ($rows as $a) {
                    $name = preg_match('/^[=+@-]/u', $a->nombres) ? "'".$a->nombres : $a->nombres;
                    fputcsv($f, [$name, $a->fecha, $a->entrada, $a->inicio_refrigerio, $a->fin_refrigerio, $a->salida, $a->estado_jornada, round($a->segundos_tardanza_computables / 60, 2), $a->segundos_trabajados === null ? '' : round($a->segundos_trabajados / 3600,2)], ';');
                }fclose($f);
            }, 'asistencias-'.$month.'.csv', ['Content-Type' => 'text/csv; charset=UTF-8']);
        }

return view('nuevo.reportes',['rows' => $rows, 'month' => $month, 'people' => DB::table('colaboradores')->orderBy('nombres')->get()]);
    }

    public function catalogo(Request $r)
    {
        $d = $r->validate(['tipo' => 'required|in:area,cargo', 'nombre' => 'required|string|max:80', 'area_id' => 'required_if:tipo,cargo|nullable|exists:areas,id']);
        $table = $d['tipo'] === 'area' ? 'areas' : 'cargos';
        $v = ['nombre' => mb_strtoupper(trim($d['nombre']),'UTF-8')];
        if ($table === 'cargos') {
            $v['area_id'] = $d['area_id'];
        }if (DB::table($table)->where($v)->exists()) {
            $this->service->fail('Ya existe ese registro.');
        }DB::table($table)->insert($v);

        return $this->ok('Catálogo actualizado.');
    }
}
