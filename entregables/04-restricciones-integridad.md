# Entregable 4. Tabla de restricciones de integridad

**Proyecto:** QATO'K · **Fuente:** KG v1.1 · **Base de datos principal:** Neo4j

## 1. Cobertura de las categorías del enunciado

| Categoría | Restricciones | Total |
|---|---|---|
| Unicidad de identificadores | RI-01, RI-02, RI-03, RI-08, RI-13, RI-15, RI-16, RI-18 | 8 |
| Propiedades obligatorias | RI-01, RI-04 | 2 |
| Valores permitidos | RI-05, RI-06, RI-07, RI-16, RI-18, RI-21, RI-24 | 7 |
| Consistencia entre entidades | RI-09, RI-10, RI-11, RI-14, RI-20, RI-22 | 6 |
| Reglas de negocio | RI-12, RI-15, RI-17, RI-19, RI-22, RI-23, RI-25 | 7 |

Hay 25 restricciones (se pedían al menos 8) y las cinco categorías están cubiertas. Algunas restricciones pertenecen a dos categorías. En "Unicidad de identificadores" se incluyen también las unicidades compuestas: RI-08 y RI-13 (un par de nodos) y RI-16 y RI-18 (una posición dentro de un intento o una simulación). Todas ellas identifican de forma única una relación o una posición.

## 2. Restricciones

**Mecanismo en Neo4j:**
- **[N]** restricción nativa disponible en cualquier edición.
- **[E]** restricción nativa disponible solo en Neo4j Enterprise; en la edición Community se valida en la aplicación.
- **[A]** validación en la lógica de aplicación, dentro de la misma transacción que la escritura.

**Estado:**
- **Definida:** existía en el KG v1.0.
- **Adoptada:** se añadió al resolver la auditoría del KG.
- ***Propuesta*:** depende de una decisión pendiente.

| ID | Restricción | Categoría | Descripción | Elementos afectados | Mecanismo en Neo4j | Estado |
|---|---|---|---|---|---|---|
| RI-01 | Unicidad de identificadores | Unicidad de identificadores; Propiedades obligatorias | Todas las entidades deben tener un identificador UUID único y obligatorio. | `id_…` de las 12 etiquetas | [N] restricción de unicidad por etiqueta; [E] existencia de la propiedad | Definida |
| RI-02 | Correo único | Unicidad de identificadores | No pueden existir dos usuarios con el mismo correo, sin distinguir mayúsculas de minúsculas. | Usuario.correo | [A] normalizar con `toLower(trim(...))` antes de escribir + [N] unicidad sobre el valor normalizado | Definida |
| RI-03 | Nombre de habilidad único | Unicidad de identificadores | No pueden existir dos habilidades con el mismo nombre. | Habilidad.nombre | [N] restricción de unicidad | Definida |
| RI-04 | Propiedades obligatorias | Propiedades obligatorias | Las propiedades marcadas como obligatorias en el diccionario (entregable 2) no admiten valor nulo. | Todas las propiedades obligatorias | [E] restricción de existencia; en Community, [A] validación antes de escribir | Definida |
| RI-05 | Dificultad y estado de simulación | Valores permitidos | `dificultad` ∈ {BASICA, INTERMEDIA, AVANZADA}; `estado` ∈ {BORRADOR, PUBLICADA, INACTIVA}. | Simulacion.dificultad, Simulacion.estado | [A] Neo4j no tiene restricciones CHECK; [E] restricción de tipo (solo garantiza que sea texto) | Definida |
| RI-06 | Estado y puntuación del intento | Valores permitidos | `estado` ∈ {EN_CURSO, COMPLETADO, ABANDONADO}; `puntuacion` entre 0 y 100. | Intento.estado, Intento.puntuacion | [A] validación de dominio; [E] restricción de tipo | Definida |
| RI-07 | Rango del progreso | Valores permitidos | `nivel_actual` entre 0 y 100. | Progreso.nivel_actual | [A] validación de dominio | Definida |
| RI-08 | Relación simulación–habilidad única | Unicidad de identificadores | Entre una simulación y una habilidad solo puede existir una relación DESARROLLA. | DESARROLLA (R04) | [A] crear siempre con `MERGE` (Neo4j no ofrece unicidad de pares de nodos) | Definida |
| RI-09 | Integridad de intentos | Consistencia entre entidades | Todo intento pertenece a un usuario y a una simulación existentes. | Intento, REALIZA (R01), TIENE (R02) | [A] crear el intento y sus dos relaciones en la misma transacción (Neo4j no puede exigir relaciones obligatorias) | Definida |
| RI-10 | Consistencia de respuestas | Consistencia entre entidades | La opción seleccionada pertenece al paso respondido, y ese paso pertenece a la simulación del intento. | Respuesta, R02, R03, R05, R08, R09, R10 | [A] la escritura solo procede si el patrón completo existe (ver sección 4) | Definida |
| RI-11 | Consistencia de rutas | Consistencia entre entidades | El paso siguiente de una opción pertenece a la misma simulación que el paso de origen. | CONDUCE_A (R07), R03, R05 | [A] validación al crear la relación CONDUCE_A | Definida |
| RI-12 | Consistencia temporal de intentos | Reglas de negocio | `fecha_fin` no puede ser anterior a `fecha_inicio`; un intento COMPLETADO debe tener `fecha_fin`. | Intento.fecha_inicio, fecha_fin, estado | [A] validación al cambiar de estado | Definida |
| RI-13 | Un progreso por habilidad | Unicidad de identificadores | Cada usuario tiene un único progreso consolidado por habilidad. | Progreso, TIENE_PROGRESO (R12), CORRESPONDE_A (R13) | [A] `MERGE` del patrón usuario–progreso–habilidad dentro de una transacción | Definida |
| RI-14 | Propiedad de evidencias | Consistencia entre entidades | La evidencia y el intento que la originó pertenecen al mismo usuario. | Evidencia, R01, R14, R15 | [A] crear la evidencia a partir del patrón `(u)-[:REALIZA]->(i)` del mismo usuario | Definida |
| RI-15 | Seguridad de compartición | Unicidad de identificadores; Reglas de negocio | El token es único. Una evidencia PRIVADA no puede consultarse mediante un enlace sin una autorización vigente (compartición ACTIVA y sin expirar). El dueño siempre puede consultarla. | Comparticion.token, estado, fecha_expiracion; Evidencia.visibilidad; TIENE_COMPARTICION (R17) | [N] unicidad del token + [A] comprobación de vigencia en cada acceso | Definida |
| RI-16 | Secuencia de respuestas | Unicidad de identificadores; Valores permitidos | `secuencia` ≥ 1 y única dentro de cada intento. | Respuesta.secuencia, REGISTRA (R08) | [A] calcular `max(secuencia) + 1` en la misma transacción (ver sección 4) | Adoptada (DEC-01) |
| RI-17 | Contenido mínimo de una simulación publicada | Reglas de negocio | Para publicar una simulación: al menos un paso, al menos una habilidad en DESARROLLA, al menos una opción en cada paso y al menos una consecuencia en cada opción. | Simulacion.estado, R03, R04, R05, R06 | [A] validación al pasar a PUBLICADA | Adoptada (DEC-02) |
| RI-18 | Orden de los pasos | Unicidad de identificadores; Valores permitidos | `orden` > 0 y único dentro de su simulación; el paso con `orden = 1` es el inicial. | Paso.orden, CONTIENE (R03) | [A] validación de dominio | Adoptada (DEC-03) |
| RI-19 | Intentos solo sobre simulaciones publicadas | Reglas de negocio | Solo se crean intentos de simulaciones en estado PUBLICADA. | Intento, Simulacion.estado, TIENE (R02) | [A] validación al iniciar el intento | Adoptada (DEC-11) |
| RI-20 | Habilidades demostrables | Consistencia entre entidades | Las habilidades que DEMUESTRA una evidencia deben estar entre las que DESARROLLA la simulación del intento que la produjo. | DEMUESTRA (R16), PRODUCE (R15), TIENE (R02), DESARROLLA (R04) | [A] validación al crear DEMUESTRA | Adoptada (DEC-11) |
| RI-21 | Vigencia de compartición | Valores permitidos | `fecha_expiracion`, si existe, debe ser posterior a `fecha_creacion`. | Comparticion.fecha_creacion, fecha_expiracion | [A] validación de dominio | Adoptada (DEC-11) |
| RI-22 | Consistencia temporal y de estado de respuestas | Consistencia entre entidades; Reglas de negocio | `fecha_respuesta` está entre `fecha_inicio` y `fecha_fin` (si existe) del intento. Solo se registran respuestas en intentos EN_CURSO. | Respuesta.fecha_respuesta, Intento.estado, REGISTRA (R08) | [A] la escritura filtra `estado = 'EN_CURSO'` (ver sección 4) | Adoptada (DEC-11) |
| RI-23 | Finalización por opción terminal | Reglas de negocio | Un intento pasa a COMPLETADO cuando la respuesta selecciona una opción sin CONDUCE_A. | Intento.estado, fecha_fin, REGISTRA (R08), SELECCIONA (R10), CONDUCE_A (R07) | [A] después de registrar la respuesta, comprobar si la opción es terminal | Adoptada (DEC-03) |
| RI-24 | Valores permitidos propuestos | Valores permitidos | Las propiedades con catálogo propuesto (entregable 2) solo admiten sus valores; `peso` en (0, 1]; `nivel_esperado` y `nivel_objetivo` entre 0 y 100; `duracion_estimada` > 0. | Usuario.estado, Paso.tipo, Consecuencia.impacto/tipo, Retroalimentacion.tipo, Evidencia.visibilidad, Comparticion.estado, DESARROLLA, Habilidad.nivel_objetivo, Simulacion.duracion_estimada | [A] validación de dominio; [E] restricción de tipo | *Propuesta* (P-03, P-04, P-06, P-08, P-09, P-10) |
| RI-25 | Evidencias de intentos completados | Reglas de negocio | Solo se genera una evidencia a partir de un intento COMPLETADO. | Evidencia, PRODUCE (R15), Intento.estado | [A] validación al generar la evidencia | *Propuesta* (P-05) |

## 3. Qué garantiza Neo4j por sí mismo y qué no

- **Unicidad** de propiedades: nativa en cualquier edición. Cubre RI-01, RI-03, el token de RI-15 y el correo normalizado de RI-02.
- **Existencia** (propiedad obligatoria), **tipo** y **clave** (unicidad + existencia): nativas solo en la edición Enterprise. La restricción de tipo existe desde Neo4j 5.9.
- **No existen** en Neo4j restricciones CHECK (rangos y catálogos), relaciones obligatorias, ni unicidad de pares de nodos. Por eso las reglas de valores, de consistencia entre entidades y de negocio se aplican en la lógica de aplicación, siempre dentro de la misma transacción que la escritura. Así una operación incompleta se revierte por completo.
- La arquitectura ya contempla esta limitación del grafo ("las restricciones de integridad complejas pueden necesitar validaciones adicionales"). PostgreSQL, la base complementaria, sí ofrece CHECK, UNIQUE y NOT NULL para los datos que se le asignen (P-01).

Fuentes sobre las ediciones: *Cypher Manual* de Neo4j (Constraints, versiones 5 y 4.4) y el curso de GraphAcademy sobre restricciones.

## 4. Implementación de referencia

### Restricciones nativas (cualquier edición)

```cypher
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
CREATE CONSTRAINT usuario_correo IF NOT EXISTS FOR (n:Usuario) REQUIRE n.correo IS UNIQUE;
CREATE CONSTRAINT habilidad_nombre IF NOT EXISTS FOR (n:Habilidad) REQUIRE n.nombre IS UNIQUE;
CREATE CONSTRAINT comparticion_token IF NOT EXISTS FOR (n:Comparticion) REQUIRE n.token IS UNIQUE;
```

### Restricciones solo de la edición Enterprise (ejemplos)

```cypher
// RI-04: propiedad obligatoria
CREATE CONSTRAINT usuario_correo_existe IF NOT EXISTS FOR (n:Usuario) REQUIRE n.correo IS NOT NULL;
CREATE CONSTRAINT respuesta_secuencia_existe IF NOT EXISTS FOR (n:Respuesta) REQUIRE n.secuencia IS NOT NULL;
// RI-24 / RI-18: tipo de la propiedad (Neo4j 5.9 o superior)
CREATE CONSTRAINT paso_orden_entero IF NOT EXISTS FOR (n:Paso) REQUIRE n.orden IS :: INTEGER;
```

### Validación en la transacción: registrar una respuesta (RI-10, RI-16, RI-22)

```cypher
MATCH (s:Simulacion)-[:TIENE]->(i:Intento {id_intento: $idIntento, estado: 'EN_CURSO'})
MATCH (s)-[:CONTIENE]->(p:Paso {id_paso: $idPaso})-[:OFRECE]->(o:Opcion {id_opcion: $idOpcion})
OPTIONAL MATCH (i)-[:REGISTRA]->(previa:Respuesta)
WITH i, p, o, coalesce(max(previa.secuencia), 0) + 1 AS siguiente
CREATE (i)-[:REGISTRA]->(r:Respuesta {id_respuesta: randomUUID(), fecha_respuesta: datetime(), secuencia: siguiente})
CREATE (r)-[:CORRESPONDE_A]->(p)
CREATE (r)-[:SELECCIONA]->(o)
RETURN r.id_respuesta AS id_respuesta, r.secuencia AS secuencia
```

Si el intento no está EN_CURSO, o la opción no pertenece al paso, o el paso no pertenece a la simulación del intento, los `MATCH` no encuentran nada y no se crea ninguna respuesta. Un usuario responde un paso a la vez. Si la aplicación permitiera enviar respuestas simultáneas del mismo intento, debería procesarlas una tras otra para que dos respuestas no obtengan la misma `secuencia`.

### Validación en la transacción: vincular una habilidad a una simulación (RI-08)

```cypher
MATCH (s:Simulacion {id_simulacion: $idSimulacion}), (h:Habilidad {id_habilidad: $idHabilidad})
MERGE (s)-[d:DESARROLLA]->(h)
SET d.peso = $peso, d.nivel_esperado = $nivelEsperado
```

`MERGE` crea la relación solo si no existe entre ese par de nodos; si ya existe, la reutiliza y actualiza sus propiedades. Así nunca hay dos relaciones DESARROLLA entre la misma simulación y la misma habilidad.

## 5. Restricciones que quedan pendientes

Dependen de cómo se modelen formalmente las ramificaciones (P-04):
- Si se permiten ciclos entre pasos y, por tanto, si un intento puede responder dos veces el mismo paso. Por eso no se restringe una respuesta por par (intento, paso).
- Si todo paso debe ser alcanzable desde el paso inicial (`orden = 1`).
