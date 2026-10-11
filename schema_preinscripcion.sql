-- ==============================================================================
-- SISTEMA DE GESTIÓN DE PREINSCRIPCIONES - U.E. FE Y ALEGRÍA "NUEVA AMÉRICA"
-- Nivel Educativo: Educación Primaria (1er Grado a 6to Grado)
-- Periodo Escolar: 2026 - 2027
-- Motor de Base de Datos: MySQL 8.0+ / MariaDB 10.5+
-- Basado en el Modelo Entidad-Relación:
--   - InstAuto (institutos / planteles de procedencia)
--   - Representante (datos del tutor/padre)
--   - Alumno (datos del aspirante)
--   - Pre-Inscripcion (registro principal de la solicitud)
--   - R_P_D (Relación Preinscripción - Documento)
--   - Documentos (Catálogo de requisitos/documentos)
--   - Grado (1er a 6to Grado de Primaria)
--   - Periodo_Ac (Periodo Escolar 2026-2027)
--   - R_G_Periodo (oferta de grados por periodo académico)
--   - Usuarios (id_user: control de auditoría / cuentas de usuario)
-- ==============================================================================

DROP DATABASE IF EXISTS sistema_preinscripcion;
CREATE DATABASE sistema_preinscripcion
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_preinscripcion;

-- ==============================================================================
-- 1. TABLA: usuarios (Resuelve 'id_user' en Pre-Inscripcion)
-- ==============================================================================
CREATE TABLE usuarios (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    correo VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol ENUM('ADMINISTRADOR', 'CONTROL_ESTUDIOS', 'SECRETARIA', 'REPRESENTANTE') NOT NULL DEFAULT 'REPRESENTANTE',
    estado ENUM('ACTIVO', 'INACTIVO', 'BLOQUEADO') NOT NULL DEFAULT 'ACTIVO',
    ultimo_acceso DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==============================================================================
-- 2. TABLA: institutos (Representa 'InstAuto' en el diagrama)
-- Escuela, preescolar o instituto de procedencia del aspirante
-- ==============================================================================
CREATE TABLE institutos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo_plantel VARCHAR(30) NULL UNIQUE COMMENT 'Código DEA o registro oficial',
    nombre VARCHAR(150) NOT NULL,
    tipo_institucion ENUM('PUBLICA', 'PRIVADA', 'SUBVENCIONADA_FE_Y_ALEGRIA', 'OTRA') NOT NULL DEFAULT 'PUBLICA',
    telefono VARCHAR(25) NULL,
    correo VARCHAR(120) NULL,
    direccion TEXT NULL,
    ciudad VARCHAR(80) NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_instituto_nombre (nombre)
) ENGINE=InnoDB;

-- ==============================================================================
-- 3. TABLA: representantes (Representa 'Representante' en el diagrama)
-- ==============================================================================
CREATE TABLE representantes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT UNSIGNED NULL,
    tipo_documento ENUM('V', 'E', 'P', 'DNI', 'CI') NOT NULL DEFAULT 'V',
    numero_identificacion VARCHAR(25) NOT NULL UNIQUE COMMENT 'Cédula o DNI',
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    parentesco ENUM('PADRE', 'MADRE', 'TUTOR_LEGAL', 'ABUELO_A', 'TIO_A', 'OTRO') NOT NULL DEFAULT 'PADRE',
    telefono_principal VARCHAR(25) NOT NULL,
    telefono_secundario VARCHAR(25) NULL,
    correo VARCHAR(120) NULL,
    profesion_ocupacion VARCHAR(100) NULL,
    lugar_trabajo VARCHAR(150) NULL,
    direccion_habitacion TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_repre_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_repre_identificacion (numero_identificacion),
    INDEX idx_repre_nombres (apellidos, nombres)
) ENGINE=InnoDB;

-- ==============================================================================
-- 4. TABLA: alumnos (Representa 'Alumno' en el diagrama)
-- ==============================================================================
CREATE TABLE alumnos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tipo_documento ENUM('V', 'E', 'P', 'CE', 'CI') NOT NULL DEFAULT 'CE' COMMENT 'CE = Cédula Escolar',
    numero_identificacion VARCHAR(25) NOT NULL UNIQUE,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero ENUM('MASCULINO', 'FEMENINO', 'OTRO') NOT NULL,
    lugar_nacimiento VARCHAR(120) NULL,
    direccion_habitacion TEXT NOT NULL,
    tipo_sangre VARCHAR(5) NULL,
    alergias_condiciones TEXT NULL,
    vive_con ENUM('AMBOS_PADRES', 'MADRE', 'PADRE', 'TUTOR', 'OTRO') NOT NULL DEFAULT 'AMBOS_PADRES',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_alumno_identificacion (numero_identificacion),
    INDEX idx_alumno_nombres (apellidos, nombres)
) ENGINE=InnoDB;

-- ==============================================================================
-- 5. TABLA: grados (Representa 'Grado' - Exclusivo Primaria 1° a 6°)
-- ==============================================================================
CREATE TABLE grados (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    nivel_educativo ENUM('PRIMARIA') NOT NULL DEFAULT 'PRIMARIA',
    orden_jerarquico TINYINT UNSIGNED NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- ==============================================================================
-- 6. TABLA: periodos_academicos (Representa 'Periodo_Ac' - 2026-2027)
-- ==============================================================================
CREATE TABLE periodos_academicos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(25) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('PLANIFICACION', 'PREINSCRIPCION_ABIERTA', 'CURSO_ACTIVO', 'CERRADO') NOT NULL DEFAULT 'PREINSCRIPCION_ABIERTA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==============================================================================
-- 7. TABLA: grado_periodos (Representa 'R_G_Periodo' en el diagrama)
-- Relación Grado - Periodo Académico
-- ==============================================================================
CREATE TABLE grado_periodos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_grado INT UNSIGNED NOT NULL,
    id_periodo INT UNSIGNED NOT NULL,
    estado ENUM('DISPONIBLE', 'CERRADO') NOT NULL DEFAULT 'DISPONIBLE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_gp_grado FOREIGN KEY (id_grado) 
        REFERENCES grados (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_gp_periodo FOREIGN KEY (id_periodo) 
        REFERENCES periodos_academicos (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_grado_periodo UNIQUE (id_grado, id_periodo)
) ENGINE=InnoDB;

-- ==============================================================================
-- 8. TABLA: documentos (Catálogo de requisitos)
-- ==============================================================================
CREATE TABLE documentos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    es_obligatorio BOOLEAN NOT NULL DEFAULT TRUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- ==============================================================================
-- 9. TABLA: preinscripciones (Representa 'Pre-Inscripcion' en el diagrama)
-- Claves foráneas: id_repre, id_alumno, id_instituto, id_g_periodo, id_user
-- ==============================================================================
CREATE TABLE preinscripciones (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo_solicitud VARCHAR(30) NOT NULL UNIQUE COMMENT 'Ej: PRE-2026-0001',
    id_repre INT UNSIGNED NOT NULL,
    id_alumno INT UNSIGNED NOT NULL,
    id_instituto INT UNSIGNED NULL,
    id_g_periodo INT UNSIGNED NOT NULL,
    id_user INT UNSIGNED NOT NULL,
    fecha_solicitud DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado ENUM(
        'PENDIENTE',
        'DOCUMENTOS_INCOMPLETOS',
        'EN_REVISION',
        'APROBADA',
        'LISTA_DE_ESPERA',
        'RECHAZADA',
        'INSCRITO'
    ) NOT NULL DEFAULT 'PENDIENTE',
    motivo_rechazo TEXT NULL,
    observaciones TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_pre_representante FOREIGN KEY (id_repre) 
        REFERENCES representantes (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pre_alumno FOREIGN KEY (id_alumno) 
        REFERENCES alumnos (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pre_instituto FOREIGN KEY (id_instituto) 
        REFERENCES institutos (id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pre_grado_periodo FOREIGN KEY (id_g_periodo) 
        REFERENCES grado_periodos (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pre_usuario FOREIGN KEY (id_user) 
        REFERENCES usuarios (id) ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT uk_alumno_oferta UNIQUE (id_alumno, id_g_periodo),
    INDEX idx_pre_estado (estado),
    INDEX idx_pre_fecha (fecha_solicitud)
) ENGINE=InnoDB;

-- ==============================================================================
-- 10. TABLA: preinscripcion_documentos (Representa 'R_P_D' en el diagrama)
-- ==============================================================================
CREATE TABLE preinscripcion_documentos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_pre INT UNSIGNED NOT NULL,
    id_documento INT UNSIGNED NOT NULL,
    ruta_archivo VARCHAR(255) NULL,
    estado ENUM('NO_CONSIGNADO', 'CONSIGNADO', 'APROBADO', 'OBSERVADO', 'RECHAZADO') NOT NULL DEFAULT 'NO_CONSIGNADO',
    fecha_entrega DATETIME NULL,
    observaciones VARCHAR(255) NULL,
    revisado_por INT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_rpd_preinscripcion FOREIGN KEY (id_pre) 
        REFERENCES preinscripciones (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rpd_documento FOREIGN KEY (id_documento) 
        REFERENCES documentos (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rpd_revisor FOREIGN KEY (revisado_por) 
        REFERENCES usuarios (id) ON DELETE SET NULL ON UPDATE CASCADE,
    
    CONSTRAINT uk_pre_doc UNIQUE (id_pre, id_documento)
) ENGINE=InnoDB;

-- ==============================================================================
-- VISTA DE CONSULTA: v_preinscripciones_completas
-- ==============================================================================
CREATE OR REPLACE VIEW v_preinscripciones_completas AS
SELECT 
    p.id AS preinscripcion_id,
    p.codigo_solicitud,
    p.fecha_solicitud,
    p.estado AS estado_preinscripcion,
    CONCAT(a.tipo_documento, '-', a.numero_identificacion) AS identificacion_alumno,
    CONCAT(a.nombres, ' ', a.apellidos) AS nombre_completo_alumno,
    TIMESTAMPDIFF(YEAR, a.fecha_nacimiento, CURDATE()) AS edad_alumno,
    CONCAT(r.tipo_documento, '-', r.numero_identificacion) AS identificacion_representante,
    CONCAT(r.nombres, ' ', r.apellidos) AS nombre_completo_representante,
    r.parentesco,
    r.telefono_principal,
    COALESCE(i.nombre, 'Primer Ingreso') AS instituto_procedencia,
    g.nombre AS grado_solicitado,
    pa.codigo AS periodo_academico,
    u.nombre_usuario AS registrado_por
FROM preinscripciones p
JOIN alumnos a ON p.id_alumno = a.id
JOIN representantes r ON p.id_repre = r.id
JOIN grado_periodos gp ON p.id_g_periodo = gp.id
JOIN grados g ON gp.id_grado = g.id
JOIN periodos_academicos pa ON gp.id_periodo = pa.id
JOIN usuarios u ON p.id_user = u.id
LEFT JOIN institutos i ON p.id_instituto = i.id;

-- ==============================================================================
-- DATOS SEMILLA (Exclusivo Primaria 1° a 6° y Periodo 2026-2027)
-- ==============================================================================

-- 1. Usuarios
INSERT INTO usuarios (nombre_completo, nombre_usuario, correo, password_hash, rol, estado) VALUES
('Coordinación de Control de Estudios', 'admin_nueva_america', 'control@feyalegrianuevaamerica.edu.ve', '$2y$10$e8T8J8y5cQZz3JkYJ8Q.1u8x0Hq3q7H3zUj7d5J2n4Z0bB1F4x5C6', 'ADMINISTRADOR', 'ACTIVO'),
('Secretaría Académica', 'secretaria', 'secretaria@feyalegrianuevaamerica.edu.ve', '$2y$10$e8T8J8y5cQZz3JkYJ8Q.1u8x0Hq3q7H3zUj7d5J2n4Z0bB1F4x5C6', 'SECRETARIA', 'ACTIVO');

-- 2. Institutos de Procedencia (Estado Zulia: San Francisco y Maracaibo)
INSERT INTO institutos (codigo_plantel, nombre, tipo_institucion, ciudad) VALUES
('DEA-CEI-24J', 'C.E.I. Barrio 24 de Julio', 'PUBLICA', 'San Francisco, Edo. Zulia'),
('DEA-FYA-CHINITA', 'U.E. Fe y Alegría La Chinita', 'SUBVENCIONADA_FE_Y_ALEGRIA', 'San Francisco, Edo. Zulia'),
('DEA-SIM-MANZ', 'C.E.I. Simoncito El Manzanillo', 'PUBLICA', 'San Francisco, Edo. Zulia'),
('DEA-COL-SVP', 'Colegio San Vicente de Paúl', 'PRIVADA', 'Maracaibo, Edo. Zulia'),
('DEA-FYA-LESTONNAC', 'U.E. Fe y Alegría Santa Juana de Lestonnac', 'SUBVENCIONADA_FE_Y_ALEGRIA', 'Maracaibo, Edo. Zulia'),
('DEA-CEI-CORTIJOS', 'C.E.I. Los Cortijos', 'PUBLICA', 'San Francisco, Edo. Zulia');

-- 3. Catálogo de Grados (1° a 6° Grado de Primaria Únicamente)
INSERT INTO grados (codigo, nombre, nivel_educativo, orden_jerarquico) VALUES
('PRIM-1', '1er Grado de Educación Primaria', 'PRIMARIA', 1),
('PRIM-2', '2do Grado de Educación Primaria', 'PRIMARIA', 2),
('PRIM-3', '3er Grado de Educación Primaria', 'PRIMARIA', 3),
('PRIM-4', '4to Grado de Educación Primaria', 'PRIMARIA', 4),
('PRIM-5', '5to Grado de Educación Primaria', 'PRIMARIA', 5),
('PRIM-6', '6to Grado de Educación Primaria', 'PRIMARIA', 6);

-- 4. Periodo Académico (2026-2027)
INSERT INTO periodos_academicos (codigo, nombre, fecha_inicio, fecha_fin, estado) VALUES
('2026-2027', 'Año Escolar 2026 - 2027', '2026-09-15', '2027-07-31', 'PREINSCRIPCION_ABIERTA');

-- 5. Relación Grado - Periodo (R_G_Periodo)
INSERT INTO grado_periodos (id_grado, id_periodo, estado) VALUES
(1, 1, 'DISPONIBLE'), -- 1er Grado 2026-2027
(2, 1, 'DISPONIBLE'), -- 2do Grado 2026-2027
(3, 1, 'DISPONIBLE'), -- 3er Grado 2026-2027
(4, 1, 'DISPONIBLE'), -- 4to Grado 2026-2027
(5, 1, 'DISPONIBLE'), -- 5to Grado 2026-2027
(6, 1, 'DISPONIBLE'); -- 6to Grado 2026-2027

-- 6. Catálogo de Documentos
INSERT INTO documentos (codigo, nombre, es_obligatorio) VALUES
('PARTIDA_NAC', 'Partida de Nacimiento del Alumno (Copia y Original)', TRUE),
('CI_REPRESENTANTE', 'Cédula de Identidad del Representante (Copia legible)', TRUE),
('BOLETA_NOTAS', 'Informe Descriptivo / Boleta de Calificaciones del grado anterior', TRUE),
('FOTOS_CARNET', '4 Fotografías del estudiante tipo carnet (Fondo blanco)', TRUE),
('CARTA_RESIDENCIA', 'Constancia de Residencia de la comunidad', TRUE),
('TARJETA_VACUNAS', 'Tarjeta o Certificado de Vacunación vigente', FALSE);
