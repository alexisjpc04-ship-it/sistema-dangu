<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Asistencia extends Model
{
    protected $table = 'asistencias';

    protected $fillable = [
        'colaborador_id',
        'turno_id',
        'fecha',
        'requiere_marca',
        'cerrada_en',
    ];

    protected function casts(): array
    {
        return [
            'fecha' => 'date',
            'requiere_marca' => 'boolean',
            'cerrada_en' => 'datetime',
        ];
    }

    public function colaborador()
    {
        return $this->belongsTo(Colaborador::class, 'colaborador_id');
    }

    public function turno()
    {
        return $this->belongsTo(Turno::class, 'turno_id');
    }

    public function eventos()
    {
        return $this->hasMany(EventoAsistencia::class, 'asistencia_id')->orderBy('marca_tiempo');
    }

    public function justificacion()
    {
        return $this->hasOne(Justificacion::class, 'asistencia_id');
    }
}
