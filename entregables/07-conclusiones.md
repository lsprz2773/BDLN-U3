# Entregable 7. Conclusiones

**Proyecto:** QATO'K · Se basa en los entregables 1 a 6.

## 1. ¿Por qué no es suficiente identificar las entidades de una aplicación para construir una base de datos orientada a grafos?

Identificar las entidades solo dice **qué nodos** existirán. En una base de datos orientada a grafos, el valor está en **cómo se conectan esos nodos**, y eso no se deduce de la lista de entidades. Para QATO'K, las 12 entidades fueron el punto de partida, pero el modelo quedó definido por decisiones que la lista no contenía:

1. **Las relaciones son el modelo.** Con las mismas 12 entidades se definieron 17 relaciones de 14 tipos, cada una con nombre, dirección y significado propios. La característica central del producto, que una decisión lleve a distintas situaciones, no está en ninguna entidad. Está en la relación `(Opcion)-[:CONDUCE_A]->(Paso)`, que forma las ramificaciones de cada simulación (MD-03). Sin ella, `Paso` y `Opcion` serían solo listas.

2. **Hay que decidir qué es nodo, qué es relación y qué es propiedad.** La lista de entidades no lo dice:
   - La asociación entre simulación y habilidad se modeló como una **relación con propiedades**, `DESARROLLA {peso, nivel_esperado}` (MD-01), en lugar de un nodo intermedio.
   - La decisión del usuario se modeló como un **nodo** `Respuesta` (MD-04), porque debe conectarse a la vez con el intento, el paso, la opción elegida y la retroalimentación. Una sola relación solo puede unir dos nodos.
   - `Progreso` se mantuvo como nodo para poder ampliarlo con un historial (MD-02).

3. **Las claves foráneas se convierten en relaciones, y eso cambia las entidades.** Al pasar del modelo relacional al grafo, las 15 claves foráneas se volvieron relaciones. `Respuesta` quedó con solo dos propiedades y hubo que añadir `secuencia` (DEC-01), que además ordena el recorrido del usuario aunque las respuestas se sincronicen con retraso por mala conectividad.

4. **Neo4j no impone un esquema por sí mismo.** Nada impide crear un `Intento` sin usuario o una `Opcion` sin consecuencias. Si no se definen las restricciones y las cardinalidades, la base acepta nodos huérfanos y datos contradictorios. Las entidades no dicen cuáles relaciones son obligatorias. Eso lo dice el análisis de cardinalidades: 9 de las 12 entidades dependen de al menos una relación obligatoria (entregable 5).

5. **Las ambigüedades aparecen al pensar en recorridos, no al listar entidades.** Al revisar el modelo se detectaron problemas que una lista de entidades nunca habría mostrado:
   - La contradicción entre la cardinalidad de R06 y OBS-03 (DEC-02).
   - Cómo terminan las rutas de una simulación (DEC-03).
   - Que dos consultas necesitaban `Simulacion` para poder responderse (DEC-05, DEC-23).

En resumen, las entidades son el vocabulario del modelo. La base de datos de grafos necesita además su gramática: relaciones con dirección y significado, la decisión entre nodo, relación o propiedad, y las reglas que mantienen el grafo coherente.

## 2. Cómo influyen las consultas, las restricciones de integridad y las cardinalidades en las decisiones de modelado

### Las consultas

En un grafo se modela para recorrer, así que las consultas que el sistema debe resolver determinan qué relaciones existen y hacia dónde apuntan.

- **Definen caminos y atajos.** C-03 (reconstruir las decisiones de un usuario) justificó representar cada decisión como nodo `Respuesta` con `secuencia` y mantener la relación directa `(Respuesta)-[:CORRESPONDE_A]->(Paso)`. Esa relación podría deducirse pasando por la opción, pero se conserva para acceder directamente al paso (entregable 3, nota 3).
- **Revelan lo que falta.** Al escribir C-04 como recorrido se vio que preguntar "en qué simulaciones" exige pasar por `Intento` hasta `Simulacion` (DEC-05). C-02 mostró que el modelo atribuye el desempeño a una habilidad por simulación y no por decisión individual (LIM-01). C-05 mostró que un único progreso consolidado no guarda la evolución en el tiempo (LIM-02, P-07).
- **Validan el modelo.** Las cinco consultas se resuelven recorriendo de 3 a 7 relaciones del diagrama (entregable 6). `Habilidad` funciona como el nodo que conecta el contenido, la ejecución y los resultados, y eso es lo que hace cortas las consultas de recomendación, fortalezas y evidencias.

### Las restricciones de integridad

Las restricciones obligan a decidir qué garantiza la base de datos y qué debe garantizar la aplicación, y a veces cambian el propio modelo.

- **Neo4j garantiza poco de forma nativa.** La unicidad de propiedades está disponible en cualquier edición. La existencia y el tipo de las propiedades solo en la edición Enterprise. Las restricciones CHECK, las relaciones obligatorias y la unicidad de pares de nodos no existen. Por eso 17 de las 25 restricciones se validan solo en la aplicación y otras 6 combinan una restricción nativa con validación en la aplicación; Neo4j garantiza por completo solo RI-03 en cualquier edición, y RI-01 únicamente en la edición Enterprise, que permite exigir la existencia del identificador. La validación se hace dentro de la misma transacción que la escritura. Por ejemplo, una respuesta solo se crea si el patrón intento–simulación–paso–opción existe completo (RI-10, entregable 4).
- **Tienen un costo que se negocia con las consultas.** Mantener relaciones redundantes como R09 y R14 acelera C-03 y C-04, pero obliga a añadir RI-10 y RI-14 para que no se contradigan con el camino largo.
- **Moldean las propiedades.** Para evitar contradicciones, `Comparticion.estado` no incluye un valor EXPIRADA. La expiración se calcula a partir de `fecha_expiracion` (DEC-09), así no existen dos fuentes de verdad para el mismo hecho. Del mismo modo, RI-08 y RI-13 llevan a crear relaciones con `MERGE` en lugar de `CREATE`.

### Las cardinalidades

Las cardinalidades deciden la forma de los elementos del grafo y las reglas de su ciclo de vida.

- **Deciden entre relación y nodo intermedio.** Las asociaciones de muchos a muchos (DESARROLLA y DEMUESTRA) son relaciones directas. En un modelo relacional habrían requerido tablas intermedias.
- **Dan significado a los mínimos.** Que CONDUCE_A sea 0..1 permite la **opción terminal**: si una opción no conduce a ningún paso, cierra el intento (DEC-03, RI-23). Que OFRECE y GENERA sean 1..N obliga a que toda situación tenga decisiones y toda decisión tenga consecuencias. Como una simulación en borrador puede estar incompleta, esos mínimos se exigen al publicarla (RI-17).
- **Determinan qué nodos dependen de otros.** Un mínimo de 1 en el lado de una entidad indica que ese nodo no puede existir solo. En Neo4j eso significa crearlo en la misma transacción que sus relaciones obligatorias (entregable 5, sección 4).
- **Marcan los límites del modelo.** El máximo de un progreso por par usuario–habilidad (RI-13) es lo que impide guardar el historial de evolución. Si se quisiera, haría falta un nodo nuevo de mediciones (P-07).

### Síntesis

Consultas, restricciones y cardinalidades no se aplican una después de otra: se revisan mutuamente. En QATO'K, analizar una consulta añadió una entidad a otra consulta (DEC-23). Revisar las cardinalidades corrigió una inconsistencia del modelo (DEC-02). Las limitaciones de las restricciones en Neo4j definieron qué reglas pasan a la aplicación. El modelo lógico resultante no es una lista de entidades: es un grafo diseñado para responder preguntas concretas sin perder la coherencia de sus datos.
