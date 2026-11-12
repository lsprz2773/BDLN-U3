# Entregable 1. Tabla de requerimientos y consultas

**Proyecto:** QATO'K, sistema de simulación y aprendizaje de habilidades profesionales mediante experiencias interactivas.
**Fuente:** grafo de conocimiento del proyecto (KG v1.1).

QATO'K permite que estudiantes universitarios próximos a egresar y recién egresados practiquen situaciones laborales mediante simulaciones. En ellas toman decisiones, ven sus consecuencias, reciben retroalimentación y generan evidencias de las habilidades que demuestran. Los requerimientos y consultas siguientes se derivan de las necesidades de ese usuario objetivo.

## 1. Requerimientos funcionales

| ID | Requerimiento | Descripción | Necesidad o problema que atiende | Entidades principales |
|---|---|---|---|---|
| RF-01 | Gestión de usuarios | El sistema debe permitir registrar usuarios, iniciar sesión y administrar sus cuentas. | Necesidad de privacidad y control sobre la información; base para personalizar el progreso | Usuario |
| RF-02 | Gestión de escenarios | El sistema debe permitir consultar y seleccionar simulaciones profesionales disponibles. | Practicar situaciones laborales realistas (formación predominantemente teórica) | Simulacion, Habilidad |
| RF-03 | Desarrollo de simulaciones | El sistema debe presentar situaciones laborales y permitir avanzar mediante respuestas y decisiones del usuario. | Tomar decisiones con información incompleta; enfrentar tareas ambiguas y fechas límite; practicar comunicación y resolución de conflictos | Simulacion, Paso, Opcion, Intento |
| RF-04 | Gestión de decisiones | El sistema debe registrar las decisiones tomadas y presentar sus consecuencias. | Pocas oportunidades de practicar decisiones bajo incertidumbre; preferencia por decisiones con consecuencias | Respuesta, Opcion, Consecuencia |
| RF-05 | Retroalimentación personalizada | El sistema debe explicar los aciertos, errores y acciones de mejora después de las decisiones. | Recibir retroalimentación específica (ausencia de retroalimentación sobre el desempeño) | Respuesta, Retroalimentacion |
| RF-06 | Seguimiento del progreso | El sistema debe registrar los resultados y la evolución de las habilidades del usuario. | Visualizar su progreso | Usuario, Progreso, Habilidad, Intento |
| RF-07 | Identificación de fortalezas y áreas de mejora | El sistema debe identificar las habilidades desarrolladas y aquellas que requieren fortalecimiento. | Identificar fortalezas y áreas de mejora | Progreso, Habilidad |
| RF-08 | Generación de evidencias | El sistema debe permitir generar evidencias de habilidades demostradas durante las simulaciones. | Obtener evidencias de habilidades demostradas (falta de experiencia formal; dificultad para comunicar competencias) | Evidencia, Habilidad, Intento |
| RF-09 | Control de privacidad | El sistema debe permitir al usuario controlar qué evidencias y resultados comparte y con quién. | Necesidad de privacidad y control sobre la información que comparte | Evidencia, Comparticion |
| RF-10 | Acceso flexible | El sistema debe permitir realizar sesiones cortas y facilitar el uso desde dispositivos móviles. | Tiempo limitado, uso frecuente del móvil y conectividad posiblemente limitada | Usuario, Intento, Respuesta, Simulacion |

## 2. Consultas que el sistema debe resolver

| ID | Consulta | Entidades involucradas | N.º de entidades | RF relacionados |
|---|---|---|---|---|
| C-01 | ¿Qué simulaciones tiene disponibles un usuario según su progreso y las habilidades que necesita fortalecer? | Usuario, Progreso, Habilidad, Simulacion | 4 | RF-02, RF-06, RF-07 |
| C-02 | ¿Cuáles son las fortalezas y áreas de mejora de un usuario según los resultados de sus simulaciones? | Usuario, Intento, Respuesta, Retroalimentacion, Progreso, Habilidad, Simulacion | 7 | RF-05, RF-06, RF-07 |
| C-03 | ¿Qué decisiones tomó un usuario durante una simulación, qué consecuencias obtuvo y qué retroalimentación recibió? | Usuario, Simulacion, Intento, Respuesta, Paso, Opcion, Consecuencia, Retroalimentacion | 8 | RF-03, RF-04, RF-05 |
| C-04 | ¿Qué evidencias puede compartir un usuario para demostrar una habilidad y en qué simulaciones las obtuvo? | Usuario, Evidencia, Habilidad, Intento, Simulacion, Comparticion | 6 | RF-08, RF-09 |
| C-05 | ¿Cómo ha evolucionado una habilidad a lo largo del tiempo y qué simulaciones contribuyeron a su desarrollo? | Usuario, Progreso, Habilidad, Intento, Simulacion | 5 | RF-06 |

**Cumplimiento del enunciado:** las cinco consultas recorren relaciones entre 3 o más entidades (de 4 a 8). Se exigían al menos dos.

## 3. Recorrido de cada consulta en el grafo

Los patrones siguientes, escritos en Cypher (el lenguaje de consulta de Neo4j), muestran que cada consulta se resuelve recorriendo relaciones del modelo. Los parámetros se indican con `$`.

### C-01. Simulaciones recomendadas según el progreso

```cypher
MATCH (u:Usuario {id_usuario: $idUsuario})
MATCH (s:Simulacion {estado: 'PUBLICADA'})-[d:DESARROLLA]->(h:Habilidad)
OPTIONAL MATCH (u)-[:TIENE_PROGRESO]->(p:Progreso)-[:CORRESPONDE_A]->(h)
WITH s, h, d, coalesce(p.nivel_actual, 0) AS nivel
WHERE nivel < d.nivel_esperado
RETURN s.titulo AS simulacion,
       collect(h.nombre) AS habilidades_a_fortalecer,
       sum(d.peso * (d.nivel_esperado - nivel)) AS prioridad
ORDER BY prioridad DESC
```

Recorrido: Usuario → Progreso → Habilidad ← Simulacion. Una habilidad sin progreso registrado (usuario nuevo) cuenta con nivel 0.

### C-02. Fortalezas y áreas de mejora

```cypher
MATCH (u:Usuario {id_usuario: $idUsuario})-[:TIENE_PROGRESO]->(p:Progreso)-[:CORRESPONDE_A]->(h:Habilidad)
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
```

Recorrido: Usuario → Progreso → Habilidad, y Usuario → Intento ← Simulacion → Habilidad, con Intento → Respuesta → Retroalimentacion. Cada habilidad se clasifica comparando su progreso con el nivel objetivo de la habilidad o, si no está definido, con el mayor nivel esperado por las simulaciones que la desarrollan. Los conteos de retroalimentación explican el resultado.

### C-03. Recorrido de decisiones, consecuencias y retroalimentación

```cypher
MATCH (u:Usuario {id_usuario: $idUsuario})-[:REALIZA]->(i:Intento)<-[:TIENE]-(s:Simulacion {id_simulacion: $idSimulacion})
MATCH (i)-[:REGISTRA]->(r:Respuesta)-[:CORRESPONDE_A]->(p:Paso)
MATCH (r)-[:SELECCIONA]->(o:Opcion)
OPTIONAL MATCH (o)-[:GENERA]->(c:Consecuencia)
OPTIONAL MATCH (r)-[:GENERA]->(f:Retroalimentacion)
RETURN i.id_intento AS intento, i.fecha_inicio AS inicio, r.secuencia AS n, p.titulo AS situacion,
       o.descripcion AS decision,
       collect(DISTINCT c.descripcion) AS consecuencias,
       collect(DISTINCT f.comentario) AS retroalimentacion
ORDER BY inicio, n
```

Recorrido: Usuario → Intento ← Simulacion; Intento → Respuesta → Paso; Respuesta → Opcion → Consecuencia; Respuesta → Retroalimentacion. La propiedad `secuencia` ordena las decisiones de cada intento.

### C-04. Evidencias compartibles de una habilidad

```cypher
MATCH (u:Usuario {id_usuario: $idUsuario})-[:GENERA]->(e:Evidencia)-[:DEMUESTRA]->(h:Habilidad {nombre: $habilidad})
MATCH (s:Simulacion)-[:TIENE]->(i:Intento)-[:PRODUCE]->(e)
OPTIONAL MATCH (e)-[:TIENE_COMPARTICION]->(c:Comparticion)
  WHERE c.estado = 'ACTIVA'
    AND (c.fecha_expiracion IS NULL OR c.fecha_expiracion > datetime())
RETURN e.titulo AS evidencia, e.visibilidad AS visibilidad,
       s.titulo AS simulacion, i.fecha_fin AS fecha,
       collect(c.token) AS enlaces_vigentes
```

Recorrido: Usuario → Evidencia → Habilidad; Simulacion → Intento → Evidencia; Evidencia → Comparticion. Solo se consideran los enlaces vigentes (estado ACTIVA y sin expirar).

### C-05. Evolución de una habilidad

```cypher
MATCH (u:Usuario {id_usuario: $idUsuario})-[:REALIZA]->(i:Intento {estado: 'COMPLETADO'})<-[:TIENE]-(s:Simulacion)-[d:DESARROLLA]->(h:Habilidad {nombre: $habilidad})
OPTIONAL MATCH (u)-[:TIENE_PROGRESO]->(p:Progreso)-[:CORRESPONDE_A]->(h)
RETURN i.fecha_fin AS fecha, s.titulo AS simulacion,
       i.puntuacion AS puntuacion, d.peso AS peso,
       p.nivel_actual AS nivel_actual_consolidado
ORDER BY fecha
```

Recorrido: Usuario → Intento ← Simulacion → Habilidad, y Usuario → Progreso → Habilidad. La serie de intentos completados, ordenada por fecha, muestra la evolución. El progreso consolidado da el nivel actual.

## 4. Matriz de trazabilidad requerimientos–consultas

| Requerimiento | C-01 | C-02 | C-03 | C-04 | C-05 | Cobertura sin consulta |
|---|---|---|---|---|---|---|
| RF-01 | ✔ | ✔ | ✔ | ✔ | ✔ | Toda consulta parte de un usuario registrado |
| RF-02 | ✔ | | | | | |
| RF-03 | | | ✔ | | | Navegación por los pasos mediante CONDUCE_A |
| RF-04 | | | ✔ | | | |
| RF-05 | | ✔ | ✔ | | | |
| RF-06 | ✔ | ✔ | | | ✔ | |
| RF-07 | ✔ | ✔ | | | | |
| RF-08 | | | | ✔ | | |
| RF-09 | | | | ✔ | | |
| RF-10 | | | | | | Duración estimada de las simulaciones y reanudación de intentos desde la última respuesta |

## 5. Notas y limitaciones

- **C-02:** el desempeño se atribuye a cada habilidad a través de la simulación (relación DESARROLLA) y del progreso consolidado, no por decisión individual. Medir cada habilidad por decisión requeriría definir el cálculo del nivel de habilidad (P-03, pendiente).
- **C-05:** la evolución se aproxima con los intentos completados y su puntuación. El modelo guarda un único progreso consolidado por habilidad (RI-13) y el historial de mediciones está pendiente (P-07).
- **RF-09:** compartir resultados se hace a través de evidencias. El destinatario de una compartición es una *propuesta* (`Comparticion.destinatario`) ligada a P-06.
- **RF-10:** un intento en curso se reanuda desde la respuesta con mayor `secuencia`; no se requiere un estado de pausa.
- La gestión de roles y la autoría y publicación de simulaciones quedan fuera del alcance actual (P-09, P-10).
