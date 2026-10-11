# U.E. Fe y Alegría "Nueva América" - Sistema de Preinscripción Primaria

Sistema institucional y web de admisión escolar para **Educación Primaria (1er a 6to Grado)** - **Periodo Escolar 2026 - 2027**, enlazado directamente a una base de datos relacional en **MySQL 8.0+** basada en el modelo de entidad-relación entregado.

---

## 🎨 Identidad Institucional & Características Clave

- **Logotipo Oficial**: Incorpora el logo oficial de **Fe y Alegría Nueva América** con su emblemático corazón rojo y siluetas.
- **Paleta de Colores Roja**: Rojo institucional Fe y Alegría (`#d90429`, `#b91c1c`, `#ef233c`) con acentos limpios y acabados de alta calidad.
- **Nivel Académico Exclusivo**: **Educación Primaria** (1°, 2°, 3°, 4°, 5° y 6° Grado).
- **Periodo Escolar**: **2026 - 2027**.
- **Sin Apartado de Cupos**: Eliminado según lo solicitado para un flujo enfocado exclusivamente en la recepción de preinscripciones.
- **Validación Estricta Paso a Paso**: No permite avanzar al siguiente paso si existen campos obligatorios (`*`) vacíos o con formato inválido; resalta los campos con borde rojo y animación de advertencia.
- **Planilla Oficial Imprimible**: Genera una planilla formal con membrete del Ministerio, logo de Fe y Alegría, recuadro de foto, datos del alumno, representante, escuela de procedencia, recaudos y firmas, formateada para impresión en hoja carta (`@media print`).

---

## 📂 Estructura del Proyecto

1. **[index.html](file:///c:/Users/chaso/bbdd/index.html)**:
   - **Página Principal Institucional** de la Unidad Educativa Fe y Alegría Nueva América.
   - Presenta la identidad de la escuela, el ideario del P. José María Vélaz, la oferta de 1° a 6° de Primaria, requisitos, ubicación, horarios y botón destacado para iniciar la preinscripción.

2. **[preinscripcion.html](file:///c:/Users/chaso/bbdd/preinscripcion.html)**:
   - **Portal y Formulario de Preinscripción 2026-2027**.
   - Formulario interactivo en 5 pasos (Alumno, Representante, Procedencia, Grado, Recaudos y Auditoría).
   - Generador y visor de la Planilla Oficial Fe y Alegría.
   - Visor y descargador de consultas SQL MySQL en vivo.

3. **[styles.css](file:///c:/Users/chaso/bbdd/styles.css)**:
   - Sistema de diseño con la paleta roja oficial Fe y Alegría, tipografía *Outfit* e *Inter*, y reglas `@media print`.

4. **[app.js](file:///c:/Users/chaso/bbdd/app.js)**:
   - Lógica de validación estricta por paso, generación correlativa de folios (`PRE-2026-XXXX`), autocompletado de prueba y construcción de sentencias MySQL.

5. **[schema_preinscripcion.sql](file:///c:/Users/chaso/bbdd/schema_preinscripcion.sql)**:
   - Script DDL para MySQL con las 10 tablas del modelo entidad-relación ajustadas a Primaria y periodo 2026-2027.

6. **[logo_feyalegria.jpg](file:///c:/Users/chaso/bbdd/logo_feyalegria.jpg)**:
   - Archivo del logotipo oficial de Fe y Alegría Nueva América utilizado en cabecera y membrete de la planilla.

---

## 🚀 ¿Cómo Usar el Sistema?

### 1. Navegación Web Directa
- Abre **[index.html](file:///c:/Users/chaso/bbdd/index.html)** en tu navegador para ver la página institucional.
- Haz clic en **"Preinscripción 2026-2027"** para ir a **[preinscripcion.html](file:///c:/Users/chaso/bbdd/preinscripcion.html)**.
- Prueba el botón **"Llenar Ejemplo"** para cargar un expediente escolar completo con 1 clic.
- Presiona **"Generar Planilla Oficial"** para imprimir o guardar en PDF la planilla con el logo institucional.
- Presiona **"Ver SQL"** para copiar o descargar las sentencias `INSERT` para tu base de datos MySQL.

### 2. Base de Datos MySQL
En tu consola de MySQL o MySQL Workbench:
```sql
SOURCE c:/Users/chaso/bbdd/schema_preinscripcion.sql;
```
