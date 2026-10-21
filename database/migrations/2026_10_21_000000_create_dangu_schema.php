<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasTable('usuarios')) {
            if (! Schema::hasTable('asignaciones_horario') || ! Schema::hasColumn('usuarios', 'username')) {
                throw new RuntimeException('La base existente no es DANGU v2. Utilice una base nueva o una migración revisada.');
            }

            return; // Baseline for a restored v2 deployment dump.
        }
        DB::unprepared(file_get_contents(database_path('esquema_v2.sql')));
    }

    public function down(): void
    {
        throw new RuntimeException('El borrado automático de datos de personal está deshabilitado. Restaure un respaldo revisado.');
    }
};
