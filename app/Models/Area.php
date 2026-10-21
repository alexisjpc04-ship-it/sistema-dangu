<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Area extends Model
{
    protected $table = 'areas';

    protected $fillable = [
        'nombre',
        'descripcion',
    ];

    public function cargos()
    {
        return $this->hasMany(Cargo::class, 'area_id');
    }
}
