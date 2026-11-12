# Entregable 5. Tabla de cardinalidades

**Proyecto:** QATO'K · **Fuente:** KG v1.1 · Se basa en el catálogo de relaciones (entregable 3).

## 1. Cómo se leen las cardinalidades

Cada relación `(Origen)-[:RELACION]->(Destino)` tiene dos cardinalidades:

- **Origen → destino:** cuántos nodos destino puede tener cada nodo origen.
- **Destino → origen:** a cuántos nodos origen puede estar ligado cada nodo destino.

La notación `mín..máx` usa 0 o 1 como mínimo y 1 o N (muchos) como máximo. Por ejemplo, en R01 `(Usuario)-[:REALIZA]->(Intento)`, "0..N / 1..1" significa que un usuario realiza de 0 a muchos intentos y que cada intento pertenece exactamente a 1 usuario.

Un mínimo de **0** responde "sí" a la pregunta *¿puede existir sin relacionarse?*. Un mínimo de **1** la responde "no". Un máximo de **1** significa *una*; un máximo de **N**, *muchas*.

## 2. Cardinalidades por relación

| ID | Patrón | Origen → destino | Destino → origen | Tipo | Justificación |
|---|---|---|---|---|---|
| R01 | (Usuario)-[:REALIZA]->(Intento) | 0..N | 1..1 | 1:N | Un usuario recién registrado no tiene intentos (OBS-10) y puede repetir simulaciones (OBS-05). Todo intento es de un usuario (RI-09). |
| R02 | (Simulacion)-[:TIENE]->(Intento) | 0..N | 1..1 | 1:N | Una simulación puede no haber sido intentada todavía. Todo intento es de una simulación (RI-09). |
| R03 | (Simulacion)-[:CONTIENE]->(Paso) | 0..N (≥1 si está PUBLICADA) | 1..1 | 1:N | Un BORRADOR puede no tener pasos; una simulación PUBLICADA necesita al menos uno (OBS-11, RI-17). Cada paso pertenece a una sola simulación. |
| R04 | (Simulacion)-[:DESARROLLA]->(Habilidad) | 0..N (≥1 si está PUBLICADA) | 0..N | N:M | Una simulación desarrolla varias habilidades y una habilidad se desarrolla en varias simulaciones (OBS-08). Como máximo hay una relación por par (RI-08). |
| R05 | (Paso)-[:OFRECE]->(Opcion) | 1..N | 1..1 | 1:N | Todo paso es una decisión con al menos una opción (OBS-02). Las rutas terminan en una opción terminal, no en un paso sin opciones (DEC-03). Se exige al publicar (RI-17). |
| R06 | (Opcion)-[:GENERA]->(Consecuencia) | 1..N | 1..1 | 1:N | Toda decisión tiene al menos una consecuencia (OBS-03, DEC-02). Se exige al publicar (RI-17). |
| R07 | (Opcion)-[:CONDUCE_A]->(Paso) | 0..1 | 0..N | N:1 | Una opción lleva a un paso o a ninguno: es terminal (OBS-04, RI-23). Varias opciones pueden llevar al mismo paso, y un paso (por ejemplo, el inicial) puede no ser destino de ninguna. |
| R08 | (Intento)-[:REGISTRA]->(Respuesta) | 0..N | 1..1 | 1:N | Un intento recién iniciado no tiene respuestas. Cada respuesta pertenece a un intento. |
| R09 | (Respuesta)-[:CORRESPONDE_A]->(Paso) | 1..1 | 0..N | N:1 | Cada respuesta se da en un paso (OBS-06). Un paso puede no haber sido respondido aún o haberlo sido en muchos intentos. |
| R10 | (Respuesta)-[:SELECCIONA]->(Opcion) | 1..1 | 0..N | N:1 | Cada respuesta elige exactamente una opción (OBS-06). Una opción puede no haber sido elegida nunca. |
| R11 | (Respuesta)-[:GENERA]->(Retroalimentacion) | 0..N | 1..1 | 1:N | Una respuesta puede generar retroalimentación (OBS-07). Cada retroalimentación explica una sola respuesta. |
| R12 | (Usuario)-[:TIENE_PROGRESO]->(Progreso) | 0..N | 1..1 | 1:N | Un usuario nuevo no tiene progreso (OBS-10). Hay como máximo un progreso por habilidad (RI-13). |
| R13 | (Progreso)-[:CORRESPONDE_A]->(Habilidad) | 1..1 | 0..N | N:1 | Cada progreso mide una habilidad. Una habilidad puede no tener progreso de ningún usuario, o tener uno por usuario (RI-13). |
| R14 | (Usuario)-[:GENERA]->(Evidencia) | 0..N | 1..1 | 1:N | Un usuario puede no tener evidencias (OBS-10). Cada evidencia tiene un único dueño. |
| R15 | (Intento)-[:PRODUCE]->(Evidencia) | 0..N | 1..1 | 1:N | Un intento puede no producir evidencias. Cada evidencia proviene de un único intento, del mismo usuario que es su dueño (RI-14). |
| R16 | (Evidencia)-[:DEMUESTRA]->(Habilidad) | 1..N | 0..N | N:M | Una evidencia demuestra al menos una habilidad (OBS-09), solo entre las que desarrolla su simulación (RI-20). Una habilidad puede no estar demostrada por ninguna evidencia. |
| R17 | (Evidencia)-[:TIENE_COMPARTICION]->(Comparticion) | 0..N | 1..1 | 1:N | Una evidencia puede no compartirse (privacidad, RF-09) o compartirse varias veces. Cada compartición es de una evidencia. |

## 3. Respuesta a las preguntas del enunciado por relación

En las columnas Mínimo y Máximo, el primer valor es por cada origen y el segundo por cada destino.

| ID | Relación | ¿El origen puede existir sin esta relación? | ¿El destino puede existir sin esta relación? | ¿Una o muchas? | Mínimo | Máximo |
|---|---|---|---|---|---|---|
| R01 | REALIZA | Sí: un usuario sin intentos | No: el intento necesita un usuario | Un usuario, muchos intentos; un intento, un usuario | 0 / 1 | N / 1 |
| R02 | TIENE | Sí: una simulación sin intentos | No: el intento necesita una simulación | Una simulación, muchos intentos; un intento, una simulación | 0 / 1 | N / 1 |
| R03 | CONTIENE | Sí, solo en BORRADOR | No: el paso necesita una simulación | Una simulación, muchos pasos; un paso, una simulación | 0 (1 si está PUBLICADA) / 1 | N / 1 |
| R04 | DESARROLLA | Sí, solo en BORRADOR | Sí: una habilidad aún sin simulaciones | Muchas a muchas | 0 (1 si está PUBLICADA) / 0 | N / N (una relación por par) |
| R05 | OFRECE | No (se exige al publicar): un paso necesita al menos una opción | No: la opción necesita un paso | Un paso, muchas opciones; una opción, un paso | 1 / 1 | N / 1 |
| R06 | GENERA | No (se exige al publicar): una opción necesita al menos una consecuencia | No: la consecuencia necesita una opción | Una opción, muchas consecuencias; una consecuencia, una opción | 1 / 1 | N / 1 |
| R07 | CONDUCE_A | Sí: una opción terminal | Sí: por ejemplo, el paso inicial | Una opción, un paso como máximo; un paso, muchas opciones | 0 / 0 | 1 / N |
| R08 | REGISTRA | Sí: un intento recién iniciado | No: la respuesta necesita un intento | Un intento, muchas respuestas; una respuesta, un intento | 0 / 1 | N / 1 |
| R09 | CORRESPONDE_A | No: la respuesta necesita un paso | Sí: un paso no respondido | Una respuesta, un paso; un paso, muchas respuestas | 1 / 0 | 1 / N |
| R10 | SELECCIONA | No: la respuesta necesita una opción | Sí: una opción nunca elegida | Una respuesta, una opción; una opción, muchas respuestas | 1 / 0 | 1 / N |
| R11 | GENERA | Sí: una respuesta sin retroalimentación | No: la retroalimentación necesita una respuesta | Una respuesta, muchas retroalimentaciones; una retroalimentación, una respuesta | 0 / 1 | N / 1 |
| R12 | TIENE_PROGRESO | Sí: un usuario sin progreso | No: el progreso necesita un usuario | Un usuario, muchos progresos (uno por habilidad); un progreso, un usuario | 0 / 1 | N (n.º de habilidades) / 1 |
| R13 | CORRESPONDE_A | No: el progreso necesita una habilidad | Sí: una habilidad sin progreso | Un progreso, una habilidad; una habilidad, muchos progresos (uno por usuario) | 1 / 0 | 1 / N (n.º de usuarios) |
| R14 | GENERA | Sí: un usuario sin evidencias | No: la evidencia necesita un dueño | Un usuario, muchas evidencias; una evidencia, un usuario | 0 / 1 | N / 1 |
| R15 | PRODUCE | Sí: un intento sin evidencias | No: la evidencia necesita un intento de origen | Un intento, muchas evidencias; una evidencia, un intento | 0 / 1 | N / 1 |
| R16 | DEMUESTRA | No: una evidencia demuestra al menos una habilidad | Sí: una habilidad no demostrada | Muchas a muchas | 1 / 0 | N (habilidades de la simulación) / N |
| R17 | TIENE_COMPARTICION | Sí: una evidencia no compartida | No: la compartición necesita una evidencia | Una evidencia, muchas comparticiones; una compartición, una evidencia | 0 / 1 | N / 1 |

## 4. ¿Puede existir cada entidad sin relacionarse?

| Entidad | ¿Puede existir sin relacionarse? | Relaciones obligatorias | Justificación |
|---|---|---|---|
| Usuario | Sí | Ninguna | Un usuario recién registrado no tiene intentos, progreso ni evidencias (OBS-10). |
| Simulacion | Sí, en BORRADOR | Si está PUBLICADA: CONTIENE (≥1 paso) y DESARROLLA (≥1 habilidad) | OBS-11, RI-17. |
| Habilidad | Sí | Ninguna | Es un elemento del catálogo de competencias. Puede existir antes de asociarse a simulaciones. |
| Paso | No | CONTIENE (de 1 simulación), OFRECE (≥1 opción) | Un paso solo tiene sentido dentro de una simulación y como punto de decisión. |
| Opcion | No | OFRECE (de 1 paso), GENERA (≥1 consecuencia) | Una opción es una alternativa de un paso y siempre tiene consecuencias. |
| Consecuencia | No | GENERA (de 1 opción) | Es el resultado de una opción. |
| Intento | No | REALIZA (de 1 usuario), TIENE (de 1 simulación) | RI-09. |
| Respuesta | No | REGISTRA (de 1 intento), CORRESPONDE_A (1 paso), SELECCIONA (1 opción) | OBS-06, RI-10. |
| Retroalimentacion | No | GENERA (de 1 respuesta) | Explica una decisión concreta. |
| Progreso | No | TIENE_PROGRESO (de 1 usuario), CORRESPONDE_A (1 habilidad) | Mide una habilidad de un usuario (RI-13). |
| Evidencia | No | GENERA (de 1 usuario), PRODUCE (de 1 intento), DEMUESTRA (≥1 habilidad) | RI-14, RI-20, OBS-09. |
| Comparticion | No | TIENE_COMPARTICION (de 1 evidencia) | Controla el acceso a una evidencia. |

Hay tres entidades independientes, que pueden existir solas: Usuario, Simulacion (en borrador) y Habilidad. Las otras nueve dependen de al menos una relación obligatoria. En Neo4j esto se traduce en que esos nodos deben crearse en la misma transacción que sus relaciones obligatorias, para evitar nodos huérfanos.

## 5. Cardinalidades condicionadas y límites adicionales

| Relación | Condición o límite | Origen |
|---|---|---|
| R03, R04 | Mínimo 1 solo cuando la simulación está PUBLICADA | OBS-11, RI-17 |
| R05, R06 | Mínimo 1 exigible al publicar; durante la autoría el contenido puede estar incompleto | RI-17 |
| R04 | Máximo una relación entre cada par simulación–habilidad | RI-08 |
| R12, R13 | Máximo un progreso por par usuario–habilidad | RI-13 |
| R16 | Las habilidades demostradas son un subconjunto de las que desarrolla la simulación del intento | RI-20 |
| R07 | Una opción sin CONDUCE_A finaliza el intento | RI-23 |
| R08 | El número máximo de respuestas de un intento depende de la longitud de la ruta. Si se admiten ciclos entre pasos (pendiente, P-04), no hay un máximo fijo | P-04 |
