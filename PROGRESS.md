# PROGRESS.md — Actividad: Diseño del modelo lógico de una aplicación basada en grafos

Seguimiento de los entregables de la actividad (ver `docs/actividad.jpg`). Proyecto: **QATO'K**. Fuente de datos: `docs/KG.json` / `CLAUDE.md`.

**Estados:** ⬜ Pendiente · 🟨 En progreso · 🟧 Por corregir · ✅ Terminado

## Resumen

| # | Entregable | Estado | Archivo | Insumo en el KG |
|---|---|---|---|---|
| 1 | Tabla de requerimientos y consultas | ⬜ Pendiente | — | RF-01..RF-10, C-01..C-05 |
| 2 | Diccionario de entidades y propiedades | ⬜ Pendiente | — | E01..E12 |
| 3 | Catálogo de relaciones | ⬜ Pendiente | — | R01..R17 (sin descripción) |
| 4 | Tabla de restricciones de integridad | ⬜ Pendiente | — | RI-01..RI-15 |
| 5 | Tabla de cardinalidades | ⬜ Pendiente | — | Cardinalidades de R01..R17 |
| 6 | Diagrama del modelo lógico | ⬜ Pendiente | — | `logical_graph_model`, MD-01..MD-05 |
| 7 | Conclusiones (2 preguntas) | ⬜ Pendiente | — | — (redacción propia) |

---

## Detalle por entregable

### 1. Tabla de requerimientos y consultas — ⬜ Pendiente
**Criterios de la actividad**
- [ ] Al menos **8 requerimientos funcionales**.
- [ ] **5 consultas** que el sistema debe resolver.
- [ ] Al menos **2 consultas** involucran relaciones entre **3 o más entidades**.

**Observaciones**
- El KG tiene 10 RF (cumple ≥8) y 5 consultas; todas involucran 4–7 entidades (cumple holgadamente).
- Conviene mostrar en la tabla las entidades involucradas por consulta y, opcionalmente, el RF que atiende cada consulta.

### 2. Diccionario de entidades y propiedades — ⬜ Pendiente
**Criterios de la actividad**
- [ ] Todas las entidades necesarias para representar el dominio.
- [ ] Al menos **3 propiedades** por entidad.
- [ ] Por propiedad: **nombre, tipo de dato, obligatoria/opcional, única**.

**Observaciones**
- Las 12 entidades tienen ≥4 propiedades (cumple).
- Obligatoriedad: el KG solo marca `nullable: true` en algunas; el resto se asume obligatorio (RI-04). Hay que explicitarlo columna por columna.
- Las propiedades FK (`id_simulacion`, `id_paso`, …) son herencia del modelo relacional; en Neo4j se representan como relaciones. Decidir si se listan en el diccionario (marcándolas como "representada por relación") o se omiten.
- Tipos: el KG usa tipos SQL (VARCHAR, DECIMAL). Considerar añadir el tipo equivalente en Neo4j (String, Float, Integer, DateTime).

### 3. Catálogo de relaciones — ⬜ Pendiente
**Criterios de la actividad**
- [ ] Tabla con: **entidad origen, nombre de la relación, entidad destino, descripción de su significado**.

**Observaciones**
- El KG **no incluye descripciones** de las relaciones: hay que redactarlas.
- Incluir las propiedades de `DESARROLLA` (`peso`, `nivel_esperado`) según MD-01.
- `GENERA` y `CORRESPONDE_A` se usan con distintos pares de etiquetas; aclararlo en la descripción.
- `TIENE` (Simulacion→Intento) es un nombre genérico; se puede justificar o proponer otro nombre (marcándolo como *propuesta*).

### 4. Tabla de restricciones de integridad — ⬜ Pendiente
**Criterios de la actividad**
- [ ] Al menos **8 restricciones**.
- [ ] Considerar: unicidad de identificadores, propiedades obligatorias, valores permitidos, consistencia entre entidades, reglas de negocio.

**Observaciones**
- El KG tiene 15 (RI-01..RI-15) y cubre las 5 categorías. Clasificar cada una por categoría en la tabla.
- Indicar cómo se implementa en Neo4j (constraint de unicidad, existencia de propiedad, validación en aplicación) vs. lo que requiere lógica de aplicación (RI-10, RI-11, RI-14).
- Faltan catálogos de valores para algunas propiedades (`Usuario.estado`, `Evidencia.visibilidad`, `Comparticion.estado`, `Consecuencia.impacto/tipo`, `Paso.tipo`). Si se proponen, marcarlos como *propuesta*.

### 5. Tabla de cardinalidades — ⬜ Pendiente
**Criterios de la actividad** (usando la tabla Relación–Origen–Destino)
- [ ] ¿Puede existir una entidad sin relacionarse?
- [ ] ¿Puede relacionarse con una o muchas entidades?
- [ ] ¿Cuál es el mínimo y máximo permitido?

**Observaciones**
- El KG da cardinalidades para R01..R17; hay que traducirlas a respuestas explícitas a las 3 preguntas.
- ⚠️ **Inconsistencia detectada:** R06 `Opcion-GENERA->Consecuencia` tiene 0..N, pero OBS-03 dice "una opción puede generar **una o más** consecuencias" (1..N). Decidir cuál prevalece.
- R03 `Simulacion-CONTIENE->Paso` 0..N es coherente con OBS-11 (borrador sin pasos), pero una simulación PUBLICADA requiere ≥1 paso: mencionarlo como regla condicionada al estado.
- R05 `Paso-OFRECE->Opcion` 1..N: revisar si un paso final (sin decisión) debe ofrecer opciones.

### 6. Diagrama del modelo lógico — ⬜ Pendiente
**Criterios de la actividad**
- [ ] Construcción del modelo lógico orientado a grafos (nodos, relaciones, propiedades).

**Observaciones**
- 12 etiquetas y 17 relaciones. Incluir propiedades clave en nodos y las propiedades de `DESARROLLA`.
- Definir formato (Mermaid, Arrows.app, draw.io, SVG/PNG).
- Debe ser coherente con los entregables 2, 3 y 5.

### 7. Conclusiones — ⬜ Pendiente
- [ ] ¿Por qué no es suficiente identificar las entidades de una aplicación para construir una base de datos orientada a grafos?
- [ ] Explica cómo las consultas, las restricciones de integridad y las cardinalidades influyen en las decisiones de modelado.

**Observaciones**
- Apoyarse en ejemplos concretos del proyecto: MD-01..MD-05, C-03 (recorrido de decisiones), C-05 (evolución → P-07, un único `Progreso` consolidado no basta para el historial), RI-10/RI-11 (consistencia que el grafo no garantiza solo).

---

## Observaciones generales
- Respetar las reglas de `CLAUDE.md`: español, IDs exactos, marcar como *propuesta* todo lo que dependa de decisiones pendientes (P-xx).
- C-05 pide evolución en el tiempo, pero el modelo actual solo tiene un `Progreso` consolidado (RI-13, P-07 pendiente): señalarlo como limitación conocida.
- Pendiente definir el formato final de entrega (Markdown, Word, PDF, presentación).

## Bitácora
| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de PROGRESS.md con los 6 entregables + conclusiones; todos pendientes. |
