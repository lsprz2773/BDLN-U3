// =====================================================================
// QATO'K · 05 (versión Neo4j Desktop) · Pruebas de humo SIN sentencias que fallan
// Igual que 05-pruebas-humo.cypher, pero sin A3, A4 ni C15 (las sentencias que deben
// fallar): Neo4j Desktop detiene la ejecución en el primer error. Esas pruebas siguen
// en 05-pruebas-humo.cypher y se ejecutan con ejecutar.sh.
// Requisito: haber ejecutado 01, 02, 03 y 04 (en ese orden) sobre la base.
// Cada prueba devuelve una fila (prueba, ok, detalle); ok = false es un fallo.
// =====================================================================

// ======================= A. Esquema ==================================

// A1 · Las 15 restricciones de unicidad existen (RI-01, RI-02, RI-03, RI-15)
SHOW CONSTRAINTS YIELD name, type
WHERE type CONTAINS 'UNIQUENESS'
RETURN 'A1 · 15 restricciones de unicidad' AS prueba, count(*) = 15 AS ok,
       toString(count(*)) + ' encontradas' AS detalle;

// A2 · Los 9 índices de consulta existen y están en línea
SHOW INDEXES YIELD name, state
WHERE name IN ['simulacion_estado', 'simulacion_texto', 'habilidad_categoria', 'paso_orden', 'intento_estado',
               'intento_fecha_inicio', 'respuesta_secuencia', 'comparticion_vigencia', 'evidencia_visibilidad']
RETURN 'A2 · 9 índices de consulta en línea' AS prueba,
       count(*) = 9 AND sum(CASE WHEN state = 'ONLINE' THEN 1 ELSE 0 END) = 9 AS ok,
       toString(count(*)) + ' índices, ' + toString(sum(CASE WHEN state = 'ONLINE' THEN 1 ELSE 0 END)) + ' en línea' AS detalle;

// A3 · Edición del servidor (Desktop usa Enterprise; el ejecutor automático, Community)
CALL dbms.components() YIELD name, edition, versions
RETURN 'A3 · edición del servidor' AS prueba, true AS ok, name + ' ' + edition + ' ' + versions[0] AS detalle;

// ======================= B. Datos de ejemplo cargados ================

// B1 · Nodos por etiqueta
UNWIND [['Usuario', 2], ['Habilidad', 3], ['Simulacion', 3], ['Paso', 4], ['Opcion', 9], ['Consecuencia', 9],
        ['Intento', 4], ['Respuesta', 5], ['Retroalimentacion', 5], ['Progreso', 3], ['Evidencia', 1], ['Comparticion', 3]] AS e
CALL {
  WITH e
  MATCH (n) WHERE e[0] IN labels(n)
  RETURN count(n) AS c
}
RETURN 'B1 · nodos :' + e[0] AS prueba, c = e[1] AS ok, toString(c) + ' de ' + toString(e[1]) AS detalle;

// B2 · Relaciones por patrón (las 17 del modelo)
UNWIND [['Usuario', 'REALIZA', 'Intento', 4], ['Simulacion', 'TIENE', 'Intento', 4], ['Simulacion', 'CONTIENE', 'Paso', 4],
        ['Simulacion', 'DESARROLLA', 'Habilidad', 5], ['Paso', 'OFRECE', 'Opcion', 9], ['Opcion', 'GENERA', 'Consecuencia', 9],
        ['Opcion', 'CONDUCE_A', 'Paso', 3], ['Intento', 'REGISTRA', 'Respuesta', 5], ['Respuesta', 'CORRESPONDE_A', 'Paso', 5],
        ['Respuesta', 'SELECCIONA', 'Opcion', 5], ['Respuesta', 'GENERA', 'Retroalimentacion', 5], ['Usuario', 'TIENE_PROGRESO', 'Progreso', 3],
        ['Progreso', 'CORRESPONDE_A', 'Habilidad', 3], ['Usuario', 'GENERA', 'Evidencia', 1], ['Intento', 'PRODUCE', 'Evidencia', 1],
        ['Evidencia', 'DEMUESTRA', 'Habilidad', 2], ['Evidencia', 'TIENE_COMPARTICION', 'Comparticion', 3]] AS e
CALL {
  WITH e
  MATCH (a)-[r]->(b) WHERE type(r) = e[1] AND e[0] IN labels(a) AND e[2] IN labels(b)
  RETURN count(r) AS c
}
RETURN 'B2 · (' + e[0] + ')-[:' + e[1] + ']->(' + e[2] + ')' AS prueba, c = e[3] AS ok,
       toString(c) + ' de ' + toString(e[3]) AS detalle;

// B3 · Totales y ninguna relación fuera del modelo
MATCH (n) WITH count(n) AS nodos
MATCH ()-[r]->() WITH nodos, count(r) AS rels
RETURN 'B3 · 51 nodos y 71 relaciones en total' AS prueba, nodos = 51 AND rels = 71 AS ok,
       toString(nodos) + ' nodos, ' + toString(rels) + ' relaciones' AS detalle;

// B4 · Las propiedades opcionales sin valor no se guardan (en Neo4j, nulo = ausente)
MATCH (i:Intento {id_intento: 'e0000000-0000-4000-8000-000000000704'}), (h:Habilidad {id_habilidad: 'e0000000-0000-4000-8000-000000000203'}),
      (s:Simulacion {id_simulacion: 'e0000000-0000-4000-8000-000000000303'}), (c:Comparticion {id_comparticion: 'e0000000-0000-4000-8000-000000001202'})
WITH [k IN ['fecha_fin', 'puntuacion'] WHERE k IN keys(i)] + [k IN ['nivel_objetivo'] WHERE k IN keys(h)]
   + [k IN ['duracion_estimada'] WHERE k IN keys(s)] + [k IN ['fecha_expiracion', 'destinatario'] WHERE k IN keys(c)] AS sobrantes
RETURN 'B4 · opcionales sin valor no se almacenan' AS prueba, size(sobrantes) = 0 AS ok, sobrantes AS detalle;

// ======================= C. Integridad: cardinalidades y reglas ======

// C1 · Relaciones obligatorias (entregable 5): ningún nodo dependiente queda huérfano ni excede su máximo
CALL {
  MATCH (n:Paso) WHERE COUNT { (:Simulacion)-[:CONTIENE]->(n) } <> 1 OR COUNT { (n)-[:OFRECE]->(:Opcion) } < 1
  WITH count(n) AS v RETURN 'Paso' AS e, v
  UNION ALL
  MATCH (n:Opcion) WHERE COUNT { (:Paso)-[:OFRECE]->(n) } <> 1 OR COUNT { (n)-[:GENERA]->(:Consecuencia) } < 1
                      OR COUNT { (n)-[:CONDUCE_A]->(:Paso) } > 1
  WITH count(n) AS v RETURN 'Opcion' AS e, v
  UNION ALL
  MATCH (n:Consecuencia) WHERE COUNT { (:Opcion)-[:GENERA]->(n) } <> 1
  WITH count(n) AS v RETURN 'Consecuencia' AS e, v
  UNION ALL
  MATCH (n:Intento) WHERE COUNT { (:Usuario)-[:REALIZA]->(n) } <> 1 OR COUNT { (:Simulacion)-[:TIENE]->(n) } <> 1
  WITH count(n) AS v RETURN 'Intento' AS e, v
  UNION ALL
  MATCH (n:Respuesta) WHERE COUNT { (:Intento)-[:REGISTRA]->(n) } <> 1 OR COUNT { (n)-[:CORRESPONDE_A]->(:Paso) } <> 1
                         OR COUNT { (n)-[:SELECCIONA]->(:Opcion) } <> 1
  WITH count(n) AS v RETURN 'Respuesta' AS e, v
  UNION ALL
  MATCH (n:Retroalimentacion) WHERE COUNT { (:Respuesta)-[:GENERA]->(n) } <> 1
  WITH count(n) AS v RETURN 'Retroalimentacion' AS e, v
  UNION ALL
  MATCH (n:Progreso) WHERE COUNT { (:Usuario)-[:TIENE_PROGRESO]->(n) } <> 1 OR COUNT { (n)-[:CORRESPONDE_A]->(:Habilidad) } <> 1
  WITH count(n) AS v RETURN 'Progreso' AS e, v
  UNION ALL
  MATCH (n:Evidencia) WHERE COUNT { (:Usuario)-[:GENERA]->(n) } <> 1 OR COUNT { (:Intento)-[:PRODUCE]->(n) } <> 1
                         OR COUNT { (n)-[:DEMUESTRA]->(:Habilidad) } < 1
  WITH count(n) AS v RETURN 'Evidencia' AS e, v
  UNION ALL
  MATCH (n:Comparticion) WHERE COUNT { (:Evidencia)-[:TIENE_COMPARTICION]->(n) } <> 1
  WITH count(n) AS v RETURN 'Comparticion' AS e, v
}
RETURN 'C1 · cardinalidades obligatorias de :' + e AS prueba, v = 0 AS ok, toString(v) + ' nodos incumplen' AS detalle;

// C2 · RI-10: la opción elegida pertenece al paso respondido, y el paso a la simulación del intento
MATCH (s:Simulacion)-[:TIENE]->(:Intento)-[:REGISTRA]->(r:Respuesta)-[:CORRESPONDE_A]->(p:Paso), (r)-[:SELECCIONA]->(o:Opcion)
WHERE NOT (p)-[:OFRECE]->(o) OR NOT (s)-[:CONTIENE]->(p)
WITH count(r) AS v
RETURN 'C2 · RI-10 consistencia de respuestas' AS prueba, v = 0 AS ok, toString(v) + ' incoherentes' AS detalle;

// C3 · RI-11: CONDUCE_A no sale de la simulación del paso de origen
MATCH (s:Simulacion)-[:CONTIENE]->(:Paso)-[:OFRECE]->(o:Opcion)-[:CONDUCE_A]->(p2:Paso)
WHERE NOT (s)-[:CONTIENE]->(p2)
WITH count(o) AS v
RETURN 'C3 · RI-11 rutas dentro de la misma simulación' AS prueba, v = 0 AS ok, toString(v) + ' rutas cruzadas' AS detalle;

// C4 · RI-17: toda simulación PUBLICADA tiene pasos, habilidades, opciones en cada paso y consecuencias en cada opción
MATCH (s:Simulacion {estado: 'PUBLICADA'})
WHERE NOT (s)-[:CONTIENE]->(:Paso) OR NOT (s)-[:DESARROLLA]->(:Habilidad)
   OR EXISTS { (s)-[:CONTIENE]->(p:Paso) WHERE NOT (p)-[:OFRECE]->(:Opcion) }
   OR EXISTS { (s)-[:CONTIENE]->(:Paso)-[:OFRECE]->(o:Opcion) WHERE NOT (o)-[:GENERA]->(:Consecuencia) }
WITH count(s) AS v
RETURN 'C4 · RI-17 contenido mínimo de las simulaciones PUBLICADAS' AS prueba, v = 0 AS ok, toString(v) + ' incompletas' AS detalle;

// C5 · RI-16: secuencia >= 1 y única dentro de cada intento
MATCH (i:Intento)-[:REGISTRA]->(r:Respuesta)
WITH i, r.secuencia AS sec, count(*) AS veces
WHERE sec < 1 OR veces > 1
WITH count(*) AS v
RETURN 'C5 · RI-16 secuencia válida y única por intento' AS prueba, v = 0 AS ok, toString(v) + ' repetidas o inválidas' AS detalle;

// C6 · RI-18: orden > 0 y único por simulación; exactamente un paso inicial (orden = 1) en cada PUBLICADA
MATCH (s:Simulacion {estado: 'PUBLICADA'})-[:CONTIENE]->(p:Paso)
WITH s, collect(p.orden) AS ordenes, collect(DISTINCT p.orden) AS distintos, min(p.orden) AS minimo
WHERE size(ordenes) <> size(distintos) OR minimo < 1 OR NOT 1 IN ordenes
WITH count(s) AS v
RETURN 'C6 · RI-18 orden de pasos' AS prueba, v = 0 AS ok, toString(v) + ' simulaciones con orden inválido' AS detalle;

// C7 · RI-20: las habilidades demostradas las desarrolla la simulación del intento de origen
MATCH (s:Simulacion)-[:TIENE]->(:Intento)-[:PRODUCE]->(e:Evidencia)-[:DEMUESTRA]->(h:Habilidad)
WHERE NOT (s)-[:DESARROLLA]->(h)
WITH count(e) AS v
RETURN 'C7 · RI-20 DEMUESTRA dentro de DESARROLLA' AS prueba, v = 0 AS ok, toString(v) + ' fuera' AS detalle;

// C8 · RI-14: la evidencia y su intento de origen son del mismo usuario
MATCH (u:Usuario)-[:GENERA]->(e:Evidencia)<-[:PRODUCE]-(i:Intento)
WHERE NOT (u)-[:REALIZA]->(i)
WITH count(e) AS v
RETURN 'C8 · RI-14 propiedad de evidencias' AS prueba, v = 0 AS ok, toString(v) + ' ajenas' AS detalle;

// C9 · RI-06, RI-07, RI-12: rangos y coherencia temporal
CALL {
  MATCH (i:Intento) WHERE (i.estado = 'COMPLETADO' AND i.fecha_fin IS NULL) OR i.fecha_fin < i.fecha_inicio
                       OR i.puntuacion < 0 OR i.puntuacion > 100
  RETURN count(i) AS v
  UNION ALL
  MATCH (p:Progreso) WHERE p.nivel_actual < 0 OR p.nivel_actual > 100
  RETURN count(p) AS v
}
WITH sum(v) AS v
RETURN 'C9 · RI-06, RI-07, RI-12 rangos y fechas' AS prueba, v = 0 AS ok, toString(v) + ' valores fuera de rango' AS detalle;

// C10 · RI-13: un único progreso por usuario y habilidad
MATCH (u:Usuario)-[:TIENE_PROGRESO]->(:Progreso)-[:CORRESPONDE_A]->(h:Habilidad)
WITH u, h, count(*) AS veces WHERE veces > 1
WITH count(*) AS v
RETURN 'C10 · RI-13 un progreso por usuario y habilidad' AS prueba, v = 0 AS ok, toString(v) + ' duplicados' AS detalle;

// C11 · RI-23: un intento COMPLETADO termina en una opción terminal; uno EN_CURSO no
MATCH (i:Intento)-[:REGISTRA]->(r:Respuesta)-[:SELECCIONA]->(o:Opcion)
WITH i, r, o ORDER BY r.secuencia DESC
WITH i, head(collect(o)) AS ultima
WITH i, NOT (ultima)-[:CONDUCE_A]->(:Paso) AS terminal
WHERE (i.estado = 'COMPLETADO') <> terminal
WITH count(i) AS v
RETURN 'C11 · RI-23 fin del intento en opción terminal' AS prueba, v = 0 AS ok, toString(v) + ' incoherentes' AS detalle;

// C12 · RI-08: no hay dos DESARROLLA entre la misma simulación y habilidad
MATCH (s:Simulacion)-[d:DESARROLLA]->(h:Habilidad)
WITH s, h, count(d) AS veces WHERE veces > 1
WITH count(*) AS v
RETURN 'C12 · RI-08 DESARROLLA única por par' AS prueba, v = 0 AS ok, toString(v) + ' pares repetidos' AS detalle;

// C13 · RI-05, RI-06, RI-24: valores dentro de sus catálogos y rangos
CALL {
  MATCH (n:Simulacion) WHERE NOT n.dificultad IN ['BASICA', 'INTERMEDIA', 'AVANZADA'] OR NOT n.estado IN ['BORRADOR', 'PUBLICADA', 'INACTIVA'] OR n.duracion_estimada <= 0 RETURN count(n) AS v
  UNION ALL MATCH (n:Intento) WHERE NOT n.estado IN ['EN_CURSO', 'COMPLETADO', 'ABANDONADO'] RETURN count(n) AS v
  UNION ALL MATCH (n:Usuario) WHERE NOT n.estado IN ['ACTIVO', 'INACTIVO', 'SUSPENDIDO'] RETURN count(n) AS v
  UNION ALL MATCH (n:Paso) WHERE NOT n.tipo IN ['CORREO', 'REUNION', 'CONVERSACION', 'TAREA', 'INCIDENTE'] OR n.orden < 1 RETURN count(n) AS v
  UNION ALL MATCH (n:Consecuencia) WHERE NOT n.impacto IN ['POSITIVO', 'NEUTRO', 'NEGATIVO'] OR NOT n.tipo IN ['RELACIONAL', 'TIEMPO', 'CALIDAD', 'REPUTACION'] RETURN count(n) AS v
  UNION ALL MATCH (n:Retroalimentacion) WHERE NOT n.tipo IN ['ACIERTO', 'PARCIAL', 'ERROR'] RETURN count(n) AS v
  UNION ALL MATCH (n:Evidencia) WHERE NOT n.visibilidad IN ['PRIVADA', 'PUBLICA'] RETURN count(n) AS v
  UNION ALL MATCH (n:Comparticion) WHERE NOT n.estado IN ['ACTIVA', 'REVOCADA'] OR n.fecha_expiracion <= n.fecha_creacion RETURN count(n) AS v
  UNION ALL MATCH (n:Habilidad) WHERE n.nivel_objetivo < 0 OR n.nivel_objetivo > 100 RETURN count(n) AS v
  UNION ALL MATCH ()-[d:DESARROLLA]->() WHERE d.peso <= 0 OR d.peso > 1 OR d.nivel_esperado < 0 OR d.nivel_esperado > 100 RETURN count(d) AS v
}
WITH sum(v) AS v
RETURN 'C13 · RI-05, RI-06, RI-24 catálogos y rangos' AS prueba, v = 0 AS ok, toString(v) + ' valores no permitidos' AS detalle;

// C14 · Tipos de dato en Neo4j (entregable 2: UUID/texto → String, INTEGER → Integer, DECIMAL → Float, TIMESTAMP → DateTime)
MATCH (i:Intento {id_intento: 'e0000000-0000-4000-8000-000000000701'}), (p:Paso {id_paso: 'e0000000-0000-4000-8000-000000000401'}),
      (g:Progreso {id_progreso: 'e0000000-0000-4000-8000-000000001001'}), (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000101'})
WITH [valueType(u.id_usuario), valueType(p.orden), valueType(g.nivel_actual), valueType(i.fecha_inicio)] AS tipos
RETURN 'C14 · tipos String, Integer, Float y DateTime' AS prueba,
       tipos = ['STRING NOT NULL', 'INTEGER NOT NULL', 'FLOAT NOT NULL', 'ZONED DATETIME NOT NULL'] AS ok,
       tipos AS detalle;

// ======================= D. Consultas C-01..C-05 =====================

// D1 · C-01 para Ana: recomienda primero la simulación con mayor brecha ponderada
CALL {
  MATCH (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000101'})
  MATCH (s:Simulacion {estado: 'PUBLICADA'})-[d:DESARROLLA]->(h:Habilidad)
  OPTIONAL MATCH (u)-[:TIENE_PROGRESO]->(p:Progreso)-[:CORRESPONDE_A]->(h)
  WITH s, h, d, coalesce(p.nivel_actual, 0) AS nivel
  WHERE nivel < d.nivel_esperado
  RETURN s.titulo AS simulacion,
         collect(h.nombre) AS habilidades_a_fortalecer,
         sum(d.peso * (d.nivel_esperado - nivel)) AS prioridad
  ORDER BY prioridad DESC
}
WITH collect(simulacion) AS sims, collect(habilidades_a_fortalecer) AS habs
RETURN 'D1 · C-01 Ana: 2 simulaciones, primero «Tres entregas para mañana»' AS prueba,
       sims = ['Tres entregas para mañana', 'Cliente molesto por un retraso'] AND habs = [['Gestión del tiempo'], ['Resolución de conflictos']] AS ok,
       [sims, habs] AS detalle;

// D2 · C-01 para Bruno (usuario nuevo, sin progreso): ve todas las PUBLICADAS, nunca la de BORRADOR
CALL {
  MATCH (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000102'})
  MATCH (s:Simulacion {estado: 'PUBLICADA'})-[d:DESARROLLA]->(h:Habilidad)
  OPTIONAL MATCH (u)-[:TIENE_PROGRESO]->(p:Progreso)-[:CORRESPONDE_A]->(h)
  WITH s, h, d, coalesce(p.nivel_actual, 0) AS nivel
  WHERE nivel < d.nivel_esperado
  RETURN s.titulo AS simulacion,
         collect(h.nombre) AS habilidades_a_fortalecer,
         sum(d.peso * (d.nivel_esperado - nivel)) AS prioridad
  ORDER BY prioridad DESC
}
WITH collect(simulacion) AS sims
RETURN 'D2 · C-01 Bruno: 2 simulaciones publicadas, ninguna en BORRADOR' AS prueba,
       sims = ['Cliente molesto por un retraso', 'Tres entregas para mañana'] AS ok, sims AS detalle;

// D3 · C-02 para Ana: clasificación y conteos de retroalimentación por habilidad
CALL {
  MATCH (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000101'})-[:TIENE_PROGRESO]->(p:Progreso)-[:CORRESPONDE_A]->(h:Habilidad)
  OPTIONAL MATCH (u)-[:REALIZA]->(i:Intento)<-[:TIENE]-(:Simulacion)-[d:DESARROLLA]->(h)
  OPTIONAL MATCH (i)-[:REGISTRA]->(:Respuesta)-[:GENERA]->(r:Retroalimentacion)
  WITH h, p,
       max(d.nivel_esperado) AS esperado_max,
       count(CASE WHEN r.tipo = 'ACIERTO' THEN 1 END) AS aciertos,
       count(CASE WHEN r.tipo = 'PARCIAL' THEN 1 END) AS parciales,
       count(CASE WHEN r.tipo = 'ERROR' THEN 1 END) AS errores
  WITH h, p, coalesce(h.nivel_objetivo, esperado_max) AS objetivo, aciertos, parciales, errores
  RETURN h.nombre AS habilidad, p.nivel_actual AS nivel_actual, objetivo,
         CASE
           WHEN objetivo IS NULL THEN 'SIN_REFERENCIA'
           WHEN p.nivel_actual >= objetivo THEN 'FORTALEZA'
           ELSE 'AREA_DE_MEJORA'
         END AS clasificacion,
         aciertos, parciales, errores
  ORDER BY nivel_actual DESC
}
WITH collect([habilidad, clasificacion, objetivo, aciertos, parciales, errores]) AS filas
RETURN 'D3 · C-02 Ana: 1 fortaleza y 2 áreas de mejora (objetivo de respaldo = 60)' AS prueba,
       filas = [['Comunicación efectiva', 'FORTALEZA', 75, 2, 1, 2],
                ['Resolución de conflictos', 'AREA_DE_MEJORA', 70, 2, 1, 1],
                ['Gestión del tiempo', 'AREA_DE_MEJORA', 60, 0, 0, 1]] AS ok,
       filas AS detalle;

// D4 · C-03 para Ana en «Cliente molesto por un retraso»: 2 intentos, 4 decisiones en orden, cada una con consecuencia y retroalimentación
CALL {
  MATCH (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000101'})-[:REALIZA]->(i:Intento)<-[:TIENE]-(s:Simulacion {id_simulacion: 'e0000000-0000-4000-8000-000000000301'})
  MATCH (i)-[:REGISTRA]->(r:Respuesta)-[:CORRESPONDE_A]->(p:Paso)
  MATCH (r)-[:SELECCIONA]->(o:Opcion)
  OPTIONAL MATCH (o)-[:GENERA]->(c:Consecuencia)
  OPTIONAL MATCH (r)-[:GENERA]->(f:Retroalimentacion)
  RETURN i.id_intento AS intento, i.fecha_inicio AS inicio, r.secuencia AS n, p.titulo AS situacion,
         o.descripcion AS decision,
         collect(DISTINCT c.descripcion) AS consecuencias,
         collect(DISTINCT f.comentario) AS retroalimentacion
  ORDER BY inicio, n
}
WITH collect([n, decision]) AS pasos, collect(size(consecuencias) = 1 AND size(retroalimentacion) = 1) AS completos
RETURN 'D4 · C-03 Ana: recorrido de 4 decisiones ordenado por intento y secuencia' AS prueba,
       pasos = [[1, 'Esperar a tener toda la información antes de responder'], [2, 'Minimizar el problema'],
                [1, 'Responder de inmediato: disculparte y proponer una llamada'], [2, 'Proponer una nueva fecha y comprometerte a avisar']]
       AND all(c IN completos WHERE c) AS ok,
       pasos AS detalle;

// D5 · C-04 para Ana y «Comunicación efectiva»: 1 evidencia, solo el enlace vigente (no el revocado ni el expirado)
CALL {
  MATCH (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000101'})-[:GENERA]->(e:Evidencia)-[:DEMUESTRA]->(h:Habilidad {nombre: 'Comunicación efectiva'})
  MATCH (s:Simulacion)-[:TIENE]->(i:Intento)-[:PRODUCE]->(e)
  OPTIONAL MATCH (e)-[:TIENE_COMPARTICION]->(c:Comparticion)
    WHERE c.estado = 'ACTIVA'
      AND (c.fecha_expiracion IS NULL OR c.fecha_expiracion > datetime())
  RETURN e.titulo AS evidencia, e.visibilidad AS visibilidad,
         s.titulo AS simulacion, i.fecha_fin AS fecha,
         collect(c.token) AS enlaces_vigentes
}
WITH collect([evidencia, visibilidad, simulacion, enlaces_vigentes]) AS filas
RETURN 'D5 · C-04 Ana: evidencia de «Cliente molesto por un retraso» con 1 enlace vigente' AS prueba,
       filas = [['Manejo de un cliente molesto', 'PRIVADA', 'Cliente molesto por un retraso', ['tok-ejemplo-vigente']]] AS ok,
       filas AS detalle;

// D6 · C-05 para Ana y «Comunicación efectiva»: 3 intentos completados en orden; el EN_CURSO no cuenta
CALL {
  MATCH (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000101'})-[:REALIZA]->(i:Intento {estado: 'COMPLETADO'})<-[:TIENE]-(s:Simulacion)-[d:DESARROLLA]->(h:Habilidad {nombre: 'Comunicación efectiva'})
  OPTIONAL MATCH (u)-[:TIENE_PROGRESO]->(p:Progreso)-[:CORRESPONDE_A]->(h)
  RETURN i.fecha_fin AS fecha, s.titulo AS simulacion,
         i.puntuacion AS puntuacion, d.peso AS peso,
         p.nivel_actual AS nivel_actual_consolidado
  ORDER BY fecha
}
WITH collect([simulacion, puntuacion]) AS serie, collect(DISTINCT nivel_actual_consolidado) AS nivel
RETURN 'D6 · C-05 Ana: evolución 45 → 92 → 65, nivel consolidado 78' AS prueba,
       serie = [['Cliente molesto por un retraso', 45.0], ['Cliente molesto por un retraso', 92.0], ['Tres entregas para mañana', 65.0]] AND nivel = [78.0] AS ok,
       [serie, nivel] AS detalle;

// D7 · RF-02: búsqueda de simulaciones por texto con el índice de texto completo
CALL db.index.fulltext.queryNodes('simulacion_texto', 'cliente') YIELD node
WITH collect(node.titulo) AS titulos
RETURN 'D7 · RF-02 búsqueda por texto encuentra «Cliente molesto por un retraso»' AS prueba,
       'Cliente molesto por un retraso' IN titulos AS ok, titulos AS detalle;

// ======================= E. Escrituras validadas (entregable 4) ======

// E1 · RI-10 + RI-22: intento de registrar una respuesta con un paso de OTRA simulación → no crea nada
//      (Cypher de referencia del entregable 4, con parámetros sustituidos)
MATCH (s:Simulacion)-[:TIENE]->(i:Intento {id_intento: 'e0000000-0000-4000-8000-000000000704', estado: 'EN_CURSO'})
MATCH (s)-[:CONTIENE]->(p:Paso {id_paso: 'e0000000-0000-4000-8000-000000000401'})-[:OFRECE]->(o:Opcion {id_opcion: 'e0000000-0000-4000-8000-000000000501'})
OPTIONAL MATCH (i)-[:REGISTRA]->(previa:Respuesta)
WITH i, p, o, coalesce(max(previa.secuencia), 0) + 1 AS siguiente
CREATE (i)-[:REGISTRA]->(r:Respuesta {id_respuesta: randomUUID(), fecha_respuesta: datetime(), secuencia: siguiente})
CREATE (r)-[:CORRESPONDE_A]->(p)
CREATE (r)-[:SELECCIONA]->(o)
RETURN r.id_respuesta AS id_respuesta, r.secuencia AS secuencia;

MATCH (i:Intento {id_intento: 'e0000000-0000-4000-8000-000000000704'})
RETURN 'E1 · RI-10 rechaza una respuesta con un paso de otra simulación' AS prueba,
       COUNT { (i)-[:REGISTRA]->() } = 0 AS ok, toString(COUNT { (i)-[:REGISTRA]->() }) + ' respuestas en el intento' AS detalle;

// E2 · RI-10 + RI-16: una respuesta válida se crea con secuencia 1 y queda bien enlazada
MATCH (s:Simulacion)-[:TIENE]->(i:Intento {id_intento: 'e0000000-0000-4000-8000-000000000704', estado: 'EN_CURSO'})
MATCH (s)-[:CONTIENE]->(p:Paso {id_paso: 'e0000000-0000-4000-8000-000000000404'})-[:OFRECE]->(o:Opcion {id_opcion: 'e0000000-0000-4000-8000-000000000508'})
OPTIONAL MATCH (i)-[:REGISTRA]->(previa:Respuesta)
WITH i, p, o, coalesce(max(previa.secuencia), 0) + 1 AS siguiente
CREATE (i)-[:REGISTRA]->(r:Respuesta {id_respuesta: randomUUID(), fecha_respuesta: datetime(), secuencia: siguiente})
CREATE (r)-[:CORRESPONDE_A]->(p)
CREATE (r)-[:SELECCIONA]->(o)
RETURN r.id_respuesta AS id_respuesta, r.secuencia AS secuencia;

MATCH (i:Intento {id_intento: 'e0000000-0000-4000-8000-000000000704'})-[:REGISTRA]->(r:Respuesta)-[:SELECCIONA]->(o:Opcion)
WITH i.fecha_inicio AS inicio, r, NOT EXISTS { (o)-[:CONDUCE_A]->() } AS terminal
RETURN 'E2 · respuesta válida creada con secuencia 1 y fecha dentro del intento' AS prueba,
       count(r) = 1 AND min(r.secuencia) = 1 AND min(r.fecha_respuesta) >= min(inicio) AND all(t IN collect(terminal) WHERE t) AS ok,
       toString(count(r)) + ' respuesta(s), secuencia ' + toString(min(r.secuencia)) AS detalle;

// La respuesta de E2 tiene un id aleatorio (no lleva el prefijo de ejemplo): se retira aquí
MATCH (:Intento {id_intento: 'e0000000-0000-4000-8000-000000000704'})-[:REGISTRA]->(r:Respuesta)
DETACH DELETE r;

// E3 · RI-08: repetir el MERGE de DESARROLLA no duplica la relación
MATCH (s:Simulacion {id_simulacion: 'e0000000-0000-4000-8000-000000000301'}), (h:Habilidad {id_habilidad: 'e0000000-0000-4000-8000-000000000201'})
MERGE (s)-[d:DESARROLLA]->(h)
SET d.peso = 0.6, d.nivel_esperado = 70;

MATCH (:Simulacion {id_simulacion: 'e0000000-0000-4000-8000-000000000301'})-[d:DESARROLLA]->(:Habilidad {id_habilidad: 'e0000000-0000-4000-8000-000000000201'})
WITH count(d) AS v
RETURN 'E3 · RI-08 MERGE mantiene una sola DESARROLLA por par' AS prueba, v = 1 AS ok, toString(v) + ' relación(es)' AS detalle;

// E4 · RI-19: no se puede iniciar un intento de una simulación en BORRADOR
MATCH (u:Usuario {id_usuario: 'e0000000-0000-4000-8000-000000000102'}),
      (s:Simulacion {id_simulacion: 'e0000000-0000-4000-8000-000000000303', estado: 'PUBLICADA'})
CREATE (u)-[:REALIZA]->(:Intento {id_intento: 'e0000000-0000-4000-8000-000000000799', fecha_inicio: datetime(), estado: 'EN_CURSO'})<-[:TIENE]-(s);

MATCH (s:Simulacion {id_simulacion: 'e0000000-0000-4000-8000-000000000303'})
RETURN 'E4 · RI-19 sin intentos sobre una simulación en BORRADOR' AS prueba,
       COUNT { (s)-[:TIENE]->(:Intento) } = 0 AS ok, toString(COUNT { (s)-[:TIENE]->(:Intento) }) + ' intentos' AS detalle;

// E5 · Después de las escrituras de prueba el grafo sigue con 51 nodos y 71 relaciones
MATCH (n) WITH count(n) AS nodos
MATCH ()-[r]->() WITH nodos, count(r) AS rels
RETURN 'E5 · las escrituras de prueba no dejaron restos' AS prueba, nodos = 51 AND rels = 71 AS ok,
       toString(nodos) + ' nodos, ' + toString(rels) + ' relaciones' AS detalle;
