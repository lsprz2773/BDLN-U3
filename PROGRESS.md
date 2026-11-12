# PROGRESS.md — Actividad: Diseño del modelo lógico de una aplicación basada en grafos

Seguimiento de los entregables de la actividad (ver `docs/actividad.jpg`). Proyecto: **QATO'K**.
- **Fuente de datos:** `docs/KG.json` v1.1 / `CLAUDE.md`.
- **Decisiones:** `docs/decisiones-modelado.md` (DEC-01..DEC-23).
- **Plan y protocolo de verificación:** `PLAN.md`.
- **Verificación automática:** `python3 scripts/verificar.py`.

**Estados:** ⬜ Pendiente · 🟨 En progreso · 🟧 Por corregir · ✅ Terminado

## Auditoría previa del KG

- ✅ Realizada → `verificacion/00-auditoria-kg.md`. 20 hallazgos (1 🔴, 6 🟠, 7 🟡, 6 ⚪).
- ✅ Resuelta → `docs/decisiones-modelado.md` (DEC-01..DEC-22 en F0.5, DEC-23 surgida en F1). Decisiones tomadas por Claude por delegación del usuario y verificadas con ToT, CoVe y SC. Aplicadas en `docs/KG.json` v1.1.

## Resumen

| # | Entregable | Estado | Archivo | Rondas | Verificación |
|---|---|---|---|---|---|
| 1 | Tabla de requerimientos y consultas | ✅ Terminado | `entregables/01-requerimientos-consultas.md` | 2 | `verificacion/01-requerimientos-consultas.md` |
| 2 | Diccionario de entidades y propiedades | ✅ Terminado | `entregables/02-diccionario-entidades.md` | 2 | `verificacion/02-diccionario-entidades.md` |
| 3 | Catálogo de relaciones | ✅ Terminado | `entregables/03-catalogo-relaciones.md` | 3 + corrección F8 | `verificacion/03-catalogo-relaciones.md` |
| 4 | Tabla de restricciones de integridad | ✅ Terminado | `entregables/04-restricciones-integridad.md` | 2 + corrección F8 | `verificacion/04-restricciones-integridad.md` |
| 5 | Tabla de cardinalidades | ✅ Terminado | `entregables/05-cardinalidades.md` | 2 | `verificacion/05-cardinalidades.md` |
| 6 | Diagrama del modelo lógico | ✅ Terminado | `entregables/06-modelo-logico.md` + `.png` | 2 + corrección F8 | `verificacion/06-modelo-logico.md` |
| 7 | Conclusiones (2 preguntas) | ✅ Terminado | `entregables/07-conclusiones.md` | 3 + corrección F8 | `verificacion/07-conclusiones.md` |
| — | Coherencia global (F8) | ✅ Terminado | — | 2 | `verificacion/08-coherencia-global.md` |

**Estado de la verificación automática:** 832 comprobaciones OK, 0 fallos.

---

## Actividades del enunciado (columna izquierda)

| # | Actividad | Requisitos | Estado | Se entrega en |
|---|---|---|---|---|
| A1 | **Analizar los requerimientos de la aplicación** | ✅ A1.1 10 RF (≥8) · ✅ A1.2 5 consultas · ✅ A1.3 5 consultas con 3+ entidades (≥2) | ✅ | Entregable 1 |
| A2 | **Identificar entidades, propiedades y relaciones** | ✅ A2.1 12 entidades · ✅ A2.2 3–6 propiedades por entidad con nombre, tipo, obligatoria y única · ✅ A2.3 17 relaciones con origen, nombre, destino y descripción | ✅ | Entregables 2 y 3 |
| A3 | **Establecer restricciones de integridad** | ✅ A3.1 25 restricciones (≥8) · ✅ A3.2 las 5 categorías cubiertas | ✅ | Entregable 4 |
| A4 | **Determinar las cardinalidades** | ✅ A4.1 tabla Relación–Origen–Destino · ✅ A4.2 existencia sin relaciones (por relación y por entidad) · ✅ A4.3 una o muchas · ✅ A4.4 mínimo y máximo | ✅ | Entregable 5 |
| A5 | **Construcción del modelo lógico** | ✅ A5.1 diagrama con nodos, propiedades, relaciones y cardinalidades, verificado contra el KG | ✅ | Entregable 6 |
| A6 | **Conclusiones** | ✅ A6.1 · ✅ A6.2 | ✅ | Entregable 7 |

---

## Detalle por entregable

### 1. Tabla de requerimientos y consultas — ✅
- [x] ≥8 RF (10, descripción literal del KG + necesidad que atiende + entidades).
- [x] 5 consultas (texto literal del KG).
- [x] ≥2 consultas con 3+ entidades (las 5: 4–8 entidades).
- **Extra:** recorrido Cypher de cada consulta, verificado contra el modelo; matriz RF↔consultas.
- **Observaciones:** limitaciones documentadas: C-02 atribuye el desempeño por simulación (LIM-01); C-05 es una aproximación (LIM-02, P-07).

### 2. Diccionario de entidades y propiedades — ✅
- [x] 12 entidades. [x] ≥3 propiedades por entidad. [x] Nombre, tipo SQL y Neo4j, obligatoria/opcional, única.
- **Observaciones:** las FK se explican como relaciones. Se agregan las propiedades de DESARROLLA y una tabla de catálogos. Los valores *propuestos* están marcados.

### 3. Catálogo de relaciones — ✅
- [x] Origen, nombre, destino y descripción de las 17 relaciones, con sus propiedades y las consultas y reglas que las usan.

### 4. Tabla de restricciones de integridad — ✅
- [x] 25 restricciones (≥8). [x] 5 categorías.
- **Extra:** mecanismo en Neo4j ([N]/[E]/[A]), DDL de constraints y validaciones transaccionales de referencia.
- **Observaciones:** RI-24 y RI-25 son *propuestas*. Los ciclos entre pasos quedan pendientes (P-04).

### 5. Tabla de cardinalidades — ✅
- [x] Las 3 preguntas del enunciado para las 17 relaciones. [x] Tabla de existencia por entidad. [x] Cardinalidades condicionadas.

### 6. Diagrama del modelo lógico — ✅
- [x] Diagrama en Mermaid renderizado a PNG, con 12 nodos, 55 propiedades, 17 relaciones y cardinalidades. [x] Lectura del modelo y comprobación de las 5 consultas sobre el diagrama.

### 7. Conclusiones — ✅
- [x] Pregunta 1. [x] Pregunta 2. Todas las afirmaciones están verificadas contra los entregables.

---

## Observaciones generales
- Todo se trabajó en `.md`, como se acordó. Los temas que dependen de decisiones pendientes (P-xx) están marcados como *propuesta* en cada entregable.
- **Pendiente de revisión del usuario:** las *propuestas* (catálogos, rangos, `Comparticion.destinatario`, RI-24, RI-25) y las decisiones DEC-01..DEC-23.

## Implementación en Neo4j (F10) — ✅

Carpeta `neo4j/` (ver su README). Neo4j 5.26 LTS Community: 15 restricciones, 9 índices, 51 nodos y 71 relaciones de ejemplo (uno o más casos por consulta C-01..C-05), pruebas de humo y limpieza. **76 pruebas, 0 fallos** (`neo4j/resultado-pruebas.txt`). Verificación: `verificacion/09-neo4j.md`.

- [x] Restricciones · [x] Índices · [x] Nodos de ejemplo por consulta · [x] Relaciones · [x] Pruebas de humo · [x] Datos retirados

## Conversión final (F9)

Generada con `node scripts/md2docx.js` → `entregables/docx/`. Estilo sobrio: texto negro, encabezados de tabla en gris y sin azul (también se neutralizaron los estilos azules que la plantilla trae pero no usa). Los 7 archivos pasaron la validación de esquema y se revisaron visualmente renderizados a PDF.

| # | Entregable | Formato final | Estado |
|---|---|---|---|
| 1 | Tabla de requerimientos y consultas | `entregables/docx/01-requerimientos-consultas.docx` (horizontal) | ✅ |
| 2 | Diccionario de entidades y propiedades | `entregables/docx/02-diccionario-entidades.docx` (horizontal) | ✅ |
| 3 | Catálogo de relaciones | `entregables/docx/03-catalogo-relaciones.docx` (horizontal) | ✅ |
| 4 | Tabla de restricciones de integridad | `entregables/docx/04-restricciones-integridad.docx` (horizontal) | ✅ |
| 5 | Tabla de cardinalidades | `entregables/docx/05-cardinalidades.docx` (horizontal) | ✅ |
| 6 | Diagrama del modelo lógico | `entregables/docx/06-modelo-logico.docx` + `entregables/06-modelo-logico.png` | ✅ |
| 7 | Conclusiones | `entregables/docx/07-conclusiones.docx` (vertical) | ✅ |

## Bitácora
| Fecha | Cambio |
|---|---|
| 2026-11-12 | Creación de PROGRESS.md con los 6 entregables + conclusiones; todos pendientes. |
| 2026-11-12 | Se añaden explícitamente las actividades A1–A6 de la columna izquierda del enunciado. |
| 2026-11-12 | Decisión de formato: todo en .md durante el modelado; conversión al formato final al terminar. |
| 2026-11-12 | Creación de PLAN.md: fases F0–F9 y protocolo de verificación ToT + CoVe + self-consistency. |
| 2026-11-12 | Auditoría del KG: estructura coherente; 20 hallazgos con resoluciones propuestas. |
| 2026-11-12 | Decisiones DEC-01..DEC-22 y KG v1.1. Carpeta única de entregables: `entregables/`. |
| 2026-11-12 | F0: `scripts/verificar.py` (probado introduciendo errores a propósito). |
| 2026-11-12 | F1: entregable 1 (2 rondas). Surge DEC-23 (Simulacion en C-03). |
| 2026-11-12 | F2: entregable 2 (2 rondas). |
| 2026-11-12 | F3: entregable 3 (3 rondas). |
| 2026-11-12 | F4: entregable 4 (2 rondas); ediciones de Neo4j confirmadas por búsqueda. RI-24 actualizada en el KG. |
| 2026-11-12 | F5: entregable 5 (2 rondas). |
| 2026-11-12 | F6: entregable 6 (2 rondas); diagrama renderizado con mermaid-cli. |
| 2026-11-12 | F7: entregable 7 (3 rondas). |
| 2026-11-12 | F8: coherencia global (2 rondas); 5 correcciones en E3, E4, E6 y E7, cada una con su ciclo de verificación. |
| 2026-11-12 | F9: conversión a .docx sin azul; diagrama re-renderizado en gris/naranja/verde (corrección registrada en `verificacion/06-modelo-logico.md`). |
| 2026-11-12 | Presentación: guía de estudio (Claude Docs + `presentacion/guia-estudio.md`/.docx) y deck de 12 diapositivas (fuente en `presentacion/diapositivas/`). Ver `presentacion/README.md`. |
| 2026-11-12 | PDF de la guía de estudio (`presentacion/guia-estudio.pdf`, 5 páginas) y de las diapositivas (`presentacion/diapositivas.pdf`, 12 páginas). |
| 2026-11-12 | F10: implementación en Neo4j (restricciones, índices, datos de ejemplo, pruebas de humo, limpieza). 76 pruebas, 0 fallos; se corrigieron 12 pruebas que pasaban sin comprobar nada. |
| 2026-11-12 | Documento «QATO'K explicado» (Claude Docs) y su copia en `presentacion/qatok-explicado.md`/.docx/.pdf. |
| 2026-11-12 | Diapositivas formalizadas: sin códigos internos (C-03, R06, RF), referencias al KG, al script ni a documentos internos; notas del orador en lenguaje formal. PDF regenerado. |
