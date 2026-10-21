<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class VerificarDangu extends Command
{
    protected $signature = 'dangu:verificar';

    protected $description = 'Comprueba configuración y datos pendientes antes de publicar';

    public function handle(): int
    {
        $checks = [
            'Entorno production' => app()->isProduction(),
            'Depuración desactivada' => ! config('app.debug'),
            'URL HTTPS real' => str_starts_with(config('app.url'), 'https://') && ! str_contains(config('app.url'), '.example'),
            'Clave de aplicación configurada' => (bool) config('app.key'),
            'Cookie segura' => (bool) config('session.secure'),
            'IP de sede configurada' => (bool) trim(config('dangu.kiosco_ips', '')),
            'Proxy no universal' => ! in_array('*', array_map('trim', explode(',', config('dangu.trusted_proxies', '')))),
            'MySQL con UTF-8 completo' => DB::selectOne('SELECT @@character_set_connection AS c')->c === 'utf8mb4',
        ];
        foreach ($checks as $label => $ok) {
            $this->line(($ok ? 'OK: ' : 'PENDIENTE: ').$label);
        }
        $this->warn('Periodos por confirmar: '.DB::table('periodos_vacacionales')->where('confirmado', 0)->count());
        $this->warn('Cuentas con clave temporal: '.DB::table('usuarios')->where('activo', 1)->where('debe_cambiar_clave', 1)->count());
        $this->warn('RRHH debe revisar horarios, régimen, fechas de ingreso y calendario anual.');

        return in_array(false, $checks, true) ? self::FAILURE : self::SUCCESS;
    }
}
