<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Cargo extends Model
{
    protected $table = 'cargos';

    protected $fillable = [
        'area_id',
        'nombre',
        'descripcion',
    ];

    public function area()
    {
        return $this->belongsTo(Area::class, 'area_id');
    }

    public function colaboradores()
    {
        return $this->hasMany(Colaborador::class, 'cargo_id');
    }
}
