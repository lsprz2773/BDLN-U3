# Auditoría del KG antes de las fases F1–F7

**Objeto:** `docs/KG.json` v1.0 (2026-11-09).
**Pregunta:** ¿el KG aporta todo lo que necesitan los entregables 1–7 y cumple los requisitos del enunciado?
**Método:** comprobación automática de la estructura, más una revisión del significado con ToT, CoVe y self-consistency (rondas al final del documento).
**Regla:** el KG **no se modifica** sin aprobación del usuario. Cada hallazgo propone una resolución, marcada como *propuesta*.

---

## 1. Resultado de la comprobación estructural (automática)

| Comprobación | Resultado |
|---|---|
| 12 entidades en `domain_model` = 12 `node_labels` de Neo4j = 12 nodos de `logical_graph_model` | ✔ Coinciden |
| 17 relaciones de `domain_model` = 17 de `logical_graph_model` (origen, tipo, destino) | ✔ Coinciden |
| 14 tipos de relación declarados = 14 tipos usados | ✔ Coinciden |
| Cada FK de las entidades tiene una relación equivalente | ✔ 15/15 (`Opcion.id_paso` → R05 y `Opcion.id_paso_siguiente` → R07) |
| Cada entidad citada en C-01..C-05 existe en el modelo | ✔ |
| Las entidades listadas en cada consulta forman un subgrafo conexo | ✔ 5/5 (pero ver H-03 y H-04: faltan entidades necesarias para responder la pregunta) |
| ≥8 RF | ✔ 10 |
| 5 consultas, ≥2 con 3+ entidades | ✔ 5 consultas de 4 a 7 entidades |
| ≥8 restricciones de integridad | ✔ 15 |
| Las 5 categorías de restricciones del enunciado | ✔ Unicidad (RI-01/02/03/08/13/15), obligatorias (RI-04), valores permitidos (RI-05/06/07), consistencia (RI-09/10/11/14), reglas de negocio (RI-12/15) |

**Conclusión:** la estructura del KG es coherente internamente. Los problemas están en el **significado** y en la **completitud**, y se detallan abajo.

---

## 2. Hallazgos

**Severidad:**
- 🔴 **Bloqueante:** puede impedir cumplir un requisito del enunciado.
- 🟠 **Alta:** inconsistencia o falta que vuelve incorrecto un entregable.
- 🟡 **Media:** falta información que el entregable debe definir o proponer.
- ⚪ **Baja:** mejora de claridad o una redundancia que hay que justificar.

### 🔴 Bloqueante

| ID | Hallazgo | Evidencia | Fase | Resolución propuesta |
|---|---|---|---|---|
| H-01 | **`Respuesta` tendría solo 2 propiedades** si las FK se representan como relaciones, lo que es lo correcto en Neo4j. El enunciado pide ≥3 propiedades por entidad. | Propiedades de E08: `id_respuesta`, `id_intento` FK, `id_paso` FK, `id_opcion` FK, `fecha_respuesta`. Sin FK quedan 2. | F2 | *Propuesta:* añadir `secuencia` INTEGER (orden de la respuesta dentro del intento; sirve para reconstruir el recorrido en C-03) y opcionalmente `tiempo_respuesta_seg` INTEGER NULL (sirve para la evaluación, P-03). |

### 🟠 Alta

| ID | Hallazgo | Evidencia | Fase | Resolución propuesta |
|---|---|---|---|---|
| H-02 | **Inconsistencia en R06.** La cardinalidad dice que una opción genera 0..N consecuencias; la observación dice "una o más". | R06 `source_cardinality: 0..N` vs. OBS-03 | F5 | *Propuesta:* **1..N**. El concepto central es "decisiones con consecuencias" (D-04, RF-04): toda opción debería mostrar al menos una consecuencia. |
| H-03 | **A C-04 le falta `Simulacion`.** La pregunta pide "en qué simulaciones las obtuvo", pero `Simulacion` no está entre sus entidades. | C-04 `related_entities` | F1 | Añadir `Simulacion`. Camino: `Evidencia<-[:PRODUCE]-Intento<-[:TIENE]-Simulacion`. Pasa de 5 a 6 entidades. |
| H-04 | **C-02 no puede atribuir el desempeño a una habilidad concreta.** `Respuesta` y `Retroalimentacion` no se relacionan con `Habilidad`. Solo se puede atribuir a nivel de simulación (`Intento<-TIENE-Simulacion-DESARROLLA->Habilidad`), y `Simulacion` tampoco está entre las entidades de C-02. | C-02 `related_entities`; no existe una relación Opcion/Respuesta→Habilidad | F1, F3 | (a) Añadir `Simulacion` a C-02. (b) *Propuesta* ligada a P-03: relación `(Opcion)-[:IMPACTA {delta}]->(Habilidad)` para medir cada habilidad por decisión. Si no se adopta, documentar la limitación: la atribución es por simulación, no por decisión. |
| H-05 | **R05 obliga a que todo paso tenga ≥1 opción.** Un paso final (cierre o resultado) no ofrecería decisiones. | R05 `source_cardinality: 1..N`; OBS-04 dice que una opción "puede terminar una ruta", lo que es compatible con 1..N; `Paso.tipo` no tiene catálogo | F4, F5 | *Propuesta:* catálogo `Paso.tipo` ∈ {INICIAL, DECISION, FINAL}. R05 pasa a **0..N** con la regla "un paso INICIAL o DECISION ofrece ≥1 opción; un paso FINAL no ofrece ninguna". Alternativa: mantener 1..N y que la ruta termine en una opción sin `CONDUCE_A` (sin pasos finales). |
| H-06 | **No se indica cómo leer la notación de cardinalidad.** El KG usa `source_cardinality`/`target_cardinality` sin explicar su significado. | Todas las relaciones | F5 | Lectura deducida y coherente en las 17 relaciones: `source_cardinality` es cuántos **destinos** tiene cada origen; `target_cardinality` es cuántos **orígenes** tiene cada destino. Ejemplo R01: un Usuario tiene 0..N Intentos y un Intento pertenece a 1..1 Usuario. Declararlo explícitamente en E5. |
| H-07 | **Las escalas de nivel no son compatibles entre sí.** C-01 compara el progreso con el nivel esperado u objetivo. | `Progreso.nivel_actual` DECIMAL(5,2) en 0–100 (RI-07); `Habilidad.nivel_objetivo` INTEGER sin rango; `DESARROLLA.nivel_esperado` y `peso` sin tipo ni rango | F2, F4 | *Propuesta:* `nivel_objetivo` y `nivel_esperado` en la misma escala 0–100. `peso` DECIMAL en (0, 1]. Añadir las restricciones de rango. |

### 🟡 Media

| ID | Hallazgo | Fase | Resolución propuesta |
|---|---|---|---|
| H-08 | **Catálogos de valores sin definir:** `Usuario.estado`, `Paso.tipo`, `Consecuencia.impacto`, `Consecuencia.tipo`, `Retroalimentacion.tipo`, `Evidencia.visibilidad`, `Comparticion.estado`, `Habilidad.categoria` (P-08). | F2, F4 | *Propuestas:* `Usuario.estado` {ACTIVO, INACTIVO, SUSPENDIDO}; `Paso.tipo` (H-05); `Consecuencia.impacto` {POSITIVO, NEUTRO, NEGATIVO}; `Consecuencia.tipo` {INMEDIATA, DIFERIDA}; `Retroalimentacion.tipo` {ACIERTO, ERROR, MEJORA}; `Evidencia.visibilidad` {PRIVADA, ENLACE, PUBLICA}; `Comparticion.estado` {ACTIVA, REVOCADA, EXPIRADA}; `Habilidad.categoria` queda pendiente (P-08). |
| H-09 | **RI-04 no dice cuáles son los "campos esenciales".** | F2 | Regla de derivación: obligatoria = la propiedad no tiene `nullable: true` en el KG. Listarlo propiedad por propiedad en E2. |
| H-10 | **Las propiedades de relación no tienen tipo, obligatoriedad ni rango** (`DESARROLLA.peso`, `DESARROLLA.nivel_esperado`). | F2, F3 | Ver H-07. Documentarlas en E2 (sección de propiedades de relación) y en E3. |
| H-11 | **Faltan reglas de negocio que el modelo necesita para ser coherente:** (a) `Paso.orden` único y >0 dentro de cada simulación; (b) una simulación PUBLICADA tiene ≥1 paso, exactamente un paso INICIAL y ≥1 habilidad en DESARROLLA (OBS-11); (c) solo se inician intentos de simulaciones PUBLICADAS; (d) una evidencia solo se genera a partir de un intento COMPLETADO (relacionado con P-05); (e) las habilidades de DEMUESTRA deben estar entre las de DESARROLLA de la simulación del intento; (f) `fecha_expiracion` > `fecha_creacion` en Comparticion; (g) `fecha_respuesta` entre las fechas del intento; (h) `duracion_estimada` > 0. | F4 | Añadirlas como RI-16 en adelante, marcadas como *propuesta*. El enunciado ya se cumple con RI-01..15; estas reglas refuerzan "consistencia entre entidades" y "reglas de negocio". |
| H-12 | **No todas las restricciones se imponen igual en Neo4j.** La unicidad de propiedad es nativa. La existencia y el tipo de propiedad dependen de la edición de Neo4j. Las reglas entre nodos (RI-09, RI-10, RI-11, RI-14) y la unicidad de la pareja en DESARROLLA (RI-08) no tienen restricción nativa. | F4 | En E4, columna "mecanismo": constraint nativo / según edición / lógica de aplicación o transacción (`MERGE`, validación previa). **Verificar en F4** qué restricciones ofrece la edición Community frente a Enterprise antes de afirmarlo en el entregable. |
| H-13 | **RF-09 dice "con quién", pero `Comparticion` no tiene destinatario ni permisos.** Además RF-09 habla de compartir "evidencias y resultados" y solo se modela la compartición de evidencias. | F1, F2 | Depende de P-06. *Propuesta mínima:* `Comparticion.destinatario` VARCHAR(150) NULL (correo o descripción; NULL = cualquiera con el enlace). Indicar en E1 que compartir "resultados" se hace a través de evidencias. |
| H-14 | **C-05 (evolución en el tiempo) solo se puede aproximar.** `Progreso` es único y consolidado (RI-13); el historial está pendiente (P-07). | F1, F7 | La consulta se resuelve con las fechas de `Intento` + `puntuacion` + `DESARROLLA`. Declararlo como limitación conocida. *Propuesta futura:* nodo `MedicionProgreso` (no se incluye en el modelo actual). |

### ⚪ Baja

| ID | Hallazgo | Fase | Resolución propuesta |
|---|---|---|---|
| H-15 | **`TIENE` (Simulacion→Intento) es un nombre genérico** y su dirección es poco natural: se lee mejor "un intento es de una simulación". | F3 | Mantenerlo por fidelidad al KG y explicar su significado. *Propuesta opcional:* `(Intento)-[:DE_SIMULACION]->(Simulacion)`. |
| H-16 | **`GENERA` se usa 3 veces (R06, R11, R14) y `CORRESPONDE_A` 2 veces (R09, R13)** con significados distintos. | F3 | Explicarlo en E3. Es válido en Neo4j porque el significado lo da el par de etiquetas. |
| H-17 | **Relaciones redundantes a propósito:** R09 (Respuesta→Paso) se puede deducir de R10+R05, y R14 (Usuario→Evidencia) de R01+R15. Por eso existen RI-10 y RI-14. | F3, F7 | Justificarlas: acceso directo y propiedad explícita, a cambio de reglas de consistencia. Buen ejemplo para las conclusiones. |
| H-18 | **RF-10 (sesiones cortas) no prevé pausar un intento.** No hay estado PAUSADO ni paso actual. | F1 | Se puede reanudar a partir de la última `Respuesta` del intento EN_CURSO. Documentarlo; no hace falta cambiar el modelo. |
| H-19 | **No hay roles de usuario ni autoría de simulaciones** (¿quién crea y publica?). | F1 | Fuera del alcance actual (P-09, P-10). Mencionarlo como pendiente. No se añade un RF. |
| H-20 | **Los tipos de dato son de SQL.** | F2 | Añadir en E2 la columna "tipo en Neo4j": UUID→String, VARCHAR/TEXT→String, INTEGER→Integer, DECIMAL→Float, TIMESTAMP→DateTime. |

---

## 3. Qué necesita cada fase del KG

| Fase | ¿El KG lo cubre? | Hallazgos que afectan |
|---|---|---|
| F1 Requerimientos y consultas | Casi completo | H-03, H-04, H-13, H-14, H-18, H-19 |
| F2 Diccionario | Faltan obligatoriedad explícita, tipos de las propiedades de relación y 1 propiedad en `Respuesta` | **H-01**, H-07, H-08, H-09, H-10, H-13, H-20 |
| F3 Relaciones | Faltan las descripciones (se redactan) | H-04, H-10, H-15, H-16, H-17 |
| F4 Restricciones | Cumple el mínimo; faltan catálogos y reglas | H-05, H-07, H-08, H-11, H-12 |
| F5 Cardinalidades | Cumple, con 2 decisiones abiertas | **H-02**, **H-05**, H-06 |
| F6 Diagrama | Completo (depende de F2–F5) | — |
| F7 Conclusiones | Completo (MD-01..05 + hallazgos como ejemplos) | H-14, H-17 |

---

## 4. Registro de verificación de esta auditoría

### Ronda 1

**ToT** (decisiones de la auditoría)
- *¿Corregir el KG directamente, o solo documentar?* Ramas: (A) modificar el KG ya; (B) documentar las propuestas en los entregables sin tocar el KG; (C) documentar aquí, decidir con el usuario y después publicar el KG v1.1 con un registro de cambios. → **C**: el KG es la fuente de verdad (`CLAUDE.md`), y A rompería la regla de no dar por decidido lo pendiente. B dejaría el KG y los entregables desalineados.
- *¿Cómo clasificar la severidad?* Ramas: (A) por fase; (B) por impacto en el enunciado; (C) ambas. → **C**: severidad por impacto (sección 2) y tabla por fase (sección 3).
- *¿Qué hacer con H-05?* Ramas: (A) R05 0..N + catálogo `Paso.tipo`; (B) mantener 1..N y terminar las rutas en opciones sin `CONDUCE_A`; (C) nodo especial `Final`. → Se prefiere **A**: es explícita, sirve para C-03 y no añade una etiqueta. B queda como alternativa válida. C se descarta porque añade una etiqueta fuera del KG.

**CoVe** (preguntas verificadas contra `docs/KG.json`, sin mirar el borrador)
| Pregunta | Respuesta | ¿Coincide? |
|---|---|---|
| ¿Cuántas propiedades sin FK tiene `Respuesta`? | 2 (`id_respuesta`, `fecha_respuesta`) | ✔ H-01 |
| ¿El texto de C-04 menciona simulaciones? | Sí: "en qué simulaciones las obtuvo" | ✔ H-03 |
| ¿`Simulacion` está en `related_entities` de C-04? | No | ✔ H-03 |
| ¿Existe alguna relación que llegue a `Habilidad` desde `Respuesta`, `Opcion` o `Retroalimentacion`? | No (solo R04, R13 y R16 llegan a Habilidad) | ✔ H-04 |
| ¿R06 `source_cardinality`? / ¿OBS-03? | 0..N / "una o más" | ✔ H-02 |
| ¿R05 `source_cardinality`? | 1..N | ✔ H-05 |
| ¿Algún catálogo para `Paso.tipo`, `Usuario.estado`, `Evidencia.visibilidad`, `Comparticion.estado`? | No (solo RI-05 y RI-06 definen catálogos) | ✔ H-08 |
| ¿Tipo de `nivel_objetivo`? ¿Rango? | INTEGER, sin rango | ✔ H-07 |
| ¿Tipos o rangos de `peso`/`nivel_esperado`? | No definidos | ✔ H-07/H-10 |
| ¿`Comparticion` tiene destinatario? | No | ✔ H-13 |
| ¿La lectura de cardinalidad de H-06 sirve para las 17 relaciones? | Se comprobó una a una (p. ej. R07: una opción conduce a 0..1 pasos y un paso es alcanzado por 0..N opciones; R09: una respuesta corresponde a 1..1 paso). Sin contradicciones. | ✔ H-06 |
| ¿Las restricciones de existencia de Neo4j son de la edición Enterprise? | No se verificó con documentación oficial en esta ronda | ⚠ Redacción cambiada a "dependen de la edición" y verificación movida a F4 (H-12) |

→ **1 cambio** (H-12 se suavizó a "verificar en F4"). Hace falta otra ronda.

**SC** (3 rutas por juicio clave)
| Juicio | Ruta 1 (KG literal) | Ruta 2 (consultas/RF) | Ruta 3 (OBS/RI) | Resultado |
|---|---|---|---|---|
| R06 debe ser 1..N | 0..N | 1..N (RF-04 "presentar sus consecuencias") | 1..N (OBS-03) | 2–1 → *propuesta* 1..N; decide el usuario |
| `Respuesta` necesita otra propiedad | Tiene 2 sin FK | C-03 se beneficia de `secuencia` | El enunciado pide ≥3 | 3/3 → H-01 bloqueante |
| C-04 necesita `Simulacion` | No la lista | El texto la pide | Camino R15+R02 | 2–1 → añadirla |
| R05 1..N es problemático | 1..N | C-03 recorre hasta el final de la ruta | OBS-04 permite terminar en una opción | Sin mayoría clara → dos alternativas (A/B) para el usuario |

### Ronda 2
- **ToT:** sin ramas nuevas.
- **CoVe:** se revisó otra vez H-12; la redacción ya no afirma nada sin verificar. Se revisó que las 20 IDs H-xx sean únicas y que la tabla de la sección 3 cite solo hallazgos que existen. ✔
- **SC:** se repitieron los juicios con el texto corregido; los resultados no cambian.
- → **Sin cambios. Auditoría cerrada.** Pendiente: decisiones del usuario.
