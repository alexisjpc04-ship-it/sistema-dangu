<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PeriodoVacacional extends Model
{
    protected $table = 'periodos_vacacionales';

    protected $fillable = [
        'colaborador_id',
        'numero_periodo',
        'fecha_inicio',
        'fecha_fin',
        'dias_devengados',
    ];

    protected function casts(): array
    {
        return [
            'fecha_inicio' => 'date',
            'fecha_fin' => 'date',
            'numero_periodo' => 'integer',
            'dias_devengados' => 'integer',
        ];
    }

    public function colaborador()
    {
        return $this->belongsTo(Colaborador::class, 'colaborador_id');
    }

    public function solicitudes()
    {
        return $this->hasMany(SolicitudVacaciones::class, 'periodo_id');
    }
}
