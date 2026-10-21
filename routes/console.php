<?php

use App\Services\PersonalService;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('dangu:jornadas', function () {
    app(PersonalService::class)->sync();
    $this->info('Jornadas actualizadas.');
});
Schedule::command('dangu:jornadas')->everyFiveMinutes()->withoutOverlapping();
