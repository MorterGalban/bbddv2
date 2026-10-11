/**
 * SERVIDOR BACKEND (Node.js + Express + MySQL2)
 * U.E. FE Y ALEGRÍA "NUEVA AMÉRICA" - SISTEMA DE PREINSCRIPCIÓN
 * Base de Datos: sistema_preinscripcion (MySQL)
 */

const express = require('express');
const mysql = require('mysql2/promise');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de conexión MySQL
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'sistema_preinscripcion',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
};

let pool = null;

try {
    pool = mysql.createPool(dbConfig);
    console.log(`[MySQL] Pool de conexiones listo para 'sistema_preinscripcion'`);
} catch (err) {
    console.warn('[MySQL] Pool no conectado:', err.message);
}

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// Endpoint: Obtener solicitudes de preinscripción
app.get('/api/preinscripciones', async (req, res) => {
    try {
        if (!pool) return res.status(503).json({ error: 'Conexión a MySQL no inicializada' });
        const [rows] = await pool.query('SELECT * FROM v_preinscripciones_completas ORDER BY fecha_solicitud DESC');
        res.json({ success: true, data: rows });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Endpoint: Registrar nueva solicitud (Transacción ACID)
app.post('/api/preinscripciones', async (req, res) => {
    if (!pool) return res.status(503).json({ error: 'Conexión a MySQL no inicializada' });

    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const { alumno, representante, instituto, preinscripcion, documentos } = req.body;

        // 1. Insertar Alumno
        const [resAlumno] = await connection.query(
            `INSERT INTO alumnos (tipo_documento, numero_identificacion, nombres, apellidos, fecha_nacimiento, genero, tipo_sangre, direccion_habitacion)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)`,
            [alumno.tipo_doc, alumno.numero_doc, alumno.nombres, alumno.apellidos, alumno.fecha_nac, alumno.genero, alumno.tipo_sangre, alumno.direccion]
        );
        const alumnoId = resAlumno.insertId;

        // 2. Insertar Representante
        const [resRepre] = await connection.query(
            `INSERT INTO representantes (tipo_documento, numero_identificacion, nombres, apellidos, parentesco, telefono_principal, correo, direccion_habitacion)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)`,
            [representante.tipo_doc, representante.numero_doc, representante.nombres, representante.apellidos, representante.parentesco, representante.telefono, representante.correo, representante.direccion]
        );
        const repreId = resRepre.insertId;

        // 3. Insertar Instituto de Procedencia (InstAuto)
        let institutoId = null;
        if (instituto && !instituto.es_primer_ingreso) {
            const [resInst] = await connection.query(
                `INSERT INTO institutos (codigo_plantel, nombre, tipo_institucion, ciudad, telefono)
                 VALUES (?, ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE id = LAST_INSERT_ID(id)`,
                [instituto.codigo, instituto.nombre, instituto.tipo, instituto.ciudad, instituto.telefono]
            );
            institutoId = resInst.insertId;
        }

        // 4. Insertar Preinscripción Principal (Pre-Inscripcion)
        const [resPre] = await connection.query(
            `INSERT INTO preinscripciones (codigo_solicitud, id_repre, id_alumno, id_instituto, id_g_periodo, id_user, estado, observaciones)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            [preinscripcion.codigo_solicitud, repreId, alumnoId, institutoId, preinscripcion.id_g_periodo, preinscripcion.id_user, preinscripcion.estado, preinscripcion.observaciones]
        );
        const preId = resPre.insertId;

        // 5. Insertar Documentos Consignados (R_P_D)
        if (Array.isArray(documentos) && documentos.length > 0) {
            for (const doc of documentos) {
                await connection.query(
                    `INSERT INTO preinscripcion_documentos (id_pre, id_documento, estado, fecha_entrega)
                     VALUES (?, ?, ?, NOW())`,
                    [preId, doc.id_documento, doc.estado]
                );
            }
        }

        await connection.commit();
        res.json({ success: true, message: 'Preinscripción registrada con éxito en MySQL', preinscripcionId: preId });
    } catch (error) {
        await connection.rollback();
        console.error('[Error de Transacción]', error);
        res.status(500).json({ success: false, error: error.message });
    } finally {
        connection.release();
    }
});

app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(` Servidor Fe y Alegría Nueva América ejecutándose en:`);
    console.log(` http://localhost:${PORT}`);
    console.log(`====================================================`);
});
