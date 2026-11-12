# Presentación de la propuesta QATO'K

Material para preparar y dar la presentación. Todo se basa en los entregables de `entregables/` y en `docs/KG.json` v1.1.

| Material | Archivo en el repo | Versión en línea |
|---|---|---|
| Guía de estudio | `guia-estudio.pdf`, `guia-estudio.docx` y `guia-estudio.md` | [Guía de estudio — Propuesta QATO'K](https://claude.ai/artifact/AAsS7EuZKUoT39dzWBzM2X) (documento editable de Claude Docs) |
| Diapositivas (12) | `diapositivas.pdf` (12 páginas, 16:9) y `diapositivas/` (fuente: `deck.json` + una página HTML por diapositiva, con notas del orador en `<aside>`) | [Propuesta QATO'K — diapositivas](https://claude.ai/artifact/KSFF9u4bSJv8uy3BfmBbG1) |
| Explicación sencilla del proyecto (qué hace, cómo funciona una simulación, qué significan RF, C-01…C-05, RI, etc.) | `qatok-explicado.pdf`, `qatok-explicado.docx` y `qatok-explicado.md` (+ `simulacion-ramas.png`) | [QATO'K explicado](https://claude.ai/artifact/SdgJZVNVamMfLJSwNDKZcy) (documento de Claude Docs) |
| Diagrama de las tres zonas | `modelo-tres-zonas.png` | — |

**Regenerar los PDF:** `node scripts/diapositivas2pdf.js` (diapositivas, con Playwright) y LibreOffice sobre `guia-estudio.docx` (guía).

**Importante:** los enlaces en línea son privados hasta que su dueño los comparta desde el menú *Share* de cada página. Para presentar sin conexión, las diapositivas se descargan como PowerPoint o PDF desde el menú *Share › Export* de la página del deck.

## Orden de las diapositivas

| # | Diapositiva | Sección |
|---|---|---|
| 1 | Portada | La idea |
| 2 | El problema: la brecha entre estudiar y trabajar | La idea |
| 3 | La solución en 5 pasos | La idea |
| 4 | Tres zonas unidas por Habilidad | El modelo y por qué un grafo |
| 5 | Por qué una base de datos orientada a grafos | El modelo y por qué un grafo |
| 6 | Una consulta, un recorrido (C-03) | El modelo y por qué un grafo |
| 7 | Los siete entregables | Entregables |
| 8 | El modelo lógico completo | Entregables |
| 9 | Quién garantiza cada regla (restricciones y cardinalidades) | Entregables |
| 10 | Decisiones de modelado clave | Decisiones y cierre |
| 11 | Limitaciones conocidas y pendientes | Decisiones y cierre |
| 12 | Conclusión | Decisiones y cierre |

Las diapositivas usan una paleta sin azules (carbón, crema y naranja), como en los documentos .docx.
