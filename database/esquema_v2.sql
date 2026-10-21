SET NAMES utf8mb4;
SET time_zone='-05:00';
CREATE TABLE areas (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_areas_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. TABLA: cargos
-- -----------------------------------------------------------------------------
CREATE TABLE cargos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  area_id BIGINT UNSIGNED NOT NULL,
  nombre VARCHAR(80) NOT NULL,
  descripcion VARCHAR(255) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_cargos_area_nombre (area_id, nombre),
  CONSTRAINT fk_cargos_area FOREIGN KEY (area_id)
    REFERENCES areas (id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 3. TABLA: turnos
-- -----------------------------------------------------------------------------
CREATE TABLE turnos (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(80) NOT NULL,
  hora_entrada TIME NOT NULL,
  inicio_refrigerio TIME NOT NULL,
  fin_refrigerio TIME NOT NULL,
  hora_salida TIME NOT NULL,
  tolerancia_min TINYINT UNSIGNED NOT NULL DEFAULT 10,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_turnos_nombre (nombre),
  CONSTRAINT ck_turnos_coherencia CHECK (
    hora_entrada >= '00:00:00' AND hora_salida < '24:00:00' AND
    hora_entrada < inicio_refrigerio AND
    inicio_refrigerio < fin_refrigerio AND
    fin_refrigerio < hora_salida
  ),
  CONSTRAINT ck_turnos_tolerancia CHECK (tolerancia_min <= 60)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 4. TABLA: colaboradores
-- -----------------------------------------------------------------------------
CREATE TABLE colaboradores (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cargo_id BIGINT UNSIGNED NOT NULL,
  turno_id BIGINT UNSIGNED NOT NULL,
  dni CHAR(8) NOT NULL,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  telefono VARCHAR(20) NULL,
  correo_contacto VARCHAR(120) NULL,
  fecha_ingreso DATE NOT NULL,
  regimen VARCHAR(30) NOT NULL DEFAULT 'REMYPE',
  pin_hash VARCHAR(255) NOT NULL,
  deleted_at DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_colaboradores_dni (dni),
  CONSTRAINT fk_colaboradores_cargo FOREIGN KEY (cargo_id)
    REFERENCES cargos (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_colaboradores_turno FOREIGN KEY (turno_id)
    REFERENCES turnos (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_colaboradores_dni CHECK (dni REGEXP '^[0-9]{8}$'),
  CONSTRAINT ck_colaboradores_pin CHECK (CHAR_LENGTH(TRIM(pin_hash)) > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 5. TABLA: usuarios
-- -----------------------------------------------------------------------------
CREATE TABLE usuarios (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  colaborador_id BIGINT UNSIGNED NOT NULL,
  email VARCHAR(120) NOT NULL,
  password VARCHAR(255) NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT 1,
  remember_token VARCHAR(100) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_usuarios_colaborador (colaborador_id),
  UNIQUE KEY uk_usuarios_email (email),
  CONSTRAINT fk_usuarios_colaborador FOREIGN KEY (colaborador_id)
    REFERENCES colaboradores (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_usuarios_activo CHECK (activo IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 6. TABLA: roles
-- -----------------------------------------------------------------------------
CREATE TABLE roles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(30) NOT NULL,
  descripcion VARCHAR(255) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_roles_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 7. TABLA: usuario_rol
-- -----------------------------------------------------------------------------
CREATE TABLE usuario_rol (
  usuario_id BIGINT UNSIGNED NOT NULL,
  rol_id BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (usuario_id, rol_id),
  CONSTRAINT fk_ur_usuario FOREIGN KEY (usuario_id)
    REFERENCES usuarios (id) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT fk_ur_rol FOREIGN KEY (rol_id)
    REFERENCES roles (id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 8. TABLA: asistencias
-- -----------------------------------------------------------------------------
CREATE TABLE asistencias (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  colaborador_id BIGINT UNSIGNED NOT NULL,
  turno_id BIGINT UNSIGNED NOT NULL,
  fecha DATE NOT NULL,
  requiere_marca BOOLEAN NOT NULL DEFAULT 1,
  cerrada_en DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_asistencias_colab_fecha (colaborador_id, fecha),
  KEY ix_asistencias_fecha (fecha),
  CONSTRAINT fk_asistencias_colaborador FOREIGN KEY (colaborador_id)
    REFERENCES colaboradores (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_asistencias_turno FOREIGN KEY (turno_id)
    REFERENCES turnos (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_asistencias_marca CHECK (requiere_marca IN (0, 1)),
  CONSTRAINT ck_asistencias_cierre CHECK (cerrada_en IS NULL OR DATE(cerrada_en) >= fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 9. TABLA: eventos_asistencia
-- -----------------------------------------------------------------------------
CREATE TABLE eventos_asistencia (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  asistencia_id BIGINT UNSIGNED NOT NULL,
  tipo_evento ENUM('ENTRADA','SALIDA_REFRIGERIO','RETORNO_REFRIGERIO','SALIDA') NOT NULL,
  marca_tiempo DATETIME NOT NULL,
  ip_origen VARCHAR(45) NOT NULL,
  dispositivo VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_eventos_asistencia_tipo (asistencia_id, tipo_evento),
  KEY ix_eventos_marca_tiempo (marca_tiempo),
  CONSTRAINT fk_eventos_asistencia FOREIGN KEY (asistencia_id)
    REFERENCES asistencias (id) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 10. TABLA: justificaciones
-- -----------------------------------------------------------------------------
CREATE TABLE justificaciones (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  asistencia_id BIGINT UNSIGNED NOT NULL,
  tipo ENUM('S','P') NOT NULL,
  motivo VARCHAR(500) NOT NULL,
  ruta_adjunto VARCHAR(255) NULL,
  solicitada_en DATETIME NOT NULL,
  estado ENUM('PENDIENTE','APROBADA','RECHAZADA') NOT NULL DEFAULT 'PENDIENTE',
  evaluado_por BIGINT UNSIGNED NULL,
  evaluada_en DATETIME NULL,
  comentario_revision VARCHAR(500) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_justificaciones_asistencia (asistencia_id),
  KEY ix_justificaciones_estado_fecha (estado, solicitada_en),
  CONSTRAINT fk_justificaciones_asistencia FOREIGN KEY (asistencia_id)
    REFERENCES asistencias (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_justificaciones_evaluador FOREIGN KEY (evaluado_por)
    REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_justificaciones_adjunto CHECK (
    tipo <> 'S' OR (ruta_adjunto IS NOT NULL AND CHAR_LENGTH(TRIM(ruta_adjunto)) > 0)
  ),
  CONSTRAINT ck_justificaciones_resolucion CHECK (
    (estado = 'PENDIENTE' AND evaluado_por IS NULL AND evaluada_en IS NULL) OR
    (estado <> 'PENDIENTE' AND evaluado_por IS NOT NULL AND evaluada_en IS NOT NULL AND
     evaluada_en >= solicitada_en AND comentario_revision IS NOT NULL AND
     CHAR_LENGTH(TRIM(comentario_revision)) > 0)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 11. TABLA: periodos_vacacionales
-- -----------------------------------------------------------------------------
CREATE TABLE periodos_vacacionales (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  colaborador_id BIGINT UNSIGNED NOT NULL,
  numero_periodo SMALLINT UNSIGNED NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  dias_devengados SMALLINT UNSIGNED NOT NULL DEFAULT 15,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_periodos_colab_num (colaborador_id, numero_periodo),
  UNIQUE KEY uk_periodos_colab_ini (colaborador_id, fecha_inicio),
  CONSTRAINT fk_periodos_colaborador FOREIGN KEY (colaborador_id)
    REFERENCES colaboradores (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_periodos_numero CHECK (numero_periodo > 0),
  CONSTRAINT ck_periodos_fechas CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT ck_periodos_dias CHECK (dias_devengados BETWEEN 1 AND 366)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 12. TABLA: solicitudes_vacaciones
-- -----------------------------------------------------------------------------
CREATE TABLE solicitudes_vacaciones (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  periodo_id BIGINT UNSIGNED NOT NULL,
  solicitada_en DATETIME NOT NULL,
  estado ENUM('PENDIENTE','APROBADA','RECHAZADA') NOT NULL DEFAULT 'PENDIENTE',
  evaluado_por BIGINT UNSIGNED NULL,
  evaluada_en DATETIME NULL,
  comentario_revision VARCHAR(500) NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY ix_solicitudes_periodo (periodo_id),
  KEY ix_solicitudes_estado (estado, solicitada_en),
  CONSTRAINT fk_solicitudes_periodo FOREIGN KEY (periodo_id)
    REFERENCES periodos_vacacionales (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT fk_solicitudes_evaluador FOREIGN KEY (evaluado_por)
    REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT ck_solicitudes_resolucion CHECK (
    (estado = 'PENDIENTE' AND evaluado_por IS NULL AND evaluada_en IS NULL) OR
    (estado <> 'PENDIENTE' AND evaluado_por IS NOT NULL AND evaluada_en IS NOT NULL AND
     evaluada_en >= solicitada_en AND comentario_revision IS NOT NULL AND
     CHAR_LENGTH(TRIM(comentario_revision)) > 0)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 13. TABLA: solicitud_dias (Atomicidad pura para goce continuo o fraccionado)
-- -----------------------------------------------------------------------------
CREATE TABLE solicitud_dias (
  solicitud_id BIGINT UNSIGNED NOT NULL,
  fecha DATE NOT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (solicitud_id, fecha),
  KEY ix_solicitud_dias_fecha (fecha),
  CONSTRAINT fk_solicitud_dias_solicitud FOREIGN KEY (solicitud_id)
    REFERENCES solicitudes_vacaciones (id) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 14. TABLA: feriados
-- -----------------------------------------------------------------------------
CREATE TABLE feriados (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  fecha DATE NOT NULL,
  motivo VARCHAR(120) NOT NULL,
  tipo ENUM('NACIONAL','CORPORATIVO') NOT NULL DEFAULT 'NACIONAL',
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_feriados_fecha (fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- VISTAS TRANSACCIONALES DINÁMICAS (CERO COLUMNAS CALCULADAS REDUNDANTES)
-- =============================================================================


ALTER TABLE colaboradores MODIFY dni CHAR(8) NULL, MODIFY fecha_ingreso DATE NULL;
ALTER TABLE usuarios ADD username VARCHAR(120) NULL UNIQUE, ADD debe_cambiar_clave BOOLEAN NOT NULL DEFAULT 1, ADD version_sesion INT NOT NULL DEFAULT 1;
ALTER TABLE periodos_vacacionales ADD usados_iniciales SMALLINT UNSIGNED NOT NULL DEFAULT 0, ADD confirmado BOOLEAN NOT NULL DEFAULT 0, ADD nota_origen TEXT NULL;
CREATE TABLE asignaciones_horario (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 colaborador_id BIGINT UNSIGNED NULL,
 alcance BIGINT UNSIGNED GENERATED ALWAYS AS (COALESCE(colaborador_id,0)) STORED,
 turno_id BIGINT UNSIGNED NOT NULL, desde DATE NOT NULL,
 dias_semana JSON NOT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_horario(alcance,desde),
 FOREIGN KEY(colaborador_id) REFERENCES colaboradores(id) ON DELETE RESTRICT,
 FOREIGN KEY(turno_id) REFERENCES turnos(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE excepciones_calendario (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, colaborador_id BIGINT UNSIGNED NULL,
 alcance BIGINT UNSIGNED GENERATED ALWAYS AS (COALESCE(colaborador_id,0)) STORED,
 fecha DATE NOT NULL, trabaja BOOLEAN NOT NULL, motivo VARCHAR(180) NOT NULL,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 UNIQUE KEY uq_excepcion(alcance,fecha), CHECK(trabaja IN(0,1)),
 FOREIGN KEY(colaborador_id) REFERENCES colaboradores(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE auditoria (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, usuario_id BIGINT UNSIGNED NULL,
 accion VARCHAR(80) NOT NULL, referencia VARCHAR(120) NOT NULL, detalle JSON NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE VIEW v_marcaciones AS
SELECT
  a.id AS asistencia_id,
  MAX(CASE WHEN e.tipo_evento = 'ENTRADA' THEN e.marca_tiempo END) AS entrada,
  MAX(CASE WHEN e.tipo_evento = 'SALIDA_REFRIGERIO' THEN e.marca_tiempo END) AS inicio_refrigerio,
  MAX(CASE WHEN e.tipo_evento = 'RETORNO_REFRIGERIO' THEN e.marca_tiempo END) AS fin_refrigerio,
  MAX(CASE WHEN e.tipo_evento = 'SALIDA' THEN e.marca_tiempo END) AS salida,
  COUNT(e.id) AS cantidad_marcas
FROM asistencias a
LEFT JOIN eventos_asistencia e ON e.asistencia_id = a.id
GROUP BY a.id;

-- Vista 2: Calificación de puntualidad, tardanzas en segundos y estado de jornada
CREATE VIEW v_asistencias_reporte AS
SELECT
  a.id,
  a.colaborador_id,
  a.turno_id,
  a.fecha,
  m.entrada,
  m.inicio_refrigerio,
  m.fin_refrigerio,
  m.salida,
  CASE
    WHEN EXISTS (
      SELECT 1 FROM solicitud_dias d
      JOIN solicitudes_vacaciones s ON s.id = d.solicitud_id
      JOIN periodos_vacacionales p ON p.id = s.periodo_id
      WHERE d.fecha = a.fecha AND s.estado = 'APROBADA' AND p.colaborador_id = a.colaborador_id
    ) THEN 'V'
    WHEN j.estado = 'APROBADA' THEN j.tipo
    WHEN m.entrada IS NOT NULL AND a.cerrada_en IS NOT NULL AND m.cantidad_marcas < 4 THEN 'INCOMPLETA'
    WHEN m.entrada > TIMESTAMP(a.fecha, t.hora_entrada) + INTERVAL t.tolerancia_min MINUTE THEN 'TARDANZA'
    WHEN m.entrada IS NOT NULL THEN 'PUNTUAL'
    WHEN a.requiere_marca = 0 THEN 'N'
    WHEN a.cerrada_en IS NULL THEN 'PENDIENTE'
    ELSE 'F'
  END AS estado_jornada,
  GREATEST(0, COALESCE(TIMESTAMPDIFF(SECOND, TIMESTAMP(a.fecha, t.hora_entrada) + INTERVAL t.tolerancia_min MINUTE, m.entrada), 0)) AS segundos_tardanza_brutos,
  CASE
    WHEN j.estado = 'APROBADA' OR a.requiere_marca = 0 THEN 0
    ELSE GREATEST(0, COALESCE(TIMESTAMPDIFF(SECOND, TIMESTAMP(a.fecha, t.hora_entrada) + INTERVAL t.tolerancia_min MINUTE, m.entrada), 0))
  END AS segundos_tardanza_computables,
  CASE
    WHEN m.cantidad_marcas = 4 AND m.entrada <= m.inicio_refrigerio AND
         m.inicio_refrigerio <= m.fin_refrigerio AND m.fin_refrigerio <= m.salida
    THEN TIMESTAMPDIFF(SECOND, m.entrada, m.inicio_refrigerio) + TIMESTAMPDIFF(SECOND, m.fin_refrigerio, m.salida)
    ELSE NULL
  END AS segundos_trabajados
FROM asistencias a
JOIN turnos t ON t.id = a.turno_id
JOIN v_marcaciones m ON m.asistencia_id = a.id
LEFT JOIN justificaciones j ON j.asistencia_id = a.id;

-- Vista 3: Resumen atómico de solicitudes de vacaciones
CREATE VIEW v_solicitudes_vacaciones AS
SELECT
  s.id,
  s.periodo_id,
  p.colaborador_id,
  s.solicitada_en,
  s.estado,
  s.evaluado_por,
  s.evaluada_en,
  s.comentario_revision,
  COUNT(d.fecha) AS dias_solicitados,
  MIN(d.fecha) AS fecha_desde,
  MAX(d.fecha) AS fecha_hasta
FROM solicitudes_vacaciones s
JOIN periodos_vacacionales p ON p.id = s.periodo_id
LEFT JOIN solicitud_dias d ON d.solicitud_id = s.id
GROUP BY s.id, s.periodo_id, p.colaborador_id, s.solicitada_en, s.estado, s.evaluado_por, s.evaluada_en, s.comentario_revision;


CREATE VIEW v_saldos_vacacionales AS
SELECT p.id periodo_id,p.colaborador_id,p.numero_periodo,p.fecha_inicio,p.fecha_fin,p.confirmado,p.dias_devengados,p.usados_iniciales,
 p.usados_iniciales+COALESCE(SUM(CASE WHEN s.estado='APROBADA' AND d.fecha<=CURRENT_DATE THEN 1 ELSE 0 END),0) dias_gozados,
 COALESCE(SUM(CASE WHEN s.estado='APROBADA' THEN 1 ELSE 0 END),0) dias_reservados,
 COALESCE(SUM(CASE WHEN s.estado='PENDIENTE' THEN 1 ELSE 0 END),0) dias_pendientes,
 CAST(p.dias_devengados AS SIGNED)-p.usados_iniciales-COALESCE(SUM(CASE WHEN s.estado='APROBADA' THEN 1 ELSE 0 END),0) saldo_disponible
FROM periodos_vacacionales p LEFT JOIN solicitudes_vacaciones s ON s.periodo_id=p.id
LEFT JOIN solicitud_dias d ON d.solicitud_id=s.id
GROUP BY p.id,p.colaborador_id,p.numero_periodo,p.fecha_inicio,p.fecha_fin,p.confirmado,p.dias_devengados,p.usados_iniciales;
CREATE TRIGGER tr_evento_no_editar BEFORE UPDATE ON eventos_asistencia FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las marcaciones originales no se editan';
CREATE TRIGGER tr_evento_no_borrar BEFORE DELETE ON eventos_asistencia FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las marcaciones originales no se eliminan';
CREATE TRIGGER tr_turno_inmutable BEFORE UPDATE ON turnos FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cree una nueva versión del horario';
