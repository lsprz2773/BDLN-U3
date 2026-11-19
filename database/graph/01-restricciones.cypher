// =====================================================================
// QATO'K · 01 · Restricciones de integridad nativas (Neo4j Community)
// Fuente: entregable 4 (RI-01, RI-02, RI-03, RI-15) y entregable 2.
// Cada restricción de unicidad crea además su índice de respaldo.
// Las demás restricciones (existencia, tipo, rangos, catálogos, consistencia
// entre nodos) no son nativas en Community: ver 01b-restricciones-enterprise.cypher
// y las validaciones de la aplicación del entregable 4.
// =====================================================================

// RI-01 · Identificador UUID único en las 12 etiquetas
CREATE CONSTRAINT usuario_id IF NOT EXISTS FOR (n:Usuario) REQUIRE n.id_usuario IS UNIQUE;
CREATE CONSTRAINT simulacion_id IF NOT EXISTS FOR (n:Simulacion) REQUIRE n.id_simulacion IS UNIQUE;
CREATE CONSTRAINT habilidad_id IF NOT EXISTS FOR (n:Habilidad) REQUIRE n.id_habilidad IS UNIQUE;
CREATE CONSTRAINT paso_id IF NOT EXISTS FOR (n:Paso) REQUIRE n.id_paso IS UNIQUE;
CREATE CONSTRAINT opcion_id IF NOT EXISTS FOR (n:Opcion) REQUIRE n.id_opcion IS UNIQUE;
CREATE CONSTRAINT consecuencia_id IF NOT EXISTS FOR (n:Consecuencia) REQUIRE n.id_consecuencia IS UNIQUE;
CREATE CONSTRAINT intento_id IF NOT EXISTS FOR (n:Intento) REQUIRE n.id_intento IS UNIQUE;
CREATE CONSTRAINT respuesta_id IF NOT EXISTS FOR (n:Respuesta) REQUIRE n.id_respuesta IS UNIQUE;
CREATE CONSTRAINT retroalimentacion_id IF NOT EXISTS FOR (n:Retroalimentacion) REQUIRE n.id_retroalimentacion IS UNIQUE;
CREATE CONSTRAINT progreso_id IF NOT EXISTS FOR (n:Progreso) REQUIRE n.id_progreso IS UNIQUE;
CREATE CONSTRAINT evidencia_id IF NOT EXISTS FOR (n:Evidencia) REQUIRE n.id_evidencia IS UNIQUE;
CREATE CONSTRAINT comparticion_id IF NOT EXISTS FOR (n:Comparticion) REQUIRE n.id_comparticion IS UNIQUE;

// RI-02 · Correo único (la aplicación lo guarda normalizado: toLower(trim(correo)))
CREATE CONSTRAINT usuario_correo IF NOT EXISTS FOR (n:Usuario) REQUIRE n.correo IS UNIQUE;

// RI-03 · Nombre de habilidad único
CREATE CONSTRAINT habilidad_nombre IF NOT EXISTS FOR (n:Habilidad) REQUIRE n.nombre IS UNIQUE;

// RI-15 · Token de compartición único
CREATE CONSTRAINT comparticion_token IF NOT EXISTS FOR (n:Comparticion) REQUIRE n.token IS UNIQUE;
