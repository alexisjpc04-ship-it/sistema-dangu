<?php

namespace App\Providers;

use Carbon\Carbon;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Middleware\TrustProxies;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $proxies = array_filter(array_map('trim', explode(',', config('dangu.trusted_proxies', ''))));
        TrustProxies::at(array_values($proxies));
        RateLimiter::for('acceso', function (Request $r) {
            return [Limit::perMinute(60)->by('ip:'.$r->ip()),
                Limit::perMinute(5)->by('usuario:'.$r->ip().'|'.mb_strtoupper((string) $r->input('username'), 'UTF-8'))];
        });
        RateLimiter::for('marcacion', function (Request $r) {
            return [Limit::perMinute(120)->by('ip:'.$r->ip()),
                Limit::perMinute(5)->by('usuario:'.$r->ip().'|'.mb_strtoupper((string) $r->input('username'), 'UTF-8'))];
        });
        Carbon::setLocale('es');
        setlocale(LC_TIME, 'es_ES.utf8', 'es_ES', 'es_PE.utf8', 'es_PE', 'es', 'Spanish_Spain.1252');
    }
}
