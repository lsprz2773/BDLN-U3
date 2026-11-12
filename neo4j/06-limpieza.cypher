// =====================================================================
// QATO'K · 06 · Retirar los datos de ejemplo
// Borra solo los nodos cuyo id_* empieza por el prefijo de ejemplo, con sus
// relaciones. Las restricciones y los índices se conservan.
// Al final, pruebas que confirman que la base quedó vacía y el esquema intacto.
// =====================================================================

MATCH (n)
WHERE any(k IN keys(n) WHERE k STARTS WITH 'id_' AND n[k] STARTS WITH 'e0000000-0000-4000-8000-')
DETACH DELETE n;

// L1 · No queda ningún nodo ni relación de ejemplo
MATCH (n) WITH count(n) AS nodos
OPTIONAL MATCH ()-[r]->() WITH nodos, count(r) AS rels
RETURN 'L1 · base sin datos de ejemplo' AS prueba, nodos = 0 AND rels = 0 AS ok,
       toString(nodos) + ' nodos, ' + toString(rels) + ' relaciones' AS detalle;

// L2 · Las 15 restricciones siguen
SHOW CONSTRAINTS YIELD type WHERE type CONTAINS 'UNIQUENESS'
RETURN 'L2 · se conservan las 15 restricciones' AS prueba, count(*) = 15 AS ok, toString(count(*)) AS detalle;

// L3 · Los 9 índices de consulta siguen en línea
SHOW INDEXES YIELD name, state
WHERE name IN ['simulacion_estado', 'simulacion_texto', 'habilidad_categoria', 'paso_orden', 'intento_estado',
               'intento_fecha_inicio', 'respuesta_secuencia', 'comparticion_vigencia', 'evidencia_visibilidad']
RETURN 'L3 · se conservan los 9 índices' AS prueba,
       count(*) = 9 AND sum(CASE WHEN state = 'ONLINE' THEN 1 ELSE 0 END) = 9 AS ok, toString(count(*)) AS detalle;
