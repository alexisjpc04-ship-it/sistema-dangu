<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

class SolicitudVacaciones extends Model
{
    protected $table = 'solicitudes_vacaciones';

    protected $fillable = [
        'periodo_id',
        'solicitada_en',
        'estado',
        'evaluado_por',
        'evaluada_en',
        'comentario_revision',
    ];

    protected function casts(): array
    {
        return [
            'solicitada_en' => 'datetime',
            'evaluada_en' => 'datetime',
        ];
    }

    public function periodoVacacional()
    {
        return $this->belongsTo(PeriodoVacacional::class, 'periodo_id');
    }

    public function dias()
    {
        return $this->hasMany(SolicitudDia::class, 'solicitud_id')->orderBy('fecha');
    }

    public function evaluador()
    {
        return $this->belongsTo(User::class, 'evaluado_por');
    }

    public function getColaboradorAttribute()
    {
        return $this->periodoVacacional?->colaborador;
    }

    public function getColaboradorIdAttribute()
    {
        return $this->periodoVacacional?->colaborador_id;
    }

    public function getFechaInicioAttribute()
    {
        $min = $this->dias->min('fecha');

        return $min ? Carbon::parse($min) : null;
    }

    public function getFechaFinAttribute()
    {
        $max = $this->dias->max('fecha');

        return $max ? Carbon::parse($max) : null;
    }

    public function getTotalDiasAttribute(): int
    {
        return $this->dias->count();
    }
}
