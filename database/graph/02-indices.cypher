// =====================================================================
// QATO'K · 02 · Índices
// Las 15 restricciones de unicidad (01) ya crean índices sobre los id_*,
// Usuario.correo, Habilidad.nombre y Comparticion.token. Aquí se añaden solo
// los índices que piden las consultas (entregable 1) y las reglas (entregable 4).
// =====================================================================

// C-01, RI-19 · filtrar simulaciones PUBLICADAS
CREATE INDEX simulacion_estado IF NOT EXISTS FOR (n:Simulacion) ON (n.estado);

// RF-02 · buscar simulaciones por texto (título y descripción)
CREATE FULLTEXT INDEX simulacion_texto IF NOT EXISTS FOR (n:Simulacion) ON EACH [n.titulo, n.descripcion];

// RF-02 · filtrar el catálogo de habilidades por categoría
CREATE INDEX habilidad_categoria IF NOT EXISTS FOR (n:Habilidad) ON (n.categoria);

// RI-18 · localizar el paso inicial (orden = 1) de una simulación
CREATE INDEX paso_orden IF NOT EXISTS FOR (n:Paso) ON (n.orden);

// C-05, RF-10 · intentos COMPLETADOS o EN_CURSO (reanudar)
CREATE INDEX intento_estado IF NOT EXISTS FOR (n:Intento) ON (n.estado);

// C-03, C-05 · ordenar y filtrar intentos por fecha
CREATE INDEX intento_fecha_inicio IF NOT EXISTS FOR (n:Intento) ON (n.fecha_inicio);

// C-03, RI-16 · ordenar las respuestas de un intento
CREATE INDEX respuesta_secuencia IF NOT EXISTS FOR (n:Respuesta) ON (n.secuencia);

// C-04, RI-15 · enlaces vigentes: estado ACTIVA y sin expirar (índice compuesto)
CREATE INDEX comparticion_vigencia IF NOT EXISTS FOR (n:Comparticion) ON (n.estado, n.fecha_expiracion);

// RF-09 · evidencias por visibilidad
CREATE INDEX evidencia_visibilidad IF NOT EXISTS FOR (n:Evidencia) ON (n.visibilidad);

// Esperar a que todos los índices estén en línea
CALL db.awaitIndexes(120);
