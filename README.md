# DANGU · Personal, asistencia y vacaciones

Aplicación Laravel 13.38, PHP 8.3+, MySQL 8.4. Entrada por usuario en MAYÚSCULAS y contraseña; DNI opcional. Interfaz en español, UTF-8, sin dependencias de CDN ni compilación npm.

## Ejecutar localmente

La instalación del equipo está conectada a `db_dangu_rrhh_v2`. Iniciar MySQL en Laragon y ejecutar `php artisan serve --host=127.0.0.1 --port=8000` desde esta carpeta. Abrir http://127.0.0.1:8000/login.

En una instalación nueva: instalar dependencias con `composer install`, copiar `.env.example` a `.env`, configurar la base, generar APP_KEY una sola vez y restaurar el SQL privado en una base vacía. Ejecutar `php artisan migrate` registra la base restaurada o crea solamente el esquema, sin cuentas. No usar los SQL de versiones académicas anteriores.

## Estructura vigente

- `routes/web.php`: rutas protegidas de usuario, administrador y kiosco.
- `app/Http/Controllers/PersonalController.php`: formularios y control de propiedad.
- `app/Services/PersonalService.php`: planes, jornadas, marcaciones y vacaciones con transacciones y bloqueos.
- `app/Http/Middleware`: cuenta activa, rol y cabeceras de seguridad.
- `resources/views/nuevo`, `public/css/dangu.css`, `public/js/dangu.js`: interfaz adaptable y teclado.
- `database/esquema_v2.sql`: esquema actual, 17 tablas de dominio, cuatro vistas y tres triggers.
- `lang/es/validation.php`: mensajes de validación en español.

No hay dependencias del controlador o las vistas antiguas; se archivaron fuera de la aplicación. Los cálculos no invocan los procedimientos de la base anterior. La migración añade una tabla administrativa `migrations` al ejecutarse.

## Operación

`php artisan dangu:jornadas` crea las jornadas desde la puesta en marcha y cierra las anteriores. El scheduler lo ejecuta cada cinco minutos. Se requiere cron `schedule:run` cada minuto en producción. Cada acceso al calendario y a reportes también sincroniza jornadas.

`php artisan dangu:verificar` enumera la configuración técnica pendiente antes de publicar. `php artisan test` prueba las rutas públicas; las pruebas de integración MySQL y HTTP se realizaron en bases QA separadas y su evidencia está en la entrega.

Consulte `GUIA_DE_USO.md` y `DESPLIEGUE.md`. La entrega privada externa contiene cuentas y SQL inicial. Nunca copiarla a `public` ni versionarla públicamente.


## Diseño y primer ingreso actualizados
Se utiliza el logo original dangu_logo.jpg con azul #004B80 y amarillo #FFCA05. Se quitó la mención visible de Lima; la zona horaria de los registros se conserva para calcular correctamente la asistencia. En el primer ingreso solo se muestra la activación de contraseña. El menú aparece después de guardar la nueva clave; antes mostraba enlaces que redirigían al mismo formulario. Se verificaron los seis paneles administrativos, el diálogo Nuevo trabajador y 26 comprobaciones de marca y navegación.


## Accesos vigentes: un nombre, un apellido y PIN de cuatro dígitos
Por solicitud del titular, los usuarios de trabajadores siguen NOMBRE.APELLIDO, en MAYÚSCULAS, conservando sus nombres completos en la ficha. La cuenta administrativa es ADMIN.DANGU. La clave inicial de todas las cuentas es 1234; las cuentas nuevas también reciben 1234 si no se especifica otra clave. Al primer ingreso debe reemplazarse por otro PIN de exactamente cuatro dígitos numéricos, incluidos posibles ceros iniciales. Las claves anteriores dejaron de servir y sus sesiones se invalidaron. La clave se guarda con hash; continúan los permisos y los límites de intentos. Un PIN de cuatro dígitos ofrece menor resistencia a intentos de adivinación que una contraseña larga; no compartir el PIN personal y no mantener 1234 para operación pública. El paquete y el SQL inicial privados reflejan estos accesos. El hosting/HTTPS y la IP de sede todavía deben configurarse para publicar.
