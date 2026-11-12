# Decisiones de modelado (resolución de la auditoría del KG)

**Fecha:** 2026-11-12
**Origen:** hallazgos H-01..H-20 de `verificacion/00-auditoria-kg.md`.
**Autoridad:** el usuario delegó estas decisiones en Claude. Cada una se tomó con el protocolo ToT → CoVe → self-consistency (`PLAN.md`, §2).
**Resultado:** las decisiones se incorporan a `docs/KG.json` **v1.1**. La versión anterior se conserva en `docs/KG-v1.0.json`.

## Clasificación de las decisiones

| Estado | Significado | En el KG v1.1 |
|---|---|---|
| **ADOPTADA** | Corrige una inconsistencia u omisión del modelo y no depende de ninguna decisión pendiente (P-xx). | Se incorpora como parte del modelo (preliminar). |
| **PROPUESTA** | Necesaria para que los entregables queden completos, pero toca una decisión pendiente P-xx. | Se incorpora con `"status": "PROPOSED"` y la P-xx relacionada. Puede cambiar. |
| **DOCUMENTADA** | No cambia el modelo; se explica en el entregable correspondiente. | Se registra en `known_limitations` / notas. |
| **DESCARTADA** | Se evaluó y no se incorpora. | No. |

## Resumen

| DEC | Hallazgo | Decisión | Estado |
|---|---|---|---|
| DEC-01 | H-01 | Añadir `Respuesta.secuencia` INTEGER obligatoria (≥1, única por intento). No se añade `tiempo_respuesta_seg`. | ADOPTADA |
| DEC-02 | H-02 | R06 `Opcion-GENERA->Consecuencia` pasa a **1..N**; exigible cuando la simulación está PUBLICADA. | ADOPTADA |
| DEC-03 | H-05 | Se mantiene R05 **1..N**. Las rutas terminan en una **opción terminal** (sin `CONDUCE_A`); no hay pasos finales. El paso inicial es el de `orden = 1`. | ADOPTADA |
| DEC-04 | H-05/H-08 | Catálogo de `Paso.tipo` = tipo de situación laboral {CORREO, REUNION, CONVERSACION, TAREA, INCIDENTE}. | PROPUESTA (P-09) |
| DEC-05 | H-03 | Añadir `Simulacion` a las entidades de C-04. | ADOPTADA |
| DEC-06 | H-04 | Añadir `Simulacion` a C-02. **No** se añade la relación `IMPACTA`; la atribución es por simulación y por `Progreso`, y se documenta la limitación. | ADOPTADA + DOCUMENTADA |
| DEC-07 | H-06 | Convención de lectura de cardinalidades declarada en el KG. | ADOPTADA |
| DEC-08 | H-07/H-10 | Escala común 0–100 para niveles: `Habilidad.nivel_objetivo` INTEGER 0–100; `DESARROLLA.nivel_esperado` INTEGER 0–100 obligatorio; `DESARROLLA.peso` DECIMAL(3,2) en (0, 1] obligatorio. | PROPUESTA (P-03, P-08) |
| DEC-09 | H-08 | Catálogos: `Usuario.estado`, `Consecuencia.impacto`, `Consecuencia.tipo`, `Retroalimentacion.tipo`, `Evidencia.visibilidad`, `Comparticion.estado`. `Habilidad.categoria` sin catálogo. | PROPUESTA (P-06, P-08, P-10) |
| DEC-10 | H-09 | Obligatoria = toda propiedad sin `nullable: true`. | ADOPTADA |
| DEC-11 | H-11 | Nuevas restricciones RI-16..RI-25. | ADOPTADA (8) / PROPUESTA (2) |
| DEC-12 | H-12 | Mecanismo por restricción: uniqueness nativa (Community); existence/type/key solo en Enterprise; el resto en lógica de aplicación/transacción. | ADOPTADA |
| DEC-13 | H-13 | Añadir `Comparticion.destinatario` VARCHAR(150) NULL. Los "resultados" se comparten mediante evidencias. | PROPUESTA (P-06) + DOCUMENTADA |
| DEC-14 | H-14 | C-05 se resuelve por aproximación (Intento + DESARROLLA); **no** se añade nodo de historial. | DOCUMENTADA |
| DEC-15 | H-15 | Mantener `TIENE` (Simulacion→Intento) por fidelidad al KG. | DOCUMENTADA |
| DEC-16 | H-16 | Mantener `GENERA` y `CORRESPONDE_A` reutilizadas; el par de etiquetas da el significado. | DOCUMENTADA |
| DEC-17 | H-17 | Mantener R09 y R14 redundantes; RI-10 y RI-14 las protegen. | DOCUMENTADA |
| DEC-18 | H-18 | Reanudar intentos desde la `Respuesta` con mayor `secuencia`; sin estado PAUSADO. | DOCUMENTADA |
| DEC-19 | H-19 | Roles y autoría fuera del alcance (P-09, P-10); no se añade RF. | DOCUMENTADA |
| DEC-20 | H-20 | El diccionario lleva tipo SQL y tipo Neo4j. | ADOPTADA |
| DEC-21 | — | Método: KG v1.1 con `changelog`; v1.0 conservada. | ADOPTADA |
| DEC-22 | — | Todos los entregables en la carpeta `entregables/`; la verificación en `verificacion/`. | ADOPTADA |

---

## Detalle de cada decisión

Criterios ToT (de `PLAN.md`): **(a)** cumple el enunciado · **(b)** fiel al KG y a `CLAUDE.md` · **(c)** soporta C-01..C-05 · **(d)** adecuada para Neo4j · **(e)** claridad.

### DEC-01 — Tercera propiedad de `Respuesta` (H-01)
- **Problema:** en Neo4j las FK se vuelven relaciones (R08, R09, R10), y `Respuesta` queda con `id_respuesta` y `fecha_respuesta`: 2 propiedades, por debajo del mínimo de 3 del enunciado.
- **ToT:**
  | Rama | a | b | c | d | e | Veredicto |
  |---|---|---|---|---|---|---|
  | A. Añadir `secuencia` | ✔ | ✔ cambio mínimo | ✔ ordena el recorrido de C-03 | ✔ | ✔ | **Elegida** |
  | B. A + `tiempo_respuesta_seg` | ✔ | ✘ especulativa: ninguna consulta la usa y depende de P-03 | ~ | ✔ | ✔ | Podada |
  | C. Listar las FK como propiedades para llegar a 3 | ✔ formal | ✘ duplica las relaciones | ✔ | ✘ redundancia que puede quedar inconsistente | ✘ | Podada |
- **CoVe:** *¿`secuencia` no es redundante con `fecha_respuesta`?* No del todo. Con conectividad limitada (restricción del stakeholder, RF-10) las respuestas pueden sincronizarse más tarde y las marcas de tiempo pueden empatar o venir de relojes distintos. `secuencia` da un orden determinista. *¿Hay que añadir una restricción?* Sí: `secuencia` ≥1 y única por intento (RI-16).
- **SC:** enunciado (≥3) → añadir · C-03 (reconstruir el recorrido) → `secuencia` · DEC-18 (reanudar sesiones) → `secuencia`. **3/3.**
- **Decisión:** `Respuesta.secuencia` INTEGER NOT NULL. **ADOPTADA.**

### DEC-02 — Cardinalidad de R06 (H-02)
- **Problema:** R06 dice 0..N y OBS-03 dice "una o más".
- **ToT:**
  | Rama | Evaluación | Veredicto |
  |---|---|---|
  | A. 1..N | Coherente con D-04 (ACCEPTED: "decisiones, consecuencias"), RF-04 ("presentar sus consecuencias") y OBS-03 | **Elegida** |
  | B. 0..N (literal del KG) | Permite decisiones sin consecuencia, lo que contradice el concepto central | Podada |
  | C. 0..N en el modelo + regla aparte | Equivale a A, pero esconde la regla fuera de la cardinalidad | Podada |
- **CoVe:** *¿Una simulación en BORRADOR puede tener opciones sin consecuencia mientras se escribe?* Sí, por OBS-11. Por eso la cardinalidad mínima 1 se exige **al publicar** (RI-17), igual que el contenido mínimo de OBS-11. *¿Cambia el destino?* No: una consecuencia sigue perteneciendo a 1..1 opción.
- **SC:** KG literal → 0..N · D-04/RF-04 → 1..N · OBS-03 → 1..N. **2–1 → 1..N.** La discrepancia se debe a un error en la cardinalidad del KG, no a una regla distinta.
- **Decisión:** R06 `source_cardinality` = **1..N** (exigible en PUBLICADA). **ADOPTADA.**

### DEC-03 — Fin de las rutas y pasos finales (H-05)
- **Problema:** R05 (1..N) impide que existan pasos sin opciones.
- **ToT:**
  | Rama | Evaluación | Veredicto |
  |---|---|---|
  | A. `Paso.tipo` {INICIAL, DECISION, FINAL} y R05 0..N | Explícita, pero contradice R05 y **un paso FINAL no genera `Respuesta`**, así que el desenlace no queda registrado en el intento (C-03 pierde el final) | Podada |
  | B. R05 1..N y la ruta termina en una **opción terminal** (sin `CONDUCE_A`) | Fiel al KG (R05, R07 0..1) y a OBS-04 ("una opción puede… terminar una ruta"). El desenlace es la `Consecuencia` de la opción terminal, que **sí** queda en la `Respuesta` → C-03 completo | **Elegida** |
  | C. Nodo especial `Final` | Añade una etiqueta fuera del KG | Podada |
- **CoVe:** *¿Cómo se identifica el paso inicial sin `tipo` INICIAL?* Es el de `orden = 1`, único por simulación (RI-18). *¿Cuándo termina un intento?* Cuando la última respuesta selecciona una opción terminal; entonces pasa a COMPLETADO con `fecha_fin` (RI-23, compatible con RI-12). *¿Contradice lo sugerido en la auditoría (H-05)?* Sí: en la auditoría la preferencia era A; con el argumento de C-03 se invierte. Queda registrado.
- **SC:** KG literal (R05, R07) → B · OBS-04 → B · C-03 → B. **3/3.**
- **Decisión:** R05 se mantiene en 1..N; opción terminal = opción sin `CONDUCE_A`; paso inicial = `orden = 1`. **ADOPTADA.**

### DEC-04 — Significado y catálogo de `Paso.tipo` (H-05, H-08)
- **Problema:** con DEC-03, `tipo` ya no marca el rol del paso en la ruta. Hay que darle un significado.
- **ToT:**
  | Rama | Evaluación | Veredicto |
  |---|---|---|
  | A. Rol en la ruta {INICIAL, INTERMEDIO} | Redundante con `orden = 1` → fuente de inconsistencias | Podada |
  | B. Tipo de situación laboral {CORREO, REUNION, CONVERSACION, TAREA, INCIDENTE} | Conecta con las necesidades del stakeholder (comunicación, conflictos, tareas ambiguas, fechas límite) y con el formato de presentación (RF-03) | **Elegida** |
  | C. Dejarlo sin catálogo | Deja un VARCHAR sin semántica | Podada |
- **CoVe:** *¿Depende de una decisión pendiente?* Sí: P-09 (formato de autoría). → PROPUESTA.
- **SC:** necesidades del stakeholder → B · eliminar redundancias (RI-18) → no A · enunciado (valores permitidos) → hace falta un catálogo. **Coherente con B.**
- **Decisión:** catálogo propuesto para `Paso.tipo`. **PROPUESTA (P-09).**

### DEC-05 — `Simulacion` en C-04 (H-03)
- **ToT:** A. añadirla (la pregunta lo pide) vs. B. reformular la pregunta sin "en qué simulaciones" (pierde valor para el empleador). → **A.**
- **CoVe:** camino `(Evidencia)<-[:PRODUCE]-(Intento)<-[:TIENE]-(Simulacion)` → existe (R15, R02). ✔
- **SC:** texto de la pregunta → sí · camino necesario → sí · RF-08 (evidencias con contexto) → sí. **3/3.**
- **Decisión:** C-04 pasa a 6 entidades. **ADOPTADA.**

### DEC-06 — Atribución de desempeño a habilidades en C-02 (H-04)
- **ToT:**
  | Rama | Evaluación | Veredicto |
  |---|---|---|
  | A. Nueva relación `(Opcion)-[:IMPACTA {delta}]->(Habilidad)` | Granularidad por decisión, pero presupone el cálculo de nivel (P-03, pendiente), añade una relación 18.ª y afecta todos los entregables | Podada (queda como propuesta futura) |
  | B. Añadir `Simulacion` a C-02; las fortalezas y áreas de mejora salen de `Progreso.nivel_actual` frente a `nivel_objetivo`/`nivel_esperado`, y el detalle de `Retroalimentacion` se agrupa por simulación (y esta por habilidad mediante DESARROLLA) | Responde la pregunta con el modelo actual | **Elegida** |
  | C. Propiedad `habilidad` en `Retroalimentacion` | Relación escondida en una propiedad: antipatrón en grafos | Podada |
- **CoVe:** *¿C-02 se puede responder sin IMPACTA?* Sí: `(Usuario)-[:TIENE_PROGRESO]->(Progreso)-[:CORRESPONDE_A]->(Habilidad)` da el nivel por habilidad (fortaleza o área de mejora). `(Usuario)-[:REALIZA]->(Intento)-[:REGISTRA]->(Respuesta)-[:GENERA]->(Retroalimentacion)` + `(Intento)<-[:TIENE]-(Simulacion)-[:DESARROLLA]->(Habilidad)` explica el porqué. ✔
- **SC:** KG (P-03 pendiente) → B · respondibilidad de C-02 → B suficiente · coherencia de los entregables (no añadir una relación especulativa) → B. **3/3.**
- **Decisión:** C-02 incluye `Simulacion`; la limitación de granularidad se documenta. **ADOPTADA + DOCUMENTADA.**

### DEC-07 — Convención de cardinalidad (H-06)
- **Decisión:** `source_cardinality` = número de nodos destino por cada nodo origen; `target_cardinality` = número de nodos origen por cada nodo destino.
- **CoVe:** se comprobaron las 17 relaciones con esta lectura (p. ej. R07: una opción conduce a 0..1 pasos y un paso lo alcanzan 0..N opciones; R16: una evidencia demuestra 1..N habilidades). Sin contradicciones. ✔
- **SC:** la lectura inversa produce absurdos (R09: "un paso tendría exactamente 1 respuesta"). Las otras lecturas coinciden. ✔ **ADOPTADA.**

### DEC-08 — Escalas de nivel y propiedades de DESARROLLA (H-07, H-10)
- **ToT:** A. todo en 0–100 (como RI-07) · B. niveles discretos 1–5 · C. dejarlo sin definir. → **A**: C-01 compara `nivel_actual` (0–100, fijado por RI-07) con `nivel_esperado`; B obligaría a convertir escalas; C hace imposible C-01.
- `peso`: A. (0, 1] · B. 0–100 · C. entero 1–5. → **A**: expresa la contribución relativa de la simulación a la habilidad. No se exige que los pesos sumen 1 (sería un supuesto sobre P-03).
- **CoVe:** *¿`nivel_objetivo` cambia de tipo?* No: sigue INTEGER y nullable (KG); solo se acota el rango. *¿Depende de una P-xx?* Sí: P-03 (cálculo) y P-08 (niveles). → PROPUESTA.
- **SC:** RI-07 → 0–100 · C-01 → misma escala · P-08 pendiente → marcar como propuesta. **Coherente.**
- **Decisión:** `nivel_objetivo` INTEGER NULL 0–100; `nivel_esperado` INTEGER NOT NULL 0–100; `peso` DECIMAL(3,2) NOT NULL en (0, 1]. **PROPUESTA (P-03, P-08).**

### DEC-09 — Catálogos de valores (H-08)
| Propiedad | Ramas evaluadas | Elegida | Justificación |
|---|---|---|---|
| `Usuario.estado` | {ACTIVO, INACTIVO} · {ACTIVO, INACTIVO, SUSPENDIDO} · + PENDIENTE_VERIFICACION | **{ACTIVO, INACTIVO, SUSPENDIDO}** | Cubre baja voluntaria y bloqueo; la verificación de cuenta es de P-10 |
| `Consecuencia.impacto` | {POSITIVO, NEUTRO, NEGATIVO} · escala numérica | **{POSITIVO, NEUTRO, NEGATIVO}** | Es la valencia; la intensidad numérica ya está en `Opcion.valoracion` |
| `Consecuencia.tipo` | {INMEDIATA, DIFERIDA} · área afectada | **{RELACIONAL, TIEMPO, CALIDAD, REPUTACION}** | Distinto de `impacto` (no repite la valencia); explica *qué* afecta la decisión, útil para la retroalimentación (RF-05) y para C-03 |
| `Retroalimentacion.tipo` | {ACIERTO, ERROR, MEJORA} · {ACIERTO, PARCIAL, ERROR} | **{ACIERTO, PARCIAL, ERROR}** | Las "acciones de mejora" de RF-05 ya viven en `recomendacion`; usar MEJORA las duplicaría. PARCIAL refleja que `valoracion` es gradual |
| `Evidencia.visibilidad` | {PRIVADA, PUBLICA} · {PRIVADA, ENLACE, PUBLICA} | **{PRIVADA, PUBLICA}**, por defecto PRIVADA | "ENLACE" duplica la existencia de una `Comparticion` vigente; RI-15 ya define el acceso de una PRIVADA por enlace autorizado. El valor por defecto PRIVADA atiende la restricción de privacidad |
| `Comparticion.estado` | {ACTIVA, REVOCADA, EXPIRADA} · {ACTIVA, REVOCADA} | **{ACTIVA, REVOCADA}** | EXPIRADA duplicaría `fecha_expiracion` y podría contradecirla. Vigente = ACTIVA y (`fecha_expiracion` nula o futura) |
| `Habilidad.categoria` | Inventar categorías · dejar pendiente | **Sin catálogo** (obligatoria, texto) | P-08 la deja expresamente pendiente; inventarla violaría `CLAUDE.md` |

- **CoVe:** se verificó que ningún valor contradice RI-05/RI-06 ni los textos de RF-05/RF-09/RI-15. Se corrigieron dos propuestas de la auditoría: `Evidencia.visibilidad` (ENLACE eliminado) y `Comparticion.estado` (EXPIRADA eliminado).
- **SC:** para cada catálogo, (1) el texto de los RF, (2) las RI relacionadas y (3) evitar redundancias con otras propiedades coinciden en la rama elegida.
- **Decisión:** **PROPUESTA** (P-06 compartición, P-08 habilidades, P-10 cuentas); `Consecuencia.*` y `Retroalimentacion.tipo` quedan ligados a P-04 y P-03.

### DEC-10 — Obligatoriedad (H-09)
- **Regla:** una propiedad es obligatoria si no tiene `nullable: true` en el KG. Las propiedades nuevas declaran su obligatoriedad de forma explícita.
- **CoVe:** contraste con RI-12 (`fecha_fin` nullable, pero obligatoria si COMPLETADO): es una obligatoriedad **condicional**; el diccionario lo indicará. ✔ **ADOPTADA.**

### DEC-11 — Nuevas restricciones de integridad (H-11)
| ID | Restricción | Categoría | Estado | Por qué |
|---|---|---|---|---|
| RI-16 | `Respuesta.secuencia` ≥1 y única dentro de cada intento | Unicidad / valores | ADOPTADA | Consecuencia de DEC-01 |
| RI-17 | Una simulación PUBLICADA tiene ≥1 paso, ≥1 habilidad en DESARROLLA, cada paso ≥1 opción (R05) y cada opción ≥1 consecuencia (R06) | Regla de negocio | ADOPTADA | Concreta OBS-11 y DEC-02 |
| RI-18 | `Paso.orden` >0 y único dentro de su simulación; el paso con `orden = 1` es el inicial | Unicidad / valores | ADOPTADA | DEC-03 |
| RI-19 | Solo se crean intentos de simulaciones PUBLICADAS | Regla de negocio | ADOPTADA | RF-02 ("disponibles"); evita intentos sobre borradores |
| RI-20 | Las habilidades que DEMUESTRA una evidencia están entre las que DESARROLLA la simulación de su intento | Consistencia | ADOPTADA | Misma familia que RI-14; evita evidencias de habilidades no practicadas |
| RI-21 | Comparticion: `fecha_expiracion` > `fecha_creacion` | Valores / temporal | ADOPTADA | Coherencia temporal |
| RI-22 | `Respuesta.fecha_respuesta` entre `fecha_inicio` y `fecha_fin` (si existe) del intento; solo se registran respuestas en intentos EN_CURSO | Consistencia / regla de negocio | ADOPTADA | Coherencia temporal y de estado |
| RI-23 | Un intento pasa a COMPLETADO al seleccionar una opción terminal (sin `CONDUCE_A`) | Regla de negocio | ADOPTADA | DEC-03 |
| RI-24 | Las propiedades con catálogo (DEC-04, DEC-09) solo admiten los valores del catálogo; `peso` en (0,1]; `nivel_esperado` y `nivel_objetivo` en 0–100; `duracion_estimada` >0 | Valores permitidos | PROPUESTA | Depende de DEC-04/08/09 (P-xx) |
| RI-25 | Solo se genera evidencia a partir de un intento COMPLETADO | Regla de negocio | PROPUESTA | Ligada a P-05 (autenticidad) |

- **ToT:** (A) añadir todas como ADOPTADA · (B) solo las que no tocan una P-xx como ADOPTADA y el resto como PROPUESTA · (C) no añadir ninguna (el enunciado ya se cumple). → **B**: C desaprovecha reglas necesarias para la coherencia (DEC-01/02/03 las requieren); A viola la regla de pendientes.
- **Descartadas:** "una respuesta por (intento, paso)": depende de si se permiten ciclos (P-04). "Todo paso alcanzable desde `orden = 1`": también P-04. Se mencionan como pendientes en E4.
- **CoVe:** cada RI nueva referencia solo elementos que existen en el KG v1.1 ✔; ninguna contradice RI-01..15 ✔ (RI-23 es compatible con RI-12).
- **SC:** cada regla tiene ≥2 de 3 justificaciones (enunciado, KG/OBS, consulta o RF). ✔

### DEC-12 — Mecanismo de implementación en Neo4j (H-12)
- **Verificación (CoVe externa):** según el *Cypher Manual* de Neo4j, existen 4 tipos de constraint: uniqueness, existence, property type y key. Las marcas de edición indican que **property type y key son Enterprise**, y la documentación 4.4 indica que **existence también es Enterprise**. La uniqueness está disponible en Community. Fuentes: [Cypher Manual – Constraints (current)](https://neo4j.com/docs/cypher-manual/current/schema/constraints/), [Cypher Manual 4.4 – Constraints](https://neo4j.com/docs/cypher-manual/4.4/constraints/). Nota: no se pudo abrir la página directamente desde este entorno; el dato se tomó de los resultados de búsqueda y se volverá a confirmar en F4.
- **Decisión:** columna "mecanismo" en E4 con tres niveles: (1) constraint nativa en cualquier edición (uniqueness: RI-01, RI-02 con correo normalizado, RI-03, RI-15 token); (2) constraint solo en Enterprise (existence/type: RI-04 y parte de RI-24), con alternativa en lógica de aplicación para Community; (3) lógica de aplicación o transacción (RI-08 con `MERGE`, RI-09..14, RI-16..23). **ADOPTADA.**
- **SC:** documentación → split · arquitectura (Neo4j con validaciones adicionales, `limitations_to_consider`) → coherente · RI-10/11/14 ya decían "lógica de aplicación" → coherente. **3/3.**

### DEC-13 — "Con quién" en RF-09 (H-13)
- **ToT:** A. `Comparticion.destinatario` VARCHAR(150) NULL · B. nodo `Destinatario` + relación · C. dejarlo todo en P-06. → **A**: cubre el texto de RF-09 con el mínimo cambio. B es prematuro (P-06). C deja RF-09 sin soporte en el modelo.
- `destinatario` NULL significa "cualquiera con el enlace vigente".
- "Resultados" (RF-09): se comparten a través de evidencias, que sintetizan resultados. → DOCUMENTADA.
- **Decisión:** **PROPUESTA (P-06) + DOCUMENTADA.**

### DEC-14 — C-05 y el historial (H-14)
- **ToT:** A. nodo `MedicionProgreso` · B. aproximación con `Intento.fecha_fin`, `Intento.puntuacion` y `DESARROLLA` · C. reformular C-05. → **B**: MD-02 y P-07 dejan pendiente el historial; C-05 está DEFINED en el KG y no debe reformularse.
- **SC:** MD-02/P-07 → no añadir el nodo · respondibilidad aproximada → sí · coherencia de los entregables → no añadir. **3/3.** **DOCUMENTADA** (limitación conocida; `MedicionProgreso` como trabajo futuro).

### DEC-15 a DEC-19 — Documentadas (H-15..H-19)
| DEC | Decisión | Razón (ToT: alternativa podada) |
|---|---|---|
| DEC-15 | Mantener `(Simulacion)-[:TIENE]->(Intento)` | Renombrar/invertir afecta R02 en todo el KG por una mejora estética; se explica su lectura en E3 |
| DEC-16 | Mantener `GENERA` ×3 y `CORRESPONDE_A` ×2 | En Neo4j el tipo + las etiquetas desambiguan; renombrar añadiría 3 tipos nuevos sin aportar a las consultas |
| DEC-17 | Mantener R09 y R14 | Acceso directo (C-03, C-04) a cambio de RI-10/RI-14; buen ejemplo para las conclusiones |
| DEC-18 | Reanudar con la `Respuesta` de mayor `secuencia` en un intento EN_CURSO | Un estado PAUSADO no aporta información nueva |
| DEC-19 | Roles y autoría fuera del alcance | P-09/P-10 pendientes; un RF sin entidades que lo soporten rompería la trazabilidad |

### DEC-20 — Doble tipo de dato (H-20)
Mapeo: UUID→String · VARCHAR/TEXT→String · INTEGER→Integer · DECIMAL→Float · TIMESTAMP→DateTime (zoned). **ADOPTADA.**

### DEC-21 — Cómo se actualiza el KG
- **ToT:** A. editar v1.0 sin rastro · B. no tocar el KG y poner las decisiones solo en los entregables · C. KG v1.1 con `changelog` y copia de v1.0. → **C**: mantiene el KG como fuente de verdad (`CLAUDE.md`) con trazabilidad completa; B desalinea el KG y los entregables. **ADOPTADA.**

### DEC-22 — Carpeta de entregables
Todos los entregables se crean en `entregables/`. Los razonamientos de verificación van en `verificacion/`, para que los entregables queden limpios para la conversión final. **ADOPTADA.**

---

## Verificación de este documento

### Ronda 1
- **ToT:** se aplicó a cada decisión (arriba). Cambio respecto a la auditoría: **H-05 se resolvió con la rama B, no con la A** que se había sugerido.
- **CoVe:**
  | Pregunta | Resultado |
  |---|---|
  | ¿Cada H-01..H-20 tiene al menos una DEC? | ✔ (H-10 en DEC-08, H-08 en DEC-04/09) |
  | ¿Toda PROPUESTA cita su P-xx? | ✔ |
  | ¿Ninguna ADOPTADA depende de una P-xx? | ✘ → `Retroalimentacion.tipo` y `Consecuencia.*` estaban como ADOPTADA en el primer borrador; se pasaron a PROPUESTA (P-03/P-04). Corregido |
  | ¿Los catálogos de la auditoría siguen siendo correctos? | ✘ → `visibilidad` (ENLACE) y `Comparticion.estado` (EXPIRADA) eran redundantes. Corregido |
  | ¿Las RI nuevas contradicen alguna existente? | ✔ Ninguna |
  | ¿El dato de las ediciones de Neo4j está respaldado? | ⚠ Solo por resultados de búsqueda → anotado y marcado para volver a confirmar en F4 |
  → 3 cambios. Se repite la ronda.
- **SC:** en cada DEC hay mayoría ≥2/3 (registrada en cada decisión).

### Ronda 2
- **ToT:** sin ramas nuevas.
- **CoVe:** se revisaron otra vez los 3 cambios: los estados y catálogos son coherentes con la tabla resumen. Se comprobó que el resumen y el detalle dicen lo mismo en las 22 DEC. ✔
- **SC:** sin cambios en las mayorías.
- → **Ronda limpia. Documento cerrado.**
