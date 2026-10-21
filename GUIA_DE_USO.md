# DANGU · Sistema renovado

Entrega del 21 de octubre de 2026. Aplicación Laravel 13.38, PHP 8.3 y MySQL 8.4.3.

## Entrar al sistema

Abra http://127.0.0.1:8000/login. La base de trabajo es **db_dangu_rrhh_v2**. El puerto 8011 y las bases que contienen `qa` son de pruebas; sus claves y movimientos no son los datos reales.

En `ACCESOS_PRIVADOS.csv` y `ACCESOS_PRIVADOS.txt` encontrará las 12 cuentas: 11 trabajadores y ADMIN.DANGU. Use el usuario completo, por ejemplo **ALEXIS.AVALOS**. Se admite escribir el usuario en minúsculas, pero se guarda y muestra en MAYÚSCULAS. La contraseña sí distingue mayúsculas. No se exige DNI; el campo queda opcional para completarlo cuando exista información real.

Cada cuenta debe cambiar su contraseña temporal al primer ingreso. Si se olvida, el administrador abre **Trabajadores → Editar → Nueva clave temporal** y comunica esa clave al titular. Restablecer o desactivar una cuenta invalida sus sesiones anteriores. No comparta el archivo completo de accesos con los trabajadores: entregue a cada uno solo su cuenta.

Si el servidor se detiene, abra una terminal en `SISTEMA` y ejecute `php artisan serve --host=127.0.0.1 --port=8000` usando el PHP de Laragon. MySQL debe estar iniciado. El servidor de desarrollo no es el servidor público de producción.

## Administrador

- **Resumen:** seleccionar un trabajador y un mes; abrir cualquier día para ver sus marcaciones.
- **Trabajadores:** buscar, crear, editar y activar/desactivar personas; añadir áreas y cargos; configurar DNI opcional, fecha real de ingreso y régimen. Los nombres respetan la fuente Excel.
- **Horarios:** elegir todo el equipo o una persona, fecha de vigencia, días semanales, entrada, salida a refrigerio, retorno y salida. El horario individual tiene prioridad sobre el general. Para cambiar uno, registrar otra asignación. Las jornadas con marcas conservan su horario original.
- **Feriados y descansos:** crear o actualizar un feriado general, un descanso general o individual y una excepción de trabajo. La excepción individual tiene prioridad sobre la general y sobre el feriado. Las vacaciones aprobadas prevalecen. No se editan días pasados.
- **Solicitudes:** aprobar o rechazar vacaciones y justificaciones con un comentario. Las resoluciones no se repiten.
- **Reportes:** filtrar por trabajador/mes, descargar CSV UTF-8 o imprimir/guardar PDF con el navegador.

## Trabajador

Consulta únicamente su calendario, sus saldos y sus solicitudes. Puede pedir vacaciones de un periodo confirmado y ya devengado. Se cuentan todos los días calendario del rango; no se descuentan feriados ni fines de semana del rango solicitado. Puede justificar una jornada hasta 48 horas después de la entrada o del cierre si no marcó. Salud exige PDF/JPG/PNG de hasta 5 MB; el documento solo lo descargan el titular y el administrador.

**Registrar asistencia** abre el kiosco. Introducir usuario y contraseña, también mediante TAB y ENTER. La secuencia es entrada, salida a refrigerio, retorno y salida. El sistema rechaza repeticiones inmediatas, marcas en descanso y una quinta marca. En producción, solo acepta la IP de sede configurada.

## Datos que RRHH debe confirmar

Se usó la hoja **Reporte**, filas 3 a 13, de `Registro_Vacaciones_Activos.xlsx`: STEVEN GONZALES, ALEXIS AVALOS, VICTOR ROSARIO, VICTORIA SOLEDAD ALZA, KARINA CINTHIA CASTILLO, ARACELY JANELY PEREZ, LIZ VALDEIVIESO, FLOR MATILDE CORDOVA, JHAN CARLOS CABRERA, JOYCE KATHERINE PEÑA y MANUEL SANCHEZ. No se fusionaron nombres sueltos de calendarios históricos ni se importaron retirados de otras hojas.

El encabezado del Reporte dice julio de 2027, posterior a esta entrega, y contiene notas pendientes. Por eso se importaron los periodos y cantidades como **referencia sin confirmar**. RRHH debe revisar cada ficha y confirmar el periodo, el derecho reconocido y los días usados previamente. Las fechas de ciclo del Excel no se tomaron como fechas de contratación. No se inventaron DNI, historial de marcaciones ni fechas de vacaciones usadas.

El horario inicial es una **propuesta**: lunes a sábado, 08:00–18:00, refrigerio 13:00–14:00, tolerancia de 10 minutos. Ajustarlo antes de usar el sistema para control real. Se implementan jornadas diurnas con un refrigerio; no turnos nocturnos ni varios intervalos diarios. El régimen y la fecha de ingreso quedan por confirmar.

Se cargaron los 12 días de la imagen como **calendario corporativo 2026**: 1 enero; 2 y 3 abril; 1 mayo; 29 junio; 28 y 29 julio; 30 agosto; 8 octubre; 1 noviembre; 8 y 25 diciembre. No se presenta esa lista como una enumeración legal exhaustiva. El administrador debe configurar los siguientes años.

## Archivos entregados

- `SISTEMA_PARA_INSTALAR.zip`: código limpio y dependencias fijadas en composer.lock; instalar dependencias con Composer.
- `BASE_INICIAL_PRIVADA.sql`: esquema y datos reales con contraseñas cifradas mediante hash; restaurar únicamente en una base vacía. No contiene contraseñas en texto legible.
- `ACCESOS_PRIVADOS.csv` / `.txt`: claves temporales originales; pierden validez cuando cada usuario las cambia.
- `DESPLIEGUE.md`: instalación en hosting con HTTPS, IP de sede y tarea programada.
- `PRUEBAS_*.json` y `PRUEBA_RESTAURACION.txt`: evidencia de pruebas.
- `RESPALDO_PREVIO`: código, base y dependencias anteriores. La base original `db_dangu_rrhh` también se conservó.

La nube todavía no está publicada: falta configurar el hosting/dominio, credenciales de base y la IP real de la sede. Los saldos, régimen y horarios requieren la revisión empresarial indicada arriba.


## Diseño y primer ingreso actualizados
Se utiliza el logo original dangu_logo.jpg con azul #004B80 y amarillo #FFCA05. Se quitó la mención visible de Lima; la zona horaria de los registros se conserva para calcular correctamente la asistencia. En el primer ingreso solo se muestra la activación de contraseña. El menú aparece después de guardar la nueva clave; antes mostraba enlaces que redirigían al mismo formulario. Se verificaron los seis paneles administrativos, el diálogo Nuevo trabajador y 26 comprobaciones de marca y navegación.


## Accesos vigentes: un nombre, un apellido y PIN de cuatro dígitos
Por solicitud del titular, los usuarios de trabajadores siguen NOMBRE.APELLIDO, en MAYÚSCULAS, conservando sus nombres completos en la ficha. La cuenta administrativa es ADMIN.DANGU. La clave inicial de todas las cuentas es 1234; las cuentas nuevas también reciben 1234 si no se especifica otra clave. Al primer ingreso debe reemplazarse por otro PIN de exactamente cuatro dígitos numéricos, incluidos posibles ceros iniciales. Las claves anteriores dejaron de servir y sus sesiones se invalidaron. La clave se guarda con hash; continúan los permisos y los límites de intentos. Un PIN de cuatro dígitos ofrece menor resistencia a intentos de adivinación que una contraseña larga; no compartir el PIN personal y no mantener 1234 para operación pública. El paquete y el SQL inicial privados reflejan estos accesos. El hosting/HTTPS y la IP de sede todavía deben configurarse para publicar.
