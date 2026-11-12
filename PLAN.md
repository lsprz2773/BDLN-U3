# PLAN.md — Plan de trabajo de los entregables (QATO'K)

Plan para construir, verificar y cerrar los entregables de la actividad *Diseño del modelo lógico de una aplicación basada en grafos* (`docs/actividad.jpg`). El estado vivo se lleva en `PROGRESS.md`; este archivo define **cómo** se trabaja.

---

## 1. Estructura de archivos

```
entregables/
  01-requerimientos-consultas.md
  02-diccionario-entidades.md
  03-catalogo-relaciones.md
  04-restricciones-integridad.md
  05-cardinalidades.md
  06-modelo-logico.md
  07-conclusiones.md
verificacion/
  01-requerimientos-consultas.md   ← bitácora de verificación de cada entregable
  ...
  08-coherencia-global.md
scripts/
  verificar.py                     ← comprobaciones automáticas contra docs/KG.json
```

- Los archivos de `entregables/` contienen **solo** el contenido entregable (limpio, listo para convertir a .docx).
- Los archivos de `verificacion/` contienen el razonamiento: ramas ToT, preguntas CoVe, rutas de self-consistency, cambios aplicados y rondas.

---

## 2. Protocolo de verificación (se aplica a CADA creación y CADA corrección)

Cada vez que se crea un entregable o se corrige cualquier parte de él, se ejecuta este ciclo completo:

```
Borrador (vN)
   │
   ├─► 1. ToT   (Tree of Thoughts)      → elegir entre alternativas de diseño
   ├─► 2. CoVe  (Chain of Verification) → verificar afirmaciones concretas
   ├─► 3. SC    (Self-Consistency)      → contrastar juicios por rutas independientes
   │
   ├─ ¿Hubo cambios? ── Sí ──► aplicar cambios → vN+1 → volver a 1
   │
   └─ No ──► ronda limpia → entregable ✅ (sujeto a revisión del usuario)
```

### 2.1 ToT — Tree of Thoughts
Para cada **decisión de diseño** del entregable (estructura de tabla, cómo representar algo, cómo resolver una ambigüedad):
1. Generar **2–3 ramas** alternativas.
2. Evaluar cada rama con criterios fijos: **(a)** cumple el enunciado, **(b)** fiel al KG y a las reglas de `CLAUDE.md`, **(c)** soporta las consultas C-01..C-05, **(d)** adecuada para Neo4j, **(e)** claridad para quien califica.
3. Podar las ramas débiles, elegir una y **registrar la justificación**.

### 2.2 CoVe — Chain of Verification
1. Del borrador, extraer las **afirmaciones verificables** (conteos, nombres, tipos, cardinalidades, referencias a IDs).
2. Plantear **preguntas de verificación** específicas (lista base por fase en la sección 4).
3. Responder cada pregunta **de forma independiente**, consultando `docs/KG.json`/el enunciado y no el borrador.
4. Comparar respuestas con el borrador → cada discrepancia es una corrección.
5. Complementar con `scripts/verificar.py` cuando la comprobación sea mecánica (conteos, nombres exactos, existencia en el KG).

### 2.3 SC — Self-Consistency
1. Para los **juicios** del entregable (p. ej. obligatoriedad, cardinalidad mínima, qué entidades toca una consulta), derivar la respuesta por **3 rutas de razonamiento independientes** (p. ej. desde las propiedades del KG, desde las consultas/reglas de negocio, desde las observaciones OBS/RI).
2. Si las 3 coinciden → se acepta.
3. Si hay mayoría 2–1 → se adopta la mayoría y se documenta la discrepancia.
4. Si no hay mayoría o la diferencia depende de una decisión pendiente (P-xx) → se marca como *propuesta* y se **escala al usuario**.

### 2.4 Criterio de parada
- Se cierra un entregable cuando una **ronda completa (ToT + CoVe + SC) no produce cambios**.
- Límite: **3 rondas** por entregable. Si en la 3.ª ronda aún hay cambios, se detiene y se consulta al usuario lo que siga abierto.
- Una **corrección posterior** (por revisión del usuario o por otra fase) reabre el ciclo desde la ronda 1 para ese entregable, y se revisan los entregables que dependen de él.

### 2.5 Registro
Cada ronda se registra en `verificacion/NN-*.md`: versión, ramas ToT y elección, preguntas CoVe con respuesta (✔/✘), rutas SC y resultado, cambios aplicados. Luego se actualiza `PROGRESS.md` (estado, checklist, bitácora).

---

## 3. Fases y dependencias

| Fase | Entregable | Depende de | Actividad del enunciado |
|---|---|---|---|
| F0 | Preparación: estructura de carpetas y `scripts/verificar.py` ✅ | — | — |
| F0.5 | Auditoría del KG (`verificacion/00-auditoria-kg.md`) y decisiones (`docs/decisiones-modelado.md`, KG v1.1) ✅ | KG | Todas |
| F1 | 1. Tabla de requerimientos y consultas ✅ | KG | A1 |
| F2 | 2. Diccionario de entidades y propiedades ✅ | F1 | A2 |
| F3 | 3. Catálogo de relaciones ✅ | F1, F2 | A2 |
| F4 | 4. Tabla de restricciones de integridad ✅ | F2, F3 | A3 |
| F5 | 5. Tabla de cardinalidades ✅ | F3, F4 | A4 |
| F6 | 6. Diagrama del modelo lógico ✅ | F2–F5 | A5 |
| F7 | 7. Conclusiones ✅ | F1–F6 | A6 |
| F8 | Revisión de coherencia global ✅ | F1–F7 | Todas |
| F9 | Conversión al formato final (.docx u otro) | F8 + aprobación | — |
| F10 | Implementación en Neo4j: restricciones, índices, datos de ejemplo por consulta, relaciones, pruebas de humo y limpieza (`neo4j/`) ✅ | F1–F8 | — |

**Ritmo:** una fase a la vez. Al terminar cada fase se presenta un resumen (qué se hizo, qué se cambió en la verificación, qué queda como *propuesta* o pregunta) y **se espera la aprobación del usuario** antes de pasar a la siguiente.

---

## 4. Detalle por fase

### F0 — Preparación
- Crear `entregables/`, `verificacion/`, `scripts/`.
- `scripts/verificar.py`: lee `docs/KG.json` y los `.md` de `entregables/`; comprueba conteos, nombres exactos de etiquetas/relaciones/propiedades/IDs y existencia de cada referencia en el KG. Crece fase a fase.
- **Hecho cuando:** el script corre sin errores (aunque no haya entregables).

### F1 — Tabla de requerimientos y consultas
- **Contenido:** tabla de RF (ID, nombre, descripción, necesidad/problema que atiende); tabla de consultas (ID, pregunta, entidades involucradas, n.º de entidades, RF relacionados, valor del grafo).
- **ToT:** (a) una tabla combinada vs. dos tablas vs. dos tablas + matriz RF↔C; (b) mantener 10 RF vs. añadir RF faltantes como *propuesta* (p. ej. autoría/publicación de simulaciones, P-09); (c) incluir o no un esbozo de patrón de recorrido por consulta para demostrar que el modelo la resuelve.
- **CoVe (base):** ¿≥8 RF? ¿5 consultas? ¿≥2 con 3+ entidades? ¿Todas las entidades citadas existen en el KG? ¿Cada consulta tiene un camino real de relaciones en el modelo? ¿Cada RF se rastrea a una necesidad del stakeholder? ¿IDs y nombres exactos?
- **SC:** entidades por consulta derivadas (1) de la lista del KG, (2) del camino de relaciones necesario, (3) de lo que pide el texto de la pregunta.

### F2 — Diccionario de entidades y propiedades
- **Contenido:** por entidad: descripción y tabla (propiedad, tipo de dato, obligatoria/opcional, única, descripción).
- **ToT:** (a) tratamiento de FKs heredadas: omitirlas / listarlas como "representada por relación" / sección aparte; (b) notación de tipos: SQL / Neo4j / ambas; (c) catálogos de valores en la columna de descripción vs. remitir a E4.
- **CoVe:** ¿12 entidades? ¿≥3 propiedades cada una? ¿4 atributos por propiedad? ¿Opcional = `nullable` del KG? ¿Única = `unique` del KG + RI-01/02/03/15? ¿Nombres exactos?
- **SC:** obligatoriedad de cada propiedad derivada (1) del `nullable` del KG, (2) de RI-04/RI-12, (3) del ciclo de vida de la entidad (OBS-10, OBS-11).

### F3 — Catálogo de relaciones
- **Contenido:** tabla (ID, entidad origen, relación, entidad destino, descripción, propiedades de la relación).
- **ToT:** (a) redacción de descripciones; (b) mantener `TIENE` o proponer otro nombre (como *propuesta*); (c) cómo explicar `GENERA` y `CORRESPONDE_A` reutilizadas.
- **CoVe:** ¿17 relaciones? ¿Origen/destino/dirección iguales a `domain_model` y `logical_graph_model`? ¿`DESARROLLA` con `peso` y `nivel_esperado`? ¿Cada consulta C-xx usa solo relaciones del catálogo?
- **SC:** significado de cada relación leído (1) desde el origen, (2) desde el destino, (3) desde la consulta que la usa; deben describir lo mismo.

### F4 — Tabla de restricciones de integridad
- **Contenido:** tabla (ID, nombre, categoría, descripción, elementos afectados, mecanismo en Neo4j / aplicación).
- **ToT:** (a) taxonomía de categorías (las 5 del enunciado); (b) mecanismo de implementación por restricción; (c) catálogos de valores faltantes (`Usuario.estado`, `Evidencia.visibilidad`, `Comparticion.estado`, `Paso.tipo`, `Consecuencia.impacto/tipo`) como *propuesta* o como pendiente.
- **CoVe:** ¿≥8? ¿Las 5 categorías cubiertas? ¿Cada restricción referencia elementos que existen en E2/E3? ¿El mecanismo propuesto existe en Neo4j (verificar qué constraints son de Community vs. Enterprise)? ¿Coherente con E2 (obligatorias/únicas)?
- **SC:** cada restricción clasificada y justificada por 3 rutas (enunciado, KG, consulta/regla de negocio que protege).

### F5 — Tabla de cardinalidades
- **Contenido:** tabla (ID, origen, relación, destino, card. origen→destino, card. destino→origen, ¿puede existir sin relacionarse?, ¿una o muchas?, mínimo, máximo, justificación).
- **ToT:** resolver casos dudosos: R06 (0..N vs. 1..N, OBS-03), R05 (paso final sin opciones), R03 (borrador vs. publicada), R16, R11.
- **CoVe:** ¿17 filas? ¿Las 3 preguntas del enunciado respondidas en cada fila? ¿Coincide con el KG o la diferencia está justificada? ¿Coherente con E2 (obligatoriedad) y E4 (RI-09, RI-13, etc.)?
- **SC:** cardinalidad derivada (1) del KG, (2) de las observaciones OBS-xx, (3) de las reglas de negocio/consultas.
- **Nota:** si una decisión cambia algo de E2–E4, se reabre el ciclo de esos entregables.

### F6 — Diagrama del modelo lógico
- **Contenido:** diagrama de nodos (etiquetas + propiedades clave), relaciones dirigidas con nombre, propiedades de relación y cardinalidades; texto breve de lectura del modelo.
- **ToT:** formato: Mermaid en .md (se ve en GitHub y se exporta a imagen) vs. Graphviz vs. Arrows.app; nivel de detalle (todas las propiedades vs. clave).
- **CoVe:** ¿12 nodos y 17 relaciones? ¿Direcciones y nombres iguales a E3? ¿Cardinalidades iguales a E5? ¿Propiedades iguales a E2? (comprobación automática parseando el diagrama).
- **SC:** el diagrama recorrido para responder C-01..C-05 por 3 lecturas distintas; si alguna consulta no puede resolverse, falta algo en el modelo.

### F7 — Conclusiones
- **Contenido:** respuesta a las 2 preguntas con ejemplos concretos del proyecto.
- **ToT:** estructura del argumento (teórico → ejemplo vs. ejemplo → generalización); qué ejemplos usar (MD-01..MD-05, C-03, C-05/P-07, RI-10/RI-11, R06).
- **CoVe:** ¿responde exactamente las 2 preguntas? ¿Cada ejemplo citado existe y es correcto en E1–E6?
- **SC:** 3 redacciones independientes de la tesis central; se conservan los argumentos que aparecen en la mayoría.

### F8 — Revisión de coherencia global
- Cruce de todos los entregables entre sí y contra el KG (nombres, conteos, cardinalidades, *propuestas* marcadas).
- Ejecutar ToT + CoVe + SC sobre el conjunto; cualquier cambio reabre el ciclo del entregable afectado.
- Actualizar `PROGRESS.md` y `CLAUDE.md` si alguna decisión quedó confirmada.

### F9 — Conversión final
- Solo tras aprobación del usuario. Convertir cada entregable a su formato final (tabla "Conversión final" de `PROGRESS.md`) y revisar el resultado convertido.

---

## 5. Puntos que probablemente requieran decisión del usuario

Se resolverán dentro de su fase con ToT/SC y se presentarán como *propuesta* si no hay base suficiente en el KG:

| Tema | Fase | Relación con el KG |
|---|---|---|
| R06: ¿una opción siempre genera consecuencia? (0..N vs. 1..N) | F5 | Inconsistencia R06 vs. OBS-03 |
| Tratamiento de FKs en el diccionario | F2 | Herencia relacional |
| Catálogos de valores faltantes | F4 | No definidos en el KG |
| ¿Añadir RF de autoría de simulaciones? | F1 | P-09 pendiente |
| Historial de progreso para C-05 | F1/F5/F7 | P-07 pendiente |
| Formato del diagrama | F6 | No definido |
