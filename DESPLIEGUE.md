# Instalar DANGU en un hosting

Versión validada: Laravel 13.38.0, PHP 8.3.33 y MySQL 8.4.3. Use PHP 8.3 o compatible con composer.lock, MySQL 8.4 y Composer 2. El SQL usa CHECK, JSON, columnas generadas, vistas y triggers; no se probó SQLite, PostgreSQL ni MariaDB.

## Instalación inicial

1. Extraer `SISTEMA_PARA_INSTALAR.zip` fuera del directorio público. Configurar el dominio para que su raíz sea únicamente `SISTEMA/public`. No exponer `.env`, `storage`, SQL ni archivos de accesos. El diseño no requiere Node, npm ni servicios externos.
2. Ejecutar en `SISTEMA`: `composer install --no-dev --prefer-dist --optimize-autoloader`. Se utiliza composer.lock; no ejecutar una actualización de versiones durante el despliegue.
3. Crear una base MySQL **vacía** con `utf8mb4` y `utf8mb4_unicode_ci`. Importar `BASE_INICIAL_PRIVADA.sql` mediante la consola privada del proveedor o `mysql -h HOST -u INSTALADOR -p BASE < BASE_INICIAL_PRIVADA.sql`. El usuario de instalación necesita permisos para tablas, vistas y triggers. El dump no fija un usuario DEFINER específico del equipo local.
4. Copiar `.env.production.example` a `.env`. Completar APP_URL con el dominio HTTPS y DB_HOST/DB_DATABASE/DB_USERNAME/DB_PASSWORD con datos reales. El usuario de ejecución debe tener los permisos de lectura y escritura que exige la aplicación; no usar root. Mantener APP_ENV=production y APP_DEBUG=false. Si MySQL es remoto, configurar TLS y su CA según el proveedor.
5. Ejecutar `php artisan key:generate` **solo para esta instalación nueva**. Conservar esa clave en los futuros despliegues. No reemplazar la clave de una instalación ya utilizada.
6. Configurar `DANGU_KIOSCO_IPS` con las IP públicas reales de la sede, separadas por comas. Vacío bloquea las marcaciones en producción. Si hay proxy inverso, configurar únicamente sus IP/CIDR reales en `DANGU_TRUSTED_PROXIES`; no usar `*`. Verificar desde la sede que la IP recibida corresponde al cliente y que otra red no puede marcar.
7. Dar acceso de escritura al proceso web sobre `storage` y `bootstrap/cache`. Los sustentos quedan en `storage/app/sustentos`, fuera de public; **no crear enlaces públicos a esa carpeta**. Ajustar `upload_max_filesize` a 5 MB o más y `post_max_size` a 8 MB o más.
8. Ejecutar `php artisan migrate --force` para registrar el esquema restaurado; después `php artisan config:cache`, `php artisan route:cache` y `php artisan view:cache`. La migración también puede crear solo el esquema vacío, pero no crea cuentas ni importa el Excel por sí sola. No ejecutar migrate:fresh sobre una base con personal.
9. Configurar el cron cada minuto: `* * * * * cd /ruta/SISTEMA && php artisan schedule:run >> /dev/null 2>&1`. El comando de jornadas corre cada cinco minutos. En un único servidor usar almacenamiento persistente para sesiones, caché y documentos. Un despliegue con múltiples réplicas exige adaptar esos almacenes antes de usarlo.
10. Ejecutar `php artisan dangu:verificar`. Sus pendientes técnicos deben resolverse. Ingresar como ADMIN.DANGU, cambiar la clave temporal y revisar horarios, calendario, régimen y periodos del Excel. Entregar cada acceso únicamente a su titular.

## Comprobación en el servidor final

Probar acceso administrador/trabajador, rechazo de rutas administrativas desde una cuenta personal, calendario individual, una solicitud de prueba, documento privado y marcación desde la sede. Confirmar HTTPS y que archivos SQL, `.env` y `storage/app` no se sirven por HTTP. El servidor local usado para desarrollar no sustituye esta verificación del hosting real.

Hacer copias de MySQL y `storage/app/sustentos` con una política de retención de la empresa; conservar también APP_KEY de forma privada. Verificar la restauración periódicamente. El dump entregado es una instantánea inicial: no debe reimportarse después de que el personal empiece a trabajar porque reemplazaría el estado con una versión antigua.

No se publicaron datos ni se contrató un servicio de hosting durante esta entrega.

Referencias técnicas consultadas: [despliegue de Laravel 13](https://laravel.com/docs/13.x/deployment), [actualización a Laravel 13](https://laravel.com/docs/13.x/upgrade).


## Accesos vigentes: un nombre, un apellido y PIN de cuatro dígitos
Por solicitud del titular, los usuarios de trabajadores siguen NOMBRE.APELLIDO, en MAYÚSCULAS, conservando sus nombres completos en la ficha. La cuenta administrativa es ADMIN.DANGU. La clave inicial de todas las cuentas es 1234; las cuentas nuevas también reciben 1234 si no se especifica otra clave. Al primer ingreso debe reemplazarse por otro PIN de exactamente cuatro dígitos numéricos, incluidos posibles ceros iniciales. Las claves anteriores dejaron de servir y sus sesiones se invalidaron. La clave se guarda con hash; continúan los permisos y los límites de intentos. Un PIN de cuatro dígitos ofrece menor resistencia a intentos de adivinación que una contraseña larga; no compartir el PIN personal y no mantener 1234 para operación pública. El paquete y el SQL inicial privados reflejan estos accesos. El hosting/HTTPS y la IP de sede todavía deben configurarse para publicar.
