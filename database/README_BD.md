# Base vigente DANGU v2

MySQL 8.4; InnoDB, utf8mb4 y zona -05:00. `esquema_v2.sql` contiene únicamente estructura para una base vacía. `BASE_INICIAL_PRIVADA.sql`, ubicado fuera del código, contiene estructura y datos iniciales reales. No importar ambos en la misma base.

17 tablas de dominio: areas, cargos, turnos, colaboradores, usuarios, roles, usuario_rol, asistencias, eventos_asistencia, justificaciones, periodos_vacacionales, solicitudes_vacaciones, solicitud_dias, feriados, asignaciones_horario, excepciones_calendario y auditoria. Cuatro vistas: v_marcaciones, v_asistencias_reporte, v_solicitudes_vacaciones y v_saldos_vacacionales. Los tres triggers protegen cambios a marcaciones y versiones de turno. Las reglas de secuencia, saldo y solapamiento se ejecutan en PersonalService dentro de transacciones y bloqueos de fila. No conceder acceso de escritura SQL directo a trabajadores.

La conexión aplica READ COMMITTED. La aprobación de vacaciones bloquea colaborador y periodo, revalida saldo y solapamiento y registra resolución y auditoría en la misma transacción. La marcación bloquea colaborador y jornada; la clave única impide duplicar tipos de evento. Las claves foráneas y CHECK preservan integridad estructural.

Los feriados generales se almacenan por fecha una sola vez; las excepciones tienen alcance general o individual. No es un error mantener feriados en su tabla independiente. Las asignaciones enlazan un turno versionado con una fecha de vigencia y sus días semanales. La jornada conserva su turno cuando ya tiene marcas.

El DNI y la fecha de ingreso son opcionales. Los usuarios tienen identificador textual en MAYÚSCULAS y hash de contraseña; nunca texto plano. Los periodos del Excel se importan sin confirmar. El saldo disponible descuenta días iniciales y todas las vacaciones aprobadas, incluso futuras; solicitudes pendientes se muestran aparte y no reservan saldo hasta aprobarse.

La instalación original se respaldó y continúa en db_dangu_rrhh. La base nueva es db_dangu_rrhh_v2. No usar scripts históricos que contienen DROP DATABASE. La migración vigente se registra sobre un dump v2 existente sin recrear tablas; su reversión destructiva está deshabilitada.
