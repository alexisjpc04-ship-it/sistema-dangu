
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `areas` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_areas_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `areas` WRITE;
/*!40000 ALTER TABLE `areas` DISABLE KEYS */;
INSERT INTO `areas` VALUES (1,'PERSONAL DANGU','Área pendiente de clasificación','2026-10-21 05:28:12','2026-10-21 05:28:12');
/*!40000 ALTER TABLE `areas` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `asignaciones_horario` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `colaborador_id` bigint unsigned DEFAULT NULL,
  `alcance` bigint unsigned GENERATED ALWAYS AS (coalesce(`colaborador_id`,0)) STORED,
  `turno_id` bigint unsigned NOT NULL,
  `desde` date NOT NULL,
  `dias_semana` json NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_horario` (`alcance`,`desde`),
  KEY `colaborador_id` (`colaborador_id`),
  KEY `turno_id` (`turno_id`),
  CONSTRAINT `asignaciones_horario_ibfk_1` FOREIGN KEY (`colaborador_id`) REFERENCES `colaboradores` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `asignaciones_horario_ibfk_2` FOREIGN KEY (`turno_id`) REFERENCES `turnos` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `asignaciones_horario` WRITE;
/*!40000 ALTER TABLE `asignaciones_horario` DISABLE KEYS */;
INSERT INTO `asignaciones_horario` (`id`, `colaborador_id`, `turno_id`, `desde`, `dias_semana`, `created_at`, `updated_at`) VALUES (1,NULL,1,'2026-10-21','[1, 2, 3, 4, 5, 6]','2026-10-21 05:28:12','2026-10-21 05:28:12');
/*!40000 ALTER TABLE `asignaciones_horario` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `asistencias` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `colaborador_id` bigint unsigned NOT NULL,
  `turno_id` bigint unsigned NOT NULL,
  `fecha` date NOT NULL,
  `requiere_marca` tinyint(1) NOT NULL DEFAULT '1',
  `cerrada_en` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_asistencias_colab_fecha` (`colaborador_id`,`fecha`),
  KEY `ix_asistencias_fecha` (`fecha`),
  KEY `fk_asistencias_turno` (`turno_id`),
  CONSTRAINT `fk_asistencias_colaborador` FOREIGN KEY (`colaborador_id`) REFERENCES `colaboradores` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_asistencias_turno` FOREIGN KEY (`turno_id`) REFERENCES `turnos` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ck_asistencias_cierre` CHECK (((`cerrada_en` is null) or (cast(`cerrada_en` as date) >= `fecha`))),
  CONSTRAINT `ck_asistencias_marca` CHECK ((`requiere_marca` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `asistencias` WRITE;
/*!40000 ALTER TABLE `asistencias` DISABLE KEYS */;
INSERT INTO `asistencias` VALUES (1,1,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(2,2,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(3,3,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(4,4,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(5,5,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(6,6,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(7,7,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(8,8,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(9,9,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(10,10,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(11,11,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02'),(12,12,1,'2026-10-21',1,NULL,'2026-10-21 06:28:02','2026-10-21 06:28:02');
/*!40000 ALTER TABLE `asistencias` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned DEFAULT NULL,
  `accion` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `referencia` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `detalle` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `auditoria_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,1,'CAMBIO_CLAVE','1','[]','2026-10-21 06:28:02'),(2,1,'CONFIGURAR_DIA','2026-10-23','{\"tipo\": \"excepcion\"}','2026-10-21 06:32:26'),(3,NULL,'ACCESOS_SIMPLIFICADOS','12 CUENTAS','{\"motivo\": \"Solicitud explícita del titular: NOMBRE.APELLIDO y PIN temporal de cuatro dígitos\"}','2026-10-21 06:35:15');
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cargos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `area_id` bigint unsigned NOT NULL,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cargos_area_nombre` (`area_id`,`nombre`),
  CONSTRAINT `fk_cargos_area` FOREIGN KEY (`area_id`) REFERENCES `areas` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `cargos` WRITE;
/*!40000 ALTER TABLE `cargos` DISABLE KEYS */;
INSERT INTO `cargos` VALUES (1,1,'COLABORADOR',NULL,'2026-10-21 05:28:12','2026-10-21 05:28:12');
/*!40000 ALTER TABLE `cargos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `colaboradores` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `cargo_id` bigint unsigned NOT NULL,
  `turno_id` bigint unsigned NOT NULL,
  `dni` char(8) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `nombres` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo_contacto` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_ingreso` date DEFAULT NULL,
  `regimen` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REMYPE',
  `pin_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_colaboradores_dni` (`dni`),
  KEY `fk_colaboradores_cargo` (`cargo_id`),
  KEY `fk_colaboradores_turno` (`turno_id`),
  CONSTRAINT `fk_colaboradores_cargo` FOREIGN KEY (`cargo_id`) REFERENCES `cargos` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_colaboradores_turno` FOREIGN KEY (`turno_id`) REFERENCES `turnos` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ck_colaboradores_dni` CHECK (regexp_like(`dni`,_utf8mb4'^[0-9]{8}$')),
  CONSTRAINT `ck_colaboradores_pin` CHECK ((char_length(trim(`pin_hash`)) > 0))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `colaboradores` WRITE;
/*!40000 ALTER TABLE `colaboradores` DISABLE KEYS */;
INSERT INTO `colaboradores` VALUES (1,1,1,NULL,'ADMINISTRACIÓN DANGU','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$Kum2vIDEmXEzu2NMiWEuAeQpl3vvBnG6wZBwMYYhdGj2o6ym7cwqy',NULL,'2026-10-21 05:28:12','2026-10-21 05:28:12'),(2,1,1,NULL,'STEVEN GONZALES','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$CaS4tX1kQYJYs29d1s.3neKattGg/tzx81aKjo6TQ95s7iBWi4bOe',NULL,'2026-10-21 05:28:12','2026-10-21 05:28:12'),(3,1,1,NULL,'ALEXIS AVALOS','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$xPwryQP8gcKLH.DilQjI8OmMtq2aQYz.Hkm9vFC4DrYfAUKOyLpiu',NULL,'2026-10-21 05:28:13','2026-10-21 05:28:13'),(4,1,1,NULL,'VICTOR ROSARIO','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$MtNJX1uLPMdM4tLLdqWtKul.pa00wf1FGGGPaAKGsvjNClN4RFyXC',NULL,'2026-10-21 05:28:13','2026-10-21 05:28:13'),(5,1,1,NULL,'VICTORIA SOLEDAD ALZA','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$8YdTEfkGbqkbx84thijfTOs8GGJusv92mdflu/TaqlhHVL518kPEW',NULL,'2026-10-21 05:28:13','2026-10-21 05:28:13'),(6,1,1,NULL,'KARINA CINTHIA CASTILLO','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$jDsOHO.fR3s3s.2ckIV/Ne5CEBgKqR/lPCj2ehAWQ/QYMNGZS8nbe',NULL,'2026-10-21 05:28:14','2026-10-21 05:28:14'),(7,1,1,NULL,'ARACELY JANELY PEREZ','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$YZglCXbPIUioQ.un7lYXOOLtgvOEDvKo7wF201NcvVdgKD9kLKHWO',NULL,'2026-10-21 05:28:14','2026-10-21 05:28:14'),(8,1,1,NULL,'LIZ VALDEIVIESO','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$bm1NSEBILFRXBqa7DJsTEOUomMpmPBrNQEZ.XGUlxVi3M/mfJK952',NULL,'2026-10-21 05:28:15','2026-10-21 05:28:15'),(9,1,1,NULL,'FLOR MATILDE CORDOVA','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$q0uzKK9v7RSL1s0ZaFs6SOnUCqIdtW/mHQEp3SUVYwQSWabWsHAFS',NULL,'2026-10-21 05:28:15','2026-10-21 05:28:15'),(10,1,1,NULL,'JHAN CARLOS CABRERA','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$mqM5dbWA966PZpN6Cit/3u/JXYNg8pG2lH1H8HB2yjBSSXeOLaRFC',NULL,'2026-10-21 05:28:16','2026-10-21 05:28:16'),(11,1,1,NULL,'JOYCE KATHERINE PEÑA','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$nmaEP4Cu55bE5f9Ijl022eW1hjBRxniWBPVwf3ug0Bq5VwAhM73NO',NULL,'2026-10-21 05:28:16','2026-10-21 05:28:16'),(12,1,1,NULL,'MANUEL SANCHEZ','',NULL,NULL,NULL,'POR CONFIRMAR','$2y$12$NMb1mFtGRhBa2CudPRcPieG8CFdPvNtlEti9eHM9cyOZqAV9HxWzm',NULL,'2026-10-21 05:28:16','2026-10-21 05:28:16');
/*!40000 ALTER TABLE `colaboradores` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `eventos_asistencia` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `asistencia_id` bigint unsigned NOT NULL,
  `tipo_evento` enum('ENTRADA','SALIDA_REFRIGERIO','RETORNO_REFRIGERIO','SALIDA') COLLATE utf8mb4_unicode_ci NOT NULL,
  `marca_tiempo` datetime NOT NULL,
  `ip_origen` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dispositivo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_eventos_asistencia_tipo` (`asistencia_id`,`tipo_evento`),
  KEY `ix_eventos_marca_tiempo` (`marca_tiempo`),
  CONSTRAINT `fk_eventos_asistencia` FOREIGN KEY (`asistencia_id`) REFERENCES `asistencias` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `eventos_asistencia` WRITE;
/*!40000 ALTER TABLE `eventos_asistencia` DISABLE KEYS */;
/*!40000 ALTER TABLE `eventos_asistencia` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `tr_evento_no_editar` BEFORE UPDATE ON `eventos_asistencia` FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las marcaciones originales no se editan' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `tr_evento_no_borrar` BEFORE DELETE ON `eventos_asistencia` FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Las marcaciones originales no se eliminan' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `excepciones_calendario` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `colaborador_id` bigint unsigned DEFAULT NULL,
  `alcance` bigint unsigned GENERATED ALWAYS AS (coalesce(`colaborador_id`,0)) STORED,
  `fecha` date NOT NULL,
  `trabaja` tinyint(1) NOT NULL,
  `motivo` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_excepcion` (`alcance`,`fecha`),
  KEY `colaborador_id` (`colaborador_id`),
  CONSTRAINT `excepciones_calendario_ibfk_1` FOREIGN KEY (`colaborador_id`) REFERENCES `colaboradores` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `excepciones_calendario_chk_1` CHECK ((`trabaja` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `excepciones_calendario` WRITE;
/*!40000 ALTER TABLE `excepciones_calendario` DISABLE KEYS */;
INSERT INTO `excepciones_calendario` (`id`, `colaborador_id`, `fecha`, `trabaja`, `motivo`, `created_at`, `updated_at`) VALUES (1,NULL,'2026-10-23',0,'ANIVERSARIO','2026-10-21 06:32:26','2026-10-21 06:32:26');
/*!40000 ALTER TABLE `excepciones_calendario` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feriados` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `fecha` date NOT NULL,
  `motivo` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo` enum('NACIONAL','CORPORATIVO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NACIONAL',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_feriados_fecha` (`fecha`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `feriados` WRITE;
/*!40000 ALTER TABLE `feriados` DISABLE KEYS */;
INSERT INTO `feriados` VALUES (1,'2026-01-01','AÑO NUEVO','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(2,'2026-04-02','SEMANA SANTA — JUEVES','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(3,'2026-04-03','SEMANA SANTA — VIERNES','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(4,'2026-05-01','DÍA DEL TRABAJADOR','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(5,'2026-06-29','SAN PEDRO Y SAN PABLO','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(6,'2026-07-28','FIESTAS PATRIAS','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(7,'2026-07-29','FIESTAS PATRIAS','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(8,'2026-08-30','SANTA ROSA DE LIMA','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(9,'2026-10-08','COMBATE DE ANGAMOS','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(10,'2026-11-01','TODOS LOS SANTOS','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(11,'2026-12-08','INMACULADA CONCEPCIÓN','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17'),(12,'2026-12-25','NAVIDAD','CORPORATIVO','2026-10-21 05:28:17','2026-10-21 05:28:17');
/*!40000 ALTER TABLE `feriados` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `justificaciones` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `asistencia_id` bigint unsigned NOT NULL,
  `tipo` enum('S','P') COLLATE utf8mb4_unicode_ci NOT NULL,
  `motivo` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruta_adjunto` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `solicitada_en` datetime NOT NULL,
  `estado` enum('PENDIENTE','APROBADA','RECHAZADA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `evaluado_por` bigint unsigned DEFAULT NULL,
  `evaluada_en` datetime DEFAULT NULL,
  `comentario_revision` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_justificaciones_asistencia` (`asistencia_id`),
  KEY `ix_justificaciones_estado_fecha` (`estado`,`solicitada_en`),
  KEY `fk_justificaciones_evaluador` (`evaluado_por`),
  CONSTRAINT `fk_justificaciones_asistencia` FOREIGN KEY (`asistencia_id`) REFERENCES `asistencias` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_justificaciones_evaluador` FOREIGN KEY (`evaluado_por`) REFERENCES `usuarios` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ck_justificaciones_adjunto` CHECK (((`tipo` <> _utf8mb4'S') or ((`ruta_adjunto` is not null) and (char_length(trim(`ruta_adjunto`)) > 0)))),
  CONSTRAINT `ck_justificaciones_resolucion` CHECK ((((`estado` = _utf8mb4'PENDIENTE') and (`evaluado_por` is null) and (`evaluada_en` is null)) or ((`estado` <> _utf8mb4'PENDIENTE') and (`evaluado_por` is not null) and (`evaluada_en` is not null) and (`evaluada_en` >= `solicitada_en`) and (`comentario_revision` is not null) and (char_length(trim(`comentario_revision`)) > 0))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `justificaciones` WRITE;
/*!40000 ALTER TABLE `justificaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `justificaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `periodos_vacacionales` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `colaborador_id` bigint unsigned NOT NULL,
  `numero_periodo` smallint unsigned NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `dias_devengados` smallint unsigned NOT NULL DEFAULT '15',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `usados_iniciales` smallint unsigned NOT NULL DEFAULT '0',
  `confirmado` tinyint(1) NOT NULL DEFAULT '0',
  `nota_origen` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_periodos_colab_num` (`colaborador_id`,`numero_periodo`),
  UNIQUE KEY `uk_periodos_colab_ini` (`colaborador_id`,`fecha_inicio`),
  CONSTRAINT `fk_periodos_colaborador` FOREIGN KEY (`colaborador_id`) REFERENCES `colaboradores` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ck_periodos_dias` CHECK ((`dias_devengados` between 1 and 366)),
  CONSTRAINT `ck_periodos_fechas` CHECK ((`fecha_fin` >= `fecha_inicio`)),
  CONSTRAINT `ck_periodos_numero` CHECK ((`numero_periodo` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `periodos_vacacionales` WRITE;
/*!40000 ALTER TABLE `periodos_vacacionales` DISABLE KEYS */;
INSERT INTO `periodos_vacacionales` VALUES (1,2,1,'2025-01-01','2026-01-01',15,'2026-10-21 05:28:12','2026-10-21 05:28:12',13,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación. 19, 22, 23 , 24  y 31 (1 dia) diciembre  , 02 al 04 enero (1 domingo), 9,10,11 enero, 17,24 y 31 enero | Pendiente indicado: 2 dias  | Programación: '),(2,3,1,'2025-04-14','2026-04-14',15,'2026-10-21 05:28:13','2026-10-21 05:28:13',7,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación. 12 agosto, (29,30,31,2,3,4 enero)  -> 7 dias | Pendiente indicado: 8 dias  (2 domingos + 6 laborabñles) | Programación: Pidio el 27 de julio permiso'),(3,4,1,'2025-03-01','2026-03-01',14,'2026-10-21 05:28:13','2026-10-21 05:28:13',1,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación. 02 de julio, 06 agosto. 28 , 29 agosto, (24,31), 26,27,28,29,30,  (02,03,04,05  enero 2026)---> 14 dias | Pendiente indicado: 1 dia laborable | Programación: '),(4,5,1,'2025-07-14','2026-07-14',15,'2026-10-21 05:28:14','2026-10-21 05:28:14',9,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación. 22,23,24 DIC, (8,9,10,11,12 abaril ), 8 mayo - Sus  3 dias canje domingo trabajados :(4, 6 ,7  abril) | Pendiente indicado: 5 dias laborables y 1 domingo | Programación: '),(5,6,1,'2025-11-01','2026-11-01',15,'2026-10-21 05:28:14','2026-10-21 05:28:14',1,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación. 2 dickembre | Pendiente indicado: 12 dias laborables, 2 domingos | Programación: '),(6,7,1,'2026-01-01','2026-12-31',15,'2026-10-21 05:28:15','2026-10-21 05:28:15',0,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación.  | Pendiente indicado: 15 dias  | Programación: '),(7,8,1,'2026-04-16','2027-04-16',15,'2026-10-21 05:28:15','2026-10-21 05:28:15',0,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación.  | Pendiente indicado: 15 dias  | Programación: 25 y 25 julio(motivo cumpleaños)'),(8,9,1,'2026-04-10','2027-04-10',15,'2026-10-21 05:28:15','2026-10-21 05:28:15',0,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación.  | Pendiente indicado: 15 dias  | Programación: '),(9,10,1,'2026-05-16','2027-05-16',15,'2026-10-21 05:28:16','2026-10-21 05:28:16',0,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación.  | Pendiente indicado: 15 dias  | Programación: Pidio permiso 27 Julio(Motivo presentacion tesis)'),(10,11,1,'2026-06-06','2027-06-06',15,'2026-10-21 05:28:16','2026-10-21 05:28:16',0,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación.  | Pendiente indicado: 15 dias  | Programación: '),(11,12,1,'2026-05-01','2027-04-30',8,'2026-10-21 05:28:17','2026-10-21 05:28:17',0,0,'Excel Reporte. Fecha del encabezado: julio de 2027; requiere conciliación.  | Pendiente indicado: 15 dias  | Programación: ');
/*!40000 ALTER TABLE `periodos_vacacionales` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_roles_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN_RRHH','Administración completa','2026-10-21 05:28:12','2026-10-21 05:28:12'),(2,'COLABORADOR','Solo información propia','2026-10-21 05:28:12','2026-10-21 05:28:12');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitud_dias` (
  `solicitud_id` bigint unsigned NOT NULL,
  `fecha` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`solicitud_id`,`fecha`),
  KEY `ix_solicitud_dias_fecha` (`fecha`),
  CONSTRAINT `fk_solicitud_dias_solicitud` FOREIGN KEY (`solicitud_id`) REFERENCES `solicitudes_vacaciones` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `solicitud_dias` WRITE;
/*!40000 ALTER TABLE `solicitud_dias` DISABLE KEYS */;
/*!40000 ALTER TABLE `solicitud_dias` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solicitudes_vacaciones` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `periodo_id` bigint unsigned NOT NULL,
  `solicitada_en` datetime NOT NULL,
  `estado` enum('PENDIENTE','APROBADA','RECHAZADA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `evaluado_por` bigint unsigned DEFAULT NULL,
  `evaluada_en` datetime DEFAULT NULL,
  `comentario_revision` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ix_solicitudes_periodo` (`periodo_id`),
  KEY `ix_solicitudes_estado` (`estado`,`solicitada_en`),
  KEY `fk_solicitudes_evaluador` (`evaluado_por`),
  CONSTRAINT `fk_solicitudes_evaluador` FOREIGN KEY (`evaluado_por`) REFERENCES `usuarios` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_solicitudes_periodo` FOREIGN KEY (`periodo_id`) REFERENCES `periodos_vacacionales` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ck_solicitudes_resolucion` CHECK ((((`estado` = _utf8mb4'PENDIENTE') and (`evaluado_por` is null) and (`evaluada_en` is null)) or ((`estado` <> _utf8mb4'PENDIENTE') and (`evaluado_por` is not null) and (`evaluada_en` is not null) and (`evaluada_en` >= `solicitada_en`) and (`comentario_revision` is not null) and (char_length(trim(`comentario_revision`)) > 0))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `solicitudes_vacaciones` WRITE;
/*!40000 ALTER TABLE `solicitudes_vacaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `solicitudes_vacaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `turnos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `hora_entrada` time NOT NULL,
  `inicio_refrigerio` time NOT NULL,
  `fin_refrigerio` time NOT NULL,
  `hora_salida` time NOT NULL,
  `tolerancia_min` tinyint unsigned NOT NULL DEFAULT '10',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_turnos_nombre` (`nombre`),
  CONSTRAINT `ck_turnos_coherencia` CHECK (((`hora_entrada` >= _utf8mb4'00:00:00') and (`hora_salida` < _utf8mb4'24:00:00') and (`hora_entrada` < `inicio_refrigerio`) and (`inicio_refrigerio` < `fin_refrigerio`) and (`fin_refrigerio` < `hora_salida`))),
  CONSTRAINT `ck_turnos_tolerancia` CHECK ((`tolerancia_min` <= 60))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `turnos` WRITE;
/*!40000 ALTER TABLE `turnos` DISABLE KEYS */;
INSERT INTO `turnos` VALUES (1,'HORARIO INICIAL POR CONFIRMAR','08:00:00','13:00:00','14:00:00','18:00:00',10,'2026-10-21 05:28:12','2026-10-21 05:28:12');
/*!40000 ALTER TABLE `turnos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `tr_turno_inmutable` BEFORE UPDATE ON `turnos` FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Cree una nueva versión del horario' */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_rol` (
  `usuario_id` bigint unsigned NOT NULL,
  `rol_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`,`rol_id`),
  KEY `fk_ur_rol` (`rol_id`),
  CONSTRAINT `fk_ur_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_ur_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `usuario_rol` WRITE;
/*!40000 ALTER TABLE `usuario_rol` DISABLE KEYS */;
INSERT INTO `usuario_rol` VALUES (1,1,'2026-10-21 05:28:12','2026-10-21 05:28:12'),(2,2,'2026-10-21 05:28:12','2026-10-21 05:28:12'),(3,2,'2026-10-21 05:28:13','2026-10-21 05:28:13'),(4,2,'2026-10-21 05:28:13','2026-10-21 05:28:13'),(5,2,'2026-10-21 05:28:14','2026-10-21 05:28:14'),(6,2,'2026-10-21 05:28:14','2026-10-21 05:28:14'),(7,2,'2026-10-21 05:28:15','2026-10-21 05:28:15'),(8,2,'2026-10-21 05:28:15','2026-10-21 05:28:15'),(9,2,'2026-10-21 05:28:15','2026-10-21 05:28:15'),(10,2,'2026-10-21 05:28:16','2026-10-21 05:28:16'),(11,2,'2026-10-21 05:28:16','2026-10-21 05:28:16'),(12,2,'2026-10-21 05:28:17','2026-10-21 05:28:17');
/*!40000 ALTER TABLE `usuario_rol` ENABLE KEYS */;
UNLOCK TABLES;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `colaborador_id` bigint unsigned NOT NULL,
  `email` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `username` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `debe_cambiar_clave` tinyint(1) NOT NULL DEFAULT '1',
  `version_sesion` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_usuarios_colaborador` (`colaborador_id`),
  UNIQUE KEY `uk_usuarios_email` (`email`),
  UNIQUE KEY `username` (`username`),
  CONSTRAINT `fk_usuarios_colaborador` FOREIGN KEY (`colaborador_id`) REFERENCES `colaboradores` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ck_usuarios_activo` CHECK ((`activo` in (0,1)))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,1,'cuenta1@dangu.invalid','$2y$12$.g0u5Rl.VSHWLjIGNP1L1.OOCaFCVNIeC/Pb2RhsGGz483qLQGOIq',1,NULL,'2026-10-21 05:28:12','2026-10-21 06:35:13','ADMIN.DANGU',1,3),(2,2,'cuenta2@dangu.invalid','$2y$12$JYvXEZgAZ2dW0MoVFz68suwpmyUy/n2PsJElzd4A6ILmQtR6QKxE.',1,NULL,'2026-10-21 05:28:12','2026-10-21 06:35:13','STEVEN.GONZALES',1,2),(3,3,'cuenta3@dangu.invalid','$2y$12$qZdu9GlCXYxMXAryXIvde.Bef4atUWBg4zOk/bxPGspd7r3ktmmWG',1,NULL,'2026-10-21 05:28:13','2026-10-21 06:35:14','ALEXIS.AVALOS',1,2),(4,4,'cuenta4@dangu.invalid','$2y$12$Q/IzRAN06U33a69JTB0usuxSPSiY2nWxjc170Ygw8fouGmhO0DCDq',1,NULL,'2026-10-21 05:28:13','2026-10-21 06:35:14','VICTOR.ROSARIO',1,2),(5,5,'cuenta5@dangu.invalid','$2y$12$VeATQi9lljU.nildWCPaUO4XYINWsZDlNI3/q3L2OkWoIrksxMoEq',1,NULL,'2026-10-21 05:28:14','2026-10-21 06:35:14','VICTORIA.ALZA',1,2),(6,6,'cuenta6@dangu.invalid','$2y$12$vZoVQ1Awz1r.twwOicY5neivmeN8/zpoFcaCHHm2nrc23NFakolQq',1,NULL,'2026-10-21 05:28:14','2026-10-21 06:35:14','KARINA.CASTILLO',1,2),(7,7,'cuenta7@dangu.invalid','$2y$12$PT19JqGe2Mgi2n3WxxI1L.5rNu6t/A.wd0jlns6ThZE7bqQlt5EZS',1,NULL,'2026-10-21 05:28:15','2026-10-21 06:35:14','ARACELY.PEREZ',1,2),(8,8,'cuenta8@dangu.invalid','$2y$12$BtYkjCuvrfOWA1VfB68P6OK9X/RDEBKR4FgQ6sNc0e7OSo44lrYN.',1,NULL,'2026-10-21 05:28:15','2026-10-21 06:35:15','LIZ.VALDEIVIESO',1,2),(9,9,'cuenta9@dangu.invalid','$2y$12$8T3rsrszURPK8Fo0KD28sOZmQ.olfbMfk8wn27Gzvlu/Q6VXBJkji',1,NULL,'2026-10-21 05:28:15','2026-10-21 06:35:15','FLOR.CORDOVA',1,2),(10,10,'cuenta10@dangu.invalid','$2y$12$UfrF5zC9x9d6GeERk2CPyO3OQet.S0s2qnDOOrU.9xqK1FMIAIPWa',1,NULL,'2026-10-21 05:28:16','2026-10-21 06:35:15','JHAN.CABRERA',1,2),(11,11,'cuenta11@dangu.invalid','$2y$12$UdWCmZeVqdY4sHVZnIzvdOlosF8iV9l2KzxThRbx7K37FjNdRebdu',1,NULL,'2026-10-21 05:28:16','2026-10-21 06:35:15','JOYCE.PEÑA',1,2),(12,12,'cuenta12@dangu.invalid','$2y$12$khQCUXigozezC5ONhRCvv.AoM5XzJnwSM96Dlbsi0n9I7CuN/wGeq',1,NULL,'2026-10-21 05:28:17','2026-10-21 06:35:15','MANUEL.SANCHEZ',1,2);
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_asistencias_reporte` AS SELECT 
 1 AS `id`,
 1 AS `colaborador_id`,
 1 AS `turno_id`,
 1 AS `fecha`,
 1 AS `entrada`,
 1 AS `inicio_refrigerio`,
 1 AS `fin_refrigerio`,
 1 AS `salida`,
 1 AS `estado_jornada`,
 1 AS `segundos_tardanza_brutos`,
 1 AS `segundos_tardanza_computables`,
 1 AS `segundos_trabajados`*/;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_marcaciones` AS SELECT 
 1 AS `asistencia_id`,
 1 AS `entrada`,
 1 AS `inicio_refrigerio`,
 1 AS `fin_refrigerio`,
 1 AS `salida`,
 1 AS `cantidad_marcas`*/;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_saldos_vacacionales` AS SELECT 
 1 AS `periodo_id`,
 1 AS `colaborador_id`,
 1 AS `numero_periodo`,
 1 AS `fecha_inicio`,
 1 AS `fecha_fin`,
 1 AS `confirmado`,
 1 AS `dias_devengados`,
 1 AS `usados_iniciales`,
 1 AS `dias_gozados`,
 1 AS `dias_reservados`,
 1 AS `dias_pendientes`,
 1 AS `saldo_disponible`*/;
SET character_set_client = @saved_cs_client;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_solicitudes_vacaciones` AS SELECT 
 1 AS `id`,
 1 AS `periodo_id`,
 1 AS `colaborador_id`,
 1 AS `solicitada_en`,
 1 AS `estado`,
 1 AS `evaluado_por`,
 1 AS `evaluada_en`,
 1 AS `comentario_revision`,
 1 AS `dias_solicitados`,
 1 AS `fecha_desde`,
 1 AS `fecha_hasta`*/;
SET character_set_client = @saved_cs_client;
/*!50001 DROP VIEW IF EXISTS `v_asistencias_reporte`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_asistencias_reporte` AS select `a`.`id` AS `id`,`a`.`colaborador_id` AS `colaborador_id`,`a`.`turno_id` AS `turno_id`,`a`.`fecha` AS `fecha`,`m`.`entrada` AS `entrada`,`m`.`inicio_refrigerio` AS `inicio_refrigerio`,`m`.`fin_refrigerio` AS `fin_refrigerio`,`m`.`salida` AS `salida`,(case when exists(select 1 from ((`solicitud_dias` `d` join `solicitudes_vacaciones` `s` on((`s`.`id` = `d`.`solicitud_id`))) join `periodos_vacacionales` `p` on((`p`.`id` = `s`.`periodo_id`))) where ((`d`.`fecha` = `a`.`fecha`) and (`s`.`estado` = 'APROBADA') and (`p`.`colaborador_id` = `a`.`colaborador_id`))) then 'V' when (`j`.`estado` = 'APROBADA') then `j`.`tipo` when ((`m`.`entrada` is not null) and (`a`.`cerrada_en` is not null) and (`m`.`cantidad_marcas` < 4)) then 'INCOMPLETA' when (`m`.`entrada` > (timestamp(`a`.`fecha`,`t`.`hora_entrada`) + interval `t`.`tolerancia_min` minute)) then 'TARDANZA' when (`m`.`entrada` is not null) then 'PUNTUAL' when (`a`.`requiere_marca` = 0) then 'N' when (`a`.`cerrada_en` is null) then 'PENDIENTE' else 'F' end) AS `estado_jornada`,greatest(0,coalesce(timestampdiff(SECOND,(timestamp(`a`.`fecha`,`t`.`hora_entrada`) + interval `t`.`tolerancia_min` minute),`m`.`entrada`),0)) AS `segundos_tardanza_brutos`,(case when ((`j`.`estado` = 'APROBADA') or (`a`.`requiere_marca` = 0)) then 0 else greatest(0,coalesce(timestampdiff(SECOND,(timestamp(`a`.`fecha`,`t`.`hora_entrada`) + interval `t`.`tolerancia_min` minute),`m`.`entrada`),0)) end) AS `segundos_tardanza_computables`,(case when ((`m`.`cantidad_marcas` = 4) and (`m`.`entrada` <= `m`.`inicio_refrigerio`) and (`m`.`inicio_refrigerio` <= `m`.`fin_refrigerio`) and (`m`.`fin_refrigerio` <= `m`.`salida`)) then (timestampdiff(SECOND,`m`.`entrada`,`m`.`inicio_refrigerio`) + timestampdiff(SECOND,`m`.`fin_refrigerio`,`m`.`salida`)) else NULL end) AS `segundos_trabajados` from (((`asistencias` `a` join `turnos` `t` on((`t`.`id` = `a`.`turno_id`))) join `v_marcaciones` `m` on((`m`.`asistencia_id` = `a`.`id`))) left join `justificaciones` `j` on((`j`.`asistencia_id` = `a`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_marcaciones`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_marcaciones` AS select `a`.`id` AS `asistencia_id`,max((case when (`e`.`tipo_evento` = 'ENTRADA') then `e`.`marca_tiempo` end)) AS `entrada`,max((case when (`e`.`tipo_evento` = 'SALIDA_REFRIGERIO') then `e`.`marca_tiempo` end)) AS `inicio_refrigerio`,max((case when (`e`.`tipo_evento` = 'RETORNO_REFRIGERIO') then `e`.`marca_tiempo` end)) AS `fin_refrigerio`,max((case when (`e`.`tipo_evento` = 'SALIDA') then `e`.`marca_tiempo` end)) AS `salida`,count(`e`.`id`) AS `cantidad_marcas` from (`asistencias` `a` left join `eventos_asistencia` `e` on((`e`.`asistencia_id` = `a`.`id`))) group by `a`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_saldos_vacacionales`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_saldos_vacacionales` AS select `p`.`id` AS `periodo_id`,`p`.`colaborador_id` AS `colaborador_id`,`p`.`numero_periodo` AS `numero_periodo`,`p`.`fecha_inicio` AS `fecha_inicio`,`p`.`fecha_fin` AS `fecha_fin`,`p`.`confirmado` AS `confirmado`,`p`.`dias_devengados` AS `dias_devengados`,`p`.`usados_iniciales` AS `usados_iniciales`,(`p`.`usados_iniciales` + coalesce(sum((case when ((`s`.`estado` = 'APROBADA') and (`d`.`fecha` <= curdate())) then 1 else 0 end)),0)) AS `dias_gozados`,coalesce(sum((case when (`s`.`estado` = 'APROBADA') then 1 else 0 end)),0) AS `dias_reservados`,coalesce(sum((case when (`s`.`estado` = 'PENDIENTE') then 1 else 0 end)),0) AS `dias_pendientes`,((cast(`p`.`dias_devengados` as signed) - `p`.`usados_iniciales`) - coalesce(sum((case when (`s`.`estado` = 'APROBADA') then 1 else 0 end)),0)) AS `saldo_disponible` from ((`periodos_vacacionales` `p` left join `solicitudes_vacaciones` `s` on((`s`.`periodo_id` = `p`.`id`))) left join `solicitud_dias` `d` on((`d`.`solicitud_id` = `s`.`id`))) group by `p`.`id`,`p`.`colaborador_id`,`p`.`numero_periodo`,`p`.`fecha_inicio`,`p`.`fecha_fin`,`p`.`confirmado`,`p`.`dias_devengados`,`p`.`usados_iniciales` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_solicitudes_vacaciones`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_solicitudes_vacaciones` AS select `s`.`id` AS `id`,`s`.`periodo_id` AS `periodo_id`,`p`.`colaborador_id` AS `colaborador_id`,`s`.`solicitada_en` AS `solicitada_en`,`s`.`estado` AS `estado`,`s`.`evaluado_por` AS `evaluado_por`,`s`.`evaluada_en` AS `evaluada_en`,`s`.`comentario_revision` AS `comentario_revision`,count(`d`.`fecha`) AS `dias_solicitados`,min(`d`.`fecha`) AS `fecha_desde`,max(`d`.`fecha`) AS `fecha_hasta` from ((`solicitudes_vacaciones` `s` join `periodos_vacacionales` `p` on((`p`.`id` = `s`.`periodo_id`))) left join `solicitud_dias` `d` on((`d`.`solicitud_id` = `s`.`id`))) group by `s`.`id`,`s`.`periodo_id`,`p`.`colaborador_id`,`s`.`solicitada_en`,`s`.`estado`,`s`.`evaluado_por`,`s`.`evaluada_en`,`s`.`comentario_revision` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

