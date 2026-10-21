<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Turno extends Model
{
    protected $table = 'turnos';

    protected $fillable = [
        'nombre',
        'hora_entrada',
        'inicio_refrigerio',
        'fin_refrigerio',
        'hora_salida',
        'tolerancia_min',
    ];

    protected function casts(): array
    {
        return [
            'tolerancia_min' => 'integer',
        ];
    }

    public function colaboradores()
    {
        return $this->hasMany(Colaborador::class, 'turno_id');
    }

    public function asistencias()
    {
        return $this->hasMany(Asistencia::class, 'turno_id');
    }
}
