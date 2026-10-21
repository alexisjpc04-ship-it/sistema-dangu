<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ActiveAccount
{
    public function handle(Request $request, Closure $next)
    {
        $u = $request->user();
        if (! $u || ! $u->activo || ! $u->colaborador || $u->colaborador->deleted_at || (int) $request->session()->get('version_sesion') !== (int) $u->version_sesion) {
            Auth::logout();
            $request->session()->invalidate();
            $request->session()->regenerateToken();

            return redirect('/login')->withErrors(['acceso' => 'La sesión terminó o la cuenta está desactivada.']);
        }
        if ($u->debe_cambiar_clave && ! $request->is('cuenta/clave', 'logout')) {
            return redirect('/cuenta/clave');
        }

        return $next($request);
    }
}
