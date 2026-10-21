<?php

use App\Http\Controllers\PersonalController as C;
use App\Http\Middleware\ActiveAccount;
use App\Http\Middleware\RoleMiddleware;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/inicio');
Route::get('/login', [C::class, 'loginForm'])->name('login');
Route::post('/login', [C::class, 'login'])->middleware('throttle:acceso');
Route::post('/logout', [C::class, 'logout']);
Route::get('/kiosco', [C::class, 'kiosco']);
Route::post('/kiosco', [C::class, 'marcar'])->middleware('throttle:marcacion');
Route::middleware(['auth', ActiveAccount::class])->group(function () {
    Route::get('/inicio', [C::class, 'inicio']);
    Route::get('/cuenta/clave', [C::class, 'claveForm']);
    Route::post('/cuenta/clave', [C::class, 'clave'])->middleware('throttle:5,1');
    Route::post('/mis-vacaciones', [C::class, 'solicitarVacaciones']);
    Route::post('/mis-justificaciones', [C::class, 'justificar']);
    Route::get('/adjuntos/{id}', [C::class, 'adjunto'])->whereNumber('id');
    Route::middleware(RoleMiddleware::class.':ADMIN_RRHH')->group(function () {
        Route::get('/personal', [C::class, 'personal']);
        Route::post('/personal', [C::class, 'persona']);
        Route::get('/personal/{id}', [C::class, 'personaForm'])->whereNumber('id');
        Route::post('/personal/{id}', [C::class, 'persona'])->whereNumber('id');
        Route::post('/personal/{id}/estado', [C::class, 'activar'])->whereNumber('id');
        Route::post('/personal/{id}/periodo', [C::class, 'periodo'])->whereNumber('id');
        Route::get('/horarios', [C::class, 'horarios']);
        Route::post('/horarios', [C::class, 'horario']);
        Route::get('/calendario', [C::class, 'calendario']);
        Route::post('/calendario', [C::class, 'dia']);
        Route::post('/calendario/{tipo}/{id}/quitar', [C::class, 'borrarDia'])->whereNumber('id');
        Route::get('/solicitudes', [C::class, 'solicitudes']);
        Route::post('/solicitudes/{tipo}/{id}', [C::class, 'resolver'])->whereNumber('id');
        Route::get('/reportes', [C::class, 'reportes']);
        Route::post('/catalogos', [C::class, 'catalogo']);
    });
});
Route::redirect('/admin/dashboard','/inicio');
Route::redirect('/portal','/inicio');
