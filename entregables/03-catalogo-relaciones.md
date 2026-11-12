# Entregable 3. Catálogo de relaciones

**Proyecto:** QATO'K · **Fuente:** KG v1.1

## Cómo leer el catálogo

- Cada relación es **dirigida**: va de la entidad origen a la entidad destino, como en el patrón `(Origen)-[:RELACION]->(Destino)`. En Neo4j una relación se puede recorrer en ambos sentidos, pero se almacena con una sola dirección.
- **Propiedades:** datos guardados en la propia relación ("—" si no tiene).
- **Consultas y reglas que la usan:** consultas (C-xx), restricciones (RI-xx) y requerimientos (RF-xx) que recorren o protegen la relación. Sirve para comprobar que ninguna relación sobra.

## Catálogo

| ID | Entidad origen | Relación | Entidad destino | Descripción | Propiedades | Consultas y reglas que la usan |
|---|---|---|---|---|---|---|
| R01 | Usuario | REALIZA | Intento | Un usuario realiza intentos de simulación. Cada intento es la ejecución de una simulación por un único usuario. | — | C-02, C-03, C-05, RI-09, RI-14 |
| R02 | Simulacion | TIENE | Intento | Una simulación tiene los intentos que los usuarios realizan sobre ella. Cada intento corresponde a una sola simulación. | — | C-02, C-03, C-04, C-05, RI-09, RI-10, RI-19, RI-20 |
| R03 | Simulacion | CONTIENE | Paso | Una simulación contiene los pasos (situaciones laborales) que la componen. Cada paso pertenece a una sola simulación. | — | RF-03, RI-10, RI-11, RI-17, RI-18 |
| R04 | Simulacion | DESARROLLA | Habilidad | Una simulación desarrolla una habilidad profesional. El `peso` indica cuánto contribuye la simulación a la habilidad y el `nivel_esperado`, el nivel que permite alcanzar. Una habilidad puede desarrollarse en varias simulaciones. | peso, nivel_esperado | C-01, C-02, C-05, RI-08, RI-17, RI-20 |
| R05 | Paso | OFRECE | Opcion | Un paso ofrece las opciones de decisión disponibles en esa situación. Cada opción pertenece a un único paso. | — | RF-03, RI-10, RI-11, RI-17 |
| R06 | Opcion | GENERA | Consecuencia | Una opción genera las consecuencias que produce elegirla. Cada consecuencia pertenece a una única opción. | — | C-03, RF-04, RI-17 |
| R07 | Opcion | CONDUCE_A | Paso | Una opción conduce al siguiente paso de la ruta, lo que forma las ramificaciones de la simulación. Si una opción no tiene esta relación, es terminal y finaliza el intento. Varias opciones pueden conducir al mismo paso. | — | RF-03, RI-11, RI-23 |
| R08 | Intento | REGISTRA | Respuesta | Un intento registra cada respuesta (decisión) que el usuario toma durante su ejecución. Cada respuesta pertenece a un único intento. | — | C-02, C-03, RI-10, RI-16, RI-22, RI-23 |
| R09 | Respuesta | CORRESPONDE_A | Paso | Una respuesta corresponde al paso (situación) en el que se tomó la decisión. | — | C-03, RI-10 |
| R10 | Respuesta | SELECCIONA | Opcion | Una respuesta selecciona la opción que eligió el usuario. Es el vínculo entre lo que hizo el usuario y el contenido de la simulación. | — | C-03, RI-10, RI-23 |
| R11 | Respuesta | GENERA | Retroalimentacion | Una respuesta genera la retroalimentación que explica la decisión y recomienda mejoras. Cada retroalimentación se refiere a una sola respuesta. | — | C-02, C-03, RF-05 |
| R12 | Usuario | TIENE_PROGRESO | Progreso | Un usuario tiene un registro de progreso consolidado por cada habilidad que ha trabajado. | — | C-01, C-02, C-05, RI-13 |
| R13 | Progreso | CORRESPONDE_A | Habilidad | Un registro de progreso corresponde a la habilidad cuyo nivel mide. | — | C-01, C-02, C-05, RI-13 |
| R14 | Usuario | GENERA | Evidencia | Un usuario genera sus evidencias y es su dueño: decide si las comparte. | — | C-04, RI-14 |
| R15 | Intento | PRODUCE | Evidencia | Un intento produce la evidencia de lo que el usuario demostró en él. Vincula cada evidencia con la experiencia que la originó. | — | C-04, RI-14, RI-20, RI-25 |
| R16 | Evidencia | DEMUESTRA | Habilidad | Una evidencia demuestra una o varias habilidades profesionales. | — | C-04, RI-20 |
| R17 | Evidencia | TIENE_COMPARTICION | Comparticion | Una evidencia tiene comparticiones (enlaces o permisos) que controlan quién puede consultarla y hasta cuándo. | — | C-04, RF-09, RI-15, RI-21 |

**Totales:** 17 relaciones de 14 tipos distintos. Una relación tiene propiedades (DESARROLLA).

## Notas de modelado

1. **Tipos de relación reutilizados.** `GENERA` aparece en tres relaciones (R06 Opcion→Consecuencia, R11 Respuesta→Retroalimentacion, R14 Usuario→Evidencia) y `CORRESPONDE_A` en dos (R09 Respuesta→Paso, R13 Progreso→Habilidad). En Neo4j el significado queda definido por el tipo junto con las etiquetas de origen y destino, así que no hay ambigüedad en las consultas. Por ejemplo, `(:Opcion)-[:GENERA]->(:Consecuencia)` nunca coincide con `(:Usuario)-[:GENERA]->(:Evidencia)`.
2. **Lectura de `TIENE` (R02).** Se conserva el nombre y la dirección del KG. Se lee "la simulación tiene intentos realizados sobre ella". Desde el intento se recorre en sentido inverso: `(i:Intento)<-[:TIENE]-(s:Simulacion)`.
3. **Relaciones redundantes a propósito.** R09 (Respuesta→Paso) podría deducirse de R10 + R05, y R14 (Usuario→Evidencia) de R01 + R15. Se mantienen porque dan acceso directo en C-03 y C-04 y hacen explícita la propiedad de cada evidencia. A cambio, exigen las restricciones de consistencia RI-10 y RI-14.
4. **Claves foráneas.** 15 de las 17 relaciones sustituyen a una clave foránea del modelo relacional original (ver entregable 2). Las otras dos son R04 (DESARROLLA) y R16 (DEMUESTRA): relaciones de muchos a muchos que en un modelo relacional habrían necesitado una tabla intermedia (en el caso de DESARROLLA, con las columnas `peso` y `nivel_esperado`). En el grafo son relaciones directas.
5. **Fuera del modelo actual.** No existe una relación entre una decisión (Opcion o Respuesta) y una habilidad. Se registró como trabajo futuro ligado a P-03 (cálculo del nivel de habilidad).
