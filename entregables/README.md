# Entregables — QATO'K

Carpeta única de entregables de la actividad *Diseño del modelo lógico de una aplicación basada en grafos*.

| # | Archivo | Entregable |
|---|---|---|
| 1 | `01-requerimientos-consultas.md` | Tabla de requerimientos y consultas |
| 2 | `02-diccionario-entidades.md` | Diccionario de entidades y propiedades |
| 3 | `03-catalogo-relaciones.md` | Catálogo de relaciones |
| 4 | `04-restricciones-integridad.md` | Tabla de restricciones de integridad |
| 5 | `05-cardinalidades.md` | Tabla de cardinalidades |
| 6 | `06-modelo-logico.md` + `06-modelo-logico.png` | Diagrama del modelo lógico (fuente Mermaid e imagen) |
| 7 | `07-conclusiones.md` | Conclusiones |

Fuente: `docs/KG.json` v1.1. Estado: ver `PROGRESS.md` (los 7 terminados y verificados). Comprobación automática: `python3 scripts/verificar.py`.

Para regenerar la imagen del diagrama: extraer el bloque `mermaid` de `06-modelo-logico.md` y renderizarlo con `@mermaid-js/mermaid-cli` (`mmdc`).
