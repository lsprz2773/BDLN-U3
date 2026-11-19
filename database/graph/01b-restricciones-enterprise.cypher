// =====================================================================
// QATO'K · 01b · Restricciones disponibles solo en Neo4j Enterprise
// NO se ejecuta en la edición Community (las pruebas de humo comprueban
// que Community las rechaza). En Community, estas reglas las valida la
// aplicación antes de escribir (entregable 4, mecanismo [A]).
// Ejecutar solo sobre un servidor Neo4j Enterprise 5.9 o superior.
// =====================================================================

// RI-04 · Propiedades obligatorias (existencia), ejemplos por etiqueta
CREATE CONSTRAINT usuario_correo_existe IF NOT EXISTS FOR (n:Usuario) REQUIRE n.correo IS NOT NULL;
CREATE CONSTRAINT usuario_nombre_existe IF NOT EXISTS FOR (n:Usuario) REQUIRE n.nombre IS NOT NULL;
CREATE CONSTRAINT simulacion_estado_existe IF NOT EXISTS FOR (n:Simulacion) REQUIRE n.estado IS NOT NULL;
CREATE CONSTRAINT paso_orden_existe IF NOT EXISTS FOR (n:Paso) REQUIRE n.orden IS NOT NULL;
CREATE CONSTRAINT intento_estado_existe IF NOT EXISTS FOR (n:Intento) REQUIRE n.estado IS NOT NULL;
CREATE CONSTRAINT respuesta_secuencia_existe IF NOT EXISTS FOR (n:Respuesta) REQUIRE n.secuencia IS NOT NULL;
CREATE CONSTRAINT progreso_nivel_existe IF NOT EXISTS FOR (n:Progreso) REQUIRE n.nivel_actual IS NOT NULL;
CREATE CONSTRAINT desarrolla_peso_existe IF NOT EXISTS FOR ()-[r:DESARROLLA]-() REQUIRE r.peso IS NOT NULL;

// RI-18, RI-24 · Tipo de las propiedades (Neo4j 5.9 o superior)
CREATE CONSTRAINT paso_orden_entero IF NOT EXISTS FOR (n:Paso) REQUIRE n.orden IS :: INTEGER;
CREATE CONSTRAINT respuesta_secuencia_entero IF NOT EXISTS FOR (n:Respuesta) REQUIRE n.secuencia IS :: INTEGER;
CREATE CONSTRAINT intento_inicio_fecha IF NOT EXISTS FOR (n:Intento) REQUIRE n.fecha_inicio IS :: ZONED DATETIME;
CREATE CONSTRAINT progreso_nivel_decimal IF NOT EXISTS FOR (n:Progreso) REQUIRE n.nivel_actual IS :: FLOAT;
