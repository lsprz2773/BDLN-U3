# Análisis de alternativas para la matriz de propiedad de datos

- **Paso del plan:** 0.1. Este documento justifica la decisión que queda en `matriz-propiedad.md` (v2).
- **Método:**
  1. Árbol de alternativas (ToT): se comparan matrices completas.
  2. Ataque a cada rama con escenarios concretos.
  3. Criterio eliminatorio (la guía) y puntuación.
  4. Ataque a la ganadora (*red team*) y riesgos residuales.
- **Fuentes:** la guía (§2.3, §3, §4.2, §5, §9) y el modelo v1.1 del KG.

## 1. Criterios

| Criterio | Qué mide | Tipo |
|---|---|---|
| **J. Justificación de las 3 bases** | ¿Pasa cada base la prueba de la guía, "si la quitamos, qué se pierde"? Debe responderse con la **naturaleza del dato**, no con "así lo repartimos" | **Eliminatorio**: si alguna base queda con J ≤ 2, la alternativa se descarta (guía §2.3) |
| E. Escrituras en varias bases | Cuántas operaciones escriben en 2 o más bases (cada una es un caso de fallo parcial) | 1–5 (5 = casi ninguna) |
| I. Integridad nativa | Cuántas reglas RI-xx puede imponer el motor sin código | 1–5 |
| R. Recuperación | ¿Se puede detectar y reparar una inconsistencia? | 1–5 |
| T. Retrabajo | Cuánto de lo ya hecho (modelo y scripts de Neo4j) se conserva | 1–5 (5 = poco retrabajo) |
| C. Simplicidad | ¿Lo pueden construir 3 personas sin piezas exóticas? | 1–5 |
| D. Demostrable | ¿Se explica y demuestra fácil en la defensa? | 1–5 |

## 2. Alternativas de reparto

### M1. Matriz v1 (la propuesta anterior)
PostgreSQL es dueño de cuentas, estados y transacciones. MongoDB es dueño del contenido de las simulaciones, de la retroalimentación entregada (colección propia) y del contenido de las evidencias. Neo4j es una proyección. La simulación se crea escribiendo en MongoDB y en PostgreSQL. El contenido se versiona.

**Ataques:**
- **Retroalimentación duplicada.** La retroalimentación de una respuesta es la de la opción elegida, y esa ya está en el contenido. Guardarla aparte es duplicación sin propósito (guía §3). Además crea una escritura en Mongo *después* del commit en PostgreSQL al responder, que es el caso de fallo parcial más frecuente de toda la aplicación.
- **Crear y editar escriben en dos bases** cuando no hace falta. Crear el registro y cargar el contenido pueden ser operaciones separadas, cada una en una sola base.
- **El versionado del contenido** (`version_contenido`) añade complejidad que ningún RF pide.
- **Justificación de MongoDB débil ante una pregunta obvia:** "¿por qué no guardar el contenido como JSONB en PostgreSQL?". La v1 no la responde con la naturaleza del dato.
- **Faltan operaciones de baja:** eliminar cuenta (RF-01, RF-09) y eliminar habilidad no tienen evento hacia el grafo.

Puntaje: J 4 · E 3 · I 4 · R 4 · T 3 · C 3 · D 4 = **25**

### M2. Grafo dueño del dominio (la arquitectura original del KG)
Neo4j es dueño de todo el dominio. PostgreSQL solo guarda usuarios y comparticiones. MongoDB solo guarda contenido y evidencias.

**Ataques:**
- **PostgreSQL no se justifica.** Si lo quitamos, los usuarios y los tokens caben en Neo4j con restricciones de unicidad. La guía lo rechaza explícitamente: "si la respuesta es ninguna, no está justificada".
- **Neo4j Community no impone existencia ni tipos** (DEC-12). RI-16 (secuencia única por intento), RI-12 y RI-22 quedan solo en código.
- Sigue habiendo réplica: el texto del contenido en Mongo y la estructura en el grafo.

Puntaje: **J 2 → descartada**. (E 3 · I 2 · R 3 · T 5 · C 4 · D 3)

### M3. El intento como documento de MongoDB
El intento y sus respuestas viven embebidos en un documento de Mongo, actualizado de forma atómica con `$push` condicionado. PostgreSQL guarda usuarios, catálogo y comparticiones.

**Ataques:**
- **Es una idea buena de verdad:** una actualización de un solo documento es atómica y resuelve RI-16.
- **Pero vacía a PostgreSQL de lo más transaccional que tiene la aplicación** (intentos y respuestas). La justificación relacional queda en "usuarios y tokens", que es débil.
- El evento hacia el grafo tendría que vivir en Mongo (otro outbox, o change streams con *replica set*): dos mecanismos de sincronización en vez de uno.
- Las reglas entre entidades (RI-09, RI-14, RI-19) quedan entre bases y sin FK.
- Los reportes de rendimiento y las agregaciones sobre intentos son más naturales en SQL.

Puntaje: J 3 · E 3 · I 3 · R 3 · T 3 · C 2 · D 4 = **21**

### M4. Contenido en tablas de PostgreSQL
Pasos, opciones y consecuencias van en tablas. MongoDB solo guarda las evidencias.

**Ataques:**
- **MongoDB no se justifica.** Una evidencia sola cabe en una columna JSONB. Falla la prueba de la guía.
- El contenido de forma variable por tipo de paso queda en columnas nulas o en tablas por tipo.

Puntaje: **J 2 → descartada**. (E 4 · I 5 · R 4 · T 3 · C 4 · D 3)

### M5. Simulación completa en MongoDB (metadatos + contenido)
Toda la simulación vive en un documento, incluido su estado y sus habilidades.

**Ataques:**
- **Publicar cruza bases:** el estado cambia en Mongo, pero el evento hacia el grafo vive en el outbox de PostgreSQL. Eso es una escritura parcial en la operación más importante del administrador, salvo que se añada un segundo outbox.
- Se pierden las FK `intento → simulacion` y `simulacion_habilidad → habilidad`. RI-08 (par único) y RI-19 quedan solo en código.

Puntaje: J 3 · E 2 · I 3 · R 3 · T 3 · C 3 · D 4 = **21**

### M6. Matriz v2: M1 corregida con los ataques anteriores
Conserva el reparto de M1 y cierra sus grietas:

1. **Invariante del outbox:** todo cambio que deba llegar al grafo nace en PostgreSQL, en la misma transacción que su evento. Hay **un solo** mecanismo de sincronización.
2. **Retroalimentación sin colección propia:** vive en la opción, dentro del contenido. El grafo solo guarda su tipo como propiedad de `Respuesta`. Responder un paso escribe **solo en PostgreSQL**.
3. **Contenido publicado inmutable:** solo se edita en BORRADOR. Eso hace segura la copia de la estructura (`CONDUCE_A`) al grafo y elimina el versionado.
4. **Una base por operación:** crear el registro escribe en PostgreSQL y cargar el contenido escribe en Mongo. Quedan solo **2 operaciones** que escriben en dos bases (eliminar un borrador y generar una evidencia), y en ambas el peor caso es un huérfano inofensivo que la reconciliación limpia.
5. **Justificación de MongoDB por la naturaleza del dato:** cada tipo de paso (CORREO, REUNION, CONVERSACION, TAREA, INCIDENTE, catálogo de `Paso.tipo`) tiene un `contexto` de forma distinta: remitente y asunto, participantes y agenda, líneas de diálogo, entregables, cronología. Un documento polimórfico y anidado que se lee y se escribe completo es el caso de uso documental por excelencia.
6. **Bajas incluidas:** eventos para eliminar usuario y habilidad.

Puntaje: J 5 · E 5 · I 4 · R 5 · T 3 · C 4 · D 5 = **31**

### Tabla de decisión del reparto

| Alternativa | J (elim.) | E | I | R | T | C | D | Total | Resultado |
|---|---|---|---|---|---|---|---|---|---|
| M1 v1 | 4 | 3 | 4 | 4 | 3 | 3 | 4 | 25 | Superada por M6 |
| M2 grafo dueño | **2** | 3 | 2 | 3 | 5 | 4 | 3 | — | **Descartada** (PostgreSQL injustificado) |
| M3 intento documento | 3 | 3 | 3 | 3 | 3 | 2 | 4 | 21 | Pierde |
| M4 contenido en SQL | **2** | 4 | 5 | 4 | 3 | 4 | 3 | — | **Descartada** (MongoDB injustificado) |
| M5 simulación en Mongo | 3 | 2 | 3 | 3 | 3 | 3 | 4 | 21 | Pierde |
| **M6 v2** | **5** | **5** | 4 | **5** | 3 | 4 | **5** | **31** | **Elegida** |

## 3. Alternativas de sincronización hacia Neo4j

| Opción | Cómo funciona | Ataque | Resultado |
|---|---|---|---|
| S1. Escritura doble síncrona | El servicio escribe en PostgreSQL y luego en Neo4j dentro de la misma petición | Si Neo4j está caído, **no se puede jugar**. Si Neo4j falla después del commit en PostgreSQL, no hay forma limpia de deshacer (no hay transacción distribuida) | Descartada |
| S2. Outbox asíncrono puro | Un proceso aplica los eventos cada N segundos | Hay un retraso visible: el usuario responde y su perfil todavía no cambia. En la demo parece un error | Insuficiente sola |
| **S3. Outbox + aplicación inmediata** | Tras el commit, el servicio **intenta** aplicar el evento de inmediato. Si lo logra, lo marca APLICADO; si no, queda PENDIENTE para el proceso de reintento | En el caso normal se ve al instante; si Neo4j cae, la app sigue funcionando y se pone al día sola | **Elegida** |
| S4. CDC (Debezium/Kafka) | Captura los cambios del log de PostgreSQL | Agrega 2 servicios más; la guía dice que no hace falta infraestructura distribuida | Descartada |
| S5. Reconstrucción completa | Se borra el grafo y se reconstruye desde PostgreSQL y Mongo | Es lenta con volumen alto y el grafo queda vacío durante la reconstrucción | **Se conserva como último recurso** (`npm run grafo:reconstruir`), no como mecanismo principal |

## 4. Ataque a la ganadora (red team de M6 + S3)

| # | Ataque | Respuesta | ¿Queda riesgo? |
|---|---|---|---|
| 1 | "El grafo es solo una caché derivada; ¿de verdad es una base justificada?" | Su responsabilidad es **recorrer conexiones** (C-01 a C-05), y además es dueño de datos propios: `Progreso` y `DEMUESTRA`. La guía pide una responsabilidad identificable, no que sea la fuente de todo | No |
| 2 | "`respuesta.id_paso` e `id_opcion` en PostgreSQL apuntan a datos de Mongo sin FK" | Es inevitable en cualquier reparto entre bases. El servicio valida RI-10 contra el contenido antes de escribir, y la reconciliación verifica que cada respuesta apunte a un paso y una opción existentes | Bajo, documentado |
| 3 | "Si un admin corrige un error de redacción en una simulación publicada, ¿no puede?" | Puede pasarla a INACTIVA y crear una nueva. Para el alcance académico es aceptable. Si hiciera falta, el texto (no la estructura) podría editarse sin afectar el grafo, porque el grafo no guarda textos | Aceptado |
| 4 | "La aplicación inmediata (S3) agrega latencia a cada respuesta" | Es 1 consulta Cypher con MERGE por id, de pocos milisegundos. Se medirá en la prueba de rendimiento | Se mide |
| 5 | "Dos eventos de la misma entidad se aplican en desorden (el inmediato y el del proceso de reintento)" | El proceso toma eventos PENDIENTE con `FOR UPDATE SKIP LOCKED` en orden de `creado_en`, y los efectos son MERGE idempotentes. `INTENTO_FINALIZADO` recalcula el progreso desde cero, no lo incrementa | No |
| 6 | "El progreso se calcula en el grafo con datos copiados: si la copia está mal, el progreso está mal" | La reconciliación compara los intentos de PostgreSQL con los del grafo antes de recalcular, y existe la reconstrucción completa | Bajo |
| 7 | "Al eliminar una cuenta quedan datos en Mongo (evidencias)" | El evento `USUARIO_ELIMINADO` borra los nodos. El servicio borra las evidencias de Mongo después del commit; si falla, quedan huérfanas y la reconciliación las elimina | No |
| 8 | "El enlace público por token lee de dos bases: ¿y si Mongo está caído?" | Responde 503 con el formato de error. Nunca se muestra una evidencia sin validar el token en PostgreSQL primero | No |
| 9 | "Con datos de prueba pequeños todo funciona; ¿y con volumen?" | La prueba de rendimiento usa un volumen generado (p. ej. 1 000 usuarios y 10 000 respuestas) y documenta el resultado | Se mide |
| 10 | "La búsqueda de simulaciones (RF-02) estaba en el grafo (D7)" | Pasa a PostgreSQL (`ILIKE` o búsqueda de texto completo sobre `titulo` y `descripcion`), que es donde viven los metadatos | No |

## 5. Decisión

Se adopta **M6 + S3**, documentada en `matriz-propiedad.md` v2. Las alternativas descartadas y sus motivos quedan aquí como evidencia de la justificación que pide la guía (§2.3: "la selección debe responder a una necesidad real del dominio").
