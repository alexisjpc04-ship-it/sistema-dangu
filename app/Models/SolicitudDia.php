<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SolicitudDia extends Model
{
    protected $table = 'solicitud_dias';

    protected $fillable = [
        'solicitud_id',
        'fecha',
    ];

    protected function casts(): array
    {
        return [
            'fecha' => 'date',
        ];
    }

    public function solicitud()
    {
        return $this->belongsTo(SolicitudVacaciones::class, 'solicitud_id');
    }
}
