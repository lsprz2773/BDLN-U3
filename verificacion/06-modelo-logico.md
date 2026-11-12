# Verificación — Entregable 6: Diagrama del modelo lógico

Archivos: `entregables/06-modelo-logico.md` (fuente Mermaid + explicación) y `entregables/06-modelo-logico.png` (imagen renderizada) · Herramientas: `scripts/verificar.py 6` y `mermaid-cli` 11.4.2

## Ronda 1 (creación, v1)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Herramienta | A. Mermaid · B. Graphviz · C. Arrows.app (JSON + imagen) | **A** | Fuente de texto que el script puede verificar contra el KG, se ve en GitHub y se exporta a PNG para el .docx. B no está instalado; C no es verificable automáticamente |
| Tipo de diagrama Mermaid | A. `erDiagram` · B. `flowchart` con aristas etiquetadas · C. `classDiagram` | **B** | A y C imponen notación relacional u orientada a objetos; B representa un grafo de propiedades: nodos + relaciones dirigidas con nombre |
| Nivel de detalle | A. solo etiquetas · B. propiedades clave · C. todas las propiedades almacenadas con marcas de única y opcional | **C** | Integra E2 en el modelo y permite verificarlo propiedad por propiedad |
| Organización visual | A. sin agrupar · B. colores por zona (contenido / ejecución / resultados) | **B** | Facilita leer el modelo y explicar `Habilidad` como nodo que une las zonas |

### CoVe
| Pregunta de verificación | Resultado |
|---|---|
| ¿El Mermaid es sintácticamente válido? | ✔ Renderizado sin errores con `mermaid-cli` |
| ¿12 nodos y 17 relaciones = KG (origen, tipo, destino)? | ✔ (script) |
| ¿Cardinalidades del diagrama = E5 / KG? | ✔ (script, 17/17) |
| ¿Cada nodo muestra todas sus propiedades almacenadas? | ✔ (script) |
| ¿La imagen es legible? | ✘ La primera versión metía varias propiedades por línea y el ajuste de texto separaba "(U)" de su propiedad → **corregido**: una propiedad por línea y mayor ancho de ajuste; re-renderizado e inspeccionado |
| ¿Los saltos de la sección 4 están bien contados? | ✘ C-05 decía 6; el recorrido tiene 5 relaciones → **corregido**. C-01 = 3, C-02 = 7, C-03 = 7, C-04 = 5 ✔ |
| ¿55 propiedades almacenadas? | ✔ recalculado desde el KG |
| ¿Las marcas `(U)` y `?` coinciden con el diccionario? | ✔ 15 únicas y 7 opcionales; se añadió la comprobación al script (corrigiendo el análisis de las comillas del nodo) |

### Self-consistency
Se recorrieron C-01..C-05 sobre el diagrama por tres lecturas distintas: (1) la tabla de recorridos (sección 4), (2) los Cypher del entregable 1 y (3) las relaciones que el entregable 3 asocia a cada consulta. Las tres coinciden para las cinco consultas; ninguna necesita una relación ausente del diagrama.

**Cambios en la ronda 1:** 3 (legibilidad, conteo de C-05, redacción de GENERA) + comprobación nueva. → Nueva ronda.

## Ronda 2 (v2)
- **ToT:** sin decisiones nuevas.
- **CoVe:** `verificar.py` (E1–E6) → **0 fallos**; imagen revisada visualmente.
- **SC:** sin cambios.
- **Resultado:** **ronda limpia → entregable cerrado.**


## Corrección en F8 (revisión de coherencia global)

### Ronda 1
- **Origen:** la regla de `CLAUDE.md` exige marcar las *propuestas*. El diagrama mostraba `destinatario?` sin indicar que es una propuesta (P-06).
- **ToT:** A. quitarla del diagrama · B. mantenerla y marcarla en la leyenda. → **B**: E2 la documenta y el diagrama debe coincidir con E2.
- **CoVe:** el resto de los elementos del diagrama son ADOPTADOS (las propiedades de DESARROLLA existen por MD-01; solo sus rangos son propuesta y no aparecen en el diagrama). `verificar.py` → 0 fallos.
- **SC:** E2, E6 y el KG (`status: PROPOSED`) coinciden. 3/3.
- **Cambios:** 1 (leyenda).

### Ronda 2
- Sin cambios. **Corrección cerrada.**

## Corrección en F9 (conversión a .docx)

### Ronda 1
- **Origen:** el usuario pidió que los documentos no usen texto ni colores azules. La zona "Contenido" del diagrama usaba relleno y borde azules.
- **ToT:** A. gris neutro para la zona de contenido, conservando naranja y verde · B. todo en escala de grises · C. otro color (morado). → **A**: mantiene la distinción entre las tres zonas sin usar azul; C se acerca demasiado al azul.
- **CoVe:** se cambiaron `classDef contenido` y las dos menciones "azul" del texto (leyenda y sección 3). Se re-renderizó con el tema `neutral` de Mermaid; la imagen no contiene azul (revisada visualmente). `verificar.py` → 0 fallos.
- **SC:** el diagrama, la leyenda y la sección 3 usan el mismo nombre de color ("gris"). 3/3.
- **Cambios:** 1.

### Ronda 2
- Sin cambios. **Corrección cerrada.**
