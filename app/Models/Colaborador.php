<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Colaborador extends Model
{
    protected $table = 'colaboradores';

    protected $fillable = [
        'cargo_id',
        'turno_id',
        'dni',
        'nombres',
        'apellidos',
        'telefono',
        'correo_contacto',
        'fecha_ingreso',
        'regimen',
        'pin_hash',
        'deleted_at',
    ];

    protected $hidden = [
        'pin_hash',
    ];

    protected function casts(): array
    {
        return [
            'fecha_ingreso' => 'date',
            'deleted_at' => 'datetime',
        ];
    }

    public function getNombreCompletoAttribute(): string
    {
        return "{$this->nombres} {$this->apellidos}";
    }

    public function cargo()
    {
        return $this->belongsTo(Cargo::class, 'cargo_id');
    }

    public function turno()
    {
        return $this->belongsTo(Turno::class, 'turno_id');
    }

    public function usuario()
    {
        return $this->hasOne(User::class, 'colaborador_id');
    }

    public function asistencias()
    {
        return $this->hasMany(Asistencia::class, 'colaborador_id');
    }

    public function periodosVacacionales()
    {
        return $this->hasMany(PeriodoVacacional::class, 'colaborador_id');
    }
}
