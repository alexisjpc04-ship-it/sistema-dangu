<!doctype html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="color-scheme" content="light"><title>@yield('title','Mi espacio') · Dangu</title><link rel="icon" href="{{ asset('images/dangu-logo.jpg') }}"><link rel="stylesheet" href="{{ asset('css/dangu.css') }}?v=marca2"><script defer src="{{ asset('js/dangu.js') }}?v=marca2"></script></head>
@php($activando=auth()->check() && auth()->user()->debe_cambiar_clave)
@php($conMenu=auth()->check() && !$activando)
<body class="{{ $conMenu?'app-shell':'public-shell' }}">
<a class="skip" href="#contenido">Saltar al contenido</a>
@if($conMenu)
<aside class="sidebar" id="navegacion"><a class="brand" href="/inicio" aria-label="Dangu, inicio"><img class="logo" src="{{ asset('images/dangu-logo.jpg') }}" alt="Dangu"></a><span class="nav-label">GESTIÓN DEL PERSONAL</span>
<nav aria-label="Paneles del sistema">
@php($links=auth()->user()->isAdmin()?['/inicio'=>['01','Resumen'],'/personal'=>['02','Trabajadores'],'/horarios'=>['03','Horarios'],'/calendario'=>['04','Feriados y descansos'],'/solicitudes'=>['05','Solicitudes'],'/reportes'=>['06','Reportes']]:['/inicio'=>['01','Mi calendario']])
@foreach($links as $url=>$item)<a href="{{ $url }}" class="{{ request()->is(ltrim($url,'/').'*')?'active':'' }}" @if(request()->is(ltrim($url,'/').'*')) aria-current="page" @endif><span class="nav-number" aria-hidden="true">{{ $item[0] }}</span>{{ $item[1] }}</a>@endforeach
</nav><div class="sidebar-tools"><a href="/kiosco">Registrar asistencia ↗</a><a href="/cuenta/clave" @if(request()->is('cuenta/clave')) aria-current="page" @endif>Mi contraseña</a></div>
<div class="sidebar-bottom"><span class="avatar" aria-hidden="true">{{ mb_substr(auth()->user()->colaborador->nombres,0,1) }}</span><div><strong>{{ auth()->user()->username }}</strong><small>{{ auth()->user()->isAdmin()?'Administración':'Trabajador' }}</small></div><form method="post" action="/logout">@csrf<button class="text-button">Cerrar sesión</button></form></div></aside>
@endif
<main id="contenido" class="{{ $conMenu?'main':'public-main' }}"><header class="topbar">
@if($conMenu)<div><span class="header-label">DANGU · PORTAL DEL EQUIPO</span><strong>@yield('title','Mi espacio')</strong></div><a class="mobile-menu" href="#navegacion">Ver menú ↑</a>
@else<a class="brand" href="{{ $activando?'/cuenta/clave':'/login' }}" aria-label="Dangu"><img class="logo" src="{{ asset('images/dangu-logo.jpg') }}" alt="Dangu"></a><span class="header-label">PORTAL DEL EQUIPO</span>@endif
<span class="header-date">{{ now()->format('d/m/Y') }}</span>
@if($activando)<form method="post" action="/logout">@csrf<button class="secondary">Cerrar sesión</button></form>@endif
</header>
@if(session('success'))<div class="alert success" role="status">{{ session('success') }}</div>@endif
@if($errors->any())<div class="alert error" role="alert"><strong>No se pudo guardar. Revisa estos datos:</strong><ul>@foreach($errors->all() as $error)<li>{{ $error }}</li>@endforeach</ul></div>@endif
@yield('content')<footer>Dangu · Gestión del personal</footer></main></body></html>
