# database/

Esquemas, cargas y consultas de las 3 bases, organizados como sugiere la guía (§10). Cada carpeta tiene un **dueño**, que es la referencia de esa base: si cambias algo de otra base, avísale.

| Carpeta | Base | Dueño | Subcarpetas |
|---|---|---|---|
| `relational/` | PostgreSQL | B | `schema/` (DDL: tablas, PK, FK, CHECK, índices) · `data/` (cargador desde `seed/dataset.json`) · `queries/` (consultas representativas) |
| `document/` | MongoDB | C | `validators/` (`$jsonSchema` por colección) · `data/` (cargador) · `queries/` |
| `graph/` | Neo4j | A | Hoy: scripts de la actividad anterior. En la fase 1: `schema/`, `data/` (proyección desde `seed/`), `queries/`, `tests/` |
| `seed/` | Las 3 | A (los cambios los aprueban los 3) | `dataset.json` + `validar_dataset.py` |

Qué datos van en cada base: `docs/modelos/matriz-propiedad.md`. Nombres y tipos: `context/convenciones.md`.
