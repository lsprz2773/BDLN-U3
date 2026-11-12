# PROGRESS.md — Actividad: Diseño del modelo lógico de una aplicación basada en grafos

Seguimiento de los entregables de la actividad (ver `docs/actividad.jpg`). Proyecto: **QATO'K**. Fuente de datos: `docs/KG.json` / `CLAUDE.md`. Plan de trabajo y protocolo de verificación: `PLAN.md`.

**Estados:** ⬜ Pendiente · 🟨 En progreso · 🟧 Por corregir · ✅ Terminado

## Auditoría previa del KG

✅ Realizada → `verificacion/00-auditoria-kg.md`. 20 hallazgos (1 🔴, 6 🟠, 7 🟡, 6 ⚪).
✅ Resuelta → `docs/decisiones-modelado.md` (DEC-01..DEC-22, decididas por Claude por delegación del usuario, verificadas con ToT/CoVe/SC en 2 rondas). Aplicadas en `docs/KG.json` v1.1.

## Resumen

| # | Entregable | Estado | Archivo | Insumo en el KG |
|---|---|---|---|---|
| 1 | Tabla de requerimientos y consultas | ⬜ Pendiente | `entregables/01-requerimientos-consultas.md` | RF-01..RF-10, C-01..C-05 (C-02/C-04 con Simulacion) |
| 2 | Diccionario de entidades y propiedades | ⬜ Pendiente | `entregables/02-diccionario-entidades.md` | E01..E12, `value_catalogs` |
| 3 | Catálogo de relaciones | ⬜ Pendiente | `entregables/03-catalogo-relaciones.md` | R01..R17 (sin descripción), `modeling_notes` |
| 4 | Tabla de restricciones de integridad | ⬜ Pendiente | `entregables/04-restricciones-integridad.md` | RI-01..RI-25, `neo4j_constraint_support` |
| 5 | Tabla de cardinalidades | ⬜ Pendiente | `entregables/05-cardinalidades.md` | R01..R17, `cardinality_convention` |
| 6 | Diagrama del modelo lógico | ⬜ Pendiente | `entregables/06-modelo-logico.md` | `logical_graph_model`, MD-01..MD-05 |
| 7 | Conclusiones (2 preguntas) | ⬜ Pendiente | `entregables/07-conclusiones.md` | `known_limitations`, DEC-xx |

---

## Actividades del enunciado (columna izquierda)

Cada actividad tiene requisitos propios que deben cumplirse aunque su resultado se presente dentro de un entregable de la tabla.

| # | Actividad | Requisitos | Estado | Se entrega en |
|---|---|---|---|---|
| A1 | **Analizar los requerimientos de la aplicación** | A1.1 Identificar ≥8 requerimientos funcionales · A1.2 Formular 5 consultas que el sistema debe resolver · A1.3 ≥2 consultas involucran relaciones entre 3+ entidades | ⬜ Pendiente | Entregable 1 |
| A2 | **Identificar entidades, propiedades y relaciones** | A2.1 Identificar las entidades necesarias para el dominio · A2.2 ≥3 propiedades por entidad con nombre, tipo de dato, obligatoria/opcional, única · A2.3 Tabla de relaciones con entidad origen, nombre, entidad destino y descripción | ⬜ Pendiente | Entregables 2 y 3 |
| A3 | **Establecer restricciones de integridad** | A3.1 Definir ≥8 restricciones · A3.2 Cubrir: unicidad de identificadores, propiedades obligatorias, valores permitidos, consistencia entre entidades, reglas de negocio | ⬜ Pendiente | Entregable 4 |
| A4 | **Determinar las cardinalidades** | A4.1 Usar la tabla Relación–Origen–Destino · A4.2 ¿Puede existir una entidad sin relacionarse? · A4.3 ¿Se relaciona con una o muchas? · A4.4 Mínimo y máximo permitido | ⬜ Pendiente | Entregable 5 |
| A5 | **Construcción del modelo lógico** | A5.1 Integrar entidades, propiedades, relaciones, restricciones y cardinalidades en el modelo de grafos | ⬜ Pendiente | Entregable 6 |
| A6 | **Conclusiones** | A6.1 ¿Por qué no basta identificar entidades para construir una BD de grafos? · A6.2 Cómo influyen consultas, restricciones y cardinalidades en el modelado | ⬜ Pendiente | Sección de conclusiones |

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
- ✅ R06 resuelta: **1..N** (DEC-02).
- R03 `Simulacion-CONTIENE->Paso` 0..N es coherente con OBS-11 (borrador sin pasos), pero una simulación PUBLICADA requiere ≥1 paso: mencionarlo como regla condicionada al estado.
- ✅ R05 resuelta: se mantiene 1..N; las rutas terminan en opción terminal (DEC-03).

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
- **Formato:** se trabaja todo en `.md` durante el modelado. Al final cada entregable se convierte al formato que le corresponda (.docx u otro, según el entregable). Ver checklist "Conversión final" abajo.

## Conversión final (al terminar el modelado)

| # | Entregable | Formato final | Estado |
|---|---|---|---|
| 1 | Tabla de requerimientos y consultas | .docx (por confirmar) | ⬜ Pendiente |
| 2 | Diccionario de entidades y propiedades | .docx (por confirmar) | ⬜ Pendiente |
| 3 | Catálogo de relaciones | .docx (por confirmar) | ⬜ Pendiente |
| 4 | Tabla de restricciones de integridad | .docx (por confirmar) | ⬜ Pendiente |
| 5 | Tabla de cardinalidades | .docx (por confirmar) | ⬜ Pendiente |
| 6 | Diagrama del modelo lógico | Imagen/PDF (por confirmar) | ⬜ Pendiente |
| 7 | Conclusiones | .docx (por confirmar) | ⬜ Pendiente |

## Bitácora
| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de PROGRESS.md con los 6 entregables + conclusiones; todos pendientes. |
| 2026-11-12 | Se añaden explícitamente las actividades A1–A6 de la columna izquierda del enunciado, con sus requisitos y el entregable donde se presentan. |
| 2026-11-12 | Decisión de formato: todo en .md durante el modelado; conversión al formato final de cada entregable al terminar. |
| 2026-11-12 | Creación de PLAN.md: fases F0–F9 y protocolo de verificación ToT + CoVe + self-consistency por cada creación y corrección. |
| 2026-11-12 | Auditoría del KG (2 rondas de verificación): estructura coherente; 20 hallazgos de significado y completitud con resoluciones propuestas. |
| 2026-11-12 | Decisiones DEC-01..DEC-22 (`docs/decisiones-modelado.md`) y KG v1.1. Carpeta única de entregables: `entregables/`. |
