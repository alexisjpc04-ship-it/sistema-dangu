<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Justificacion extends Model
{
    protected $table = 'justificaciones';

    protected $fillable = [
        'asistencia_id',
        'tipo',
        'motivo',
        'ruta_adjunto',
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

    public function asistencia()
    {
        return $this->belongsTo(Asistencia::class, 'asistencia_id');
    }

    public function evaluador()
    {
        return $this->belongsTo(User::class, 'evaluado_por');
    }
}
