<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EventoAsistencia extends Model
{
    protected $table = 'eventos_asistencia';

    protected $fillable = [
        'asistencia_id',
        'tipo_evento',
        'marca_tiempo',
        'ip_origen',
        'dispositivo',
    ];

    protected function casts(): array
    {
        return [
            'marca_tiempo' => 'datetime',
        ];
    }

    public function asistencia()
    {
        return $this->belongsTo(Asistencia::class, 'asistencia_id');
    }
}
