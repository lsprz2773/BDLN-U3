# Verificación — Entregable 1: Tabla de requerimientos y consultas

Archivo: `entregables/01-requerimientos-consultas.md` · Fuente: KG v1.1 · Herramienta: `scripts/verificar.py 1`

## Ronda 1 (creación, v1)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Estructura | A. una tabla combinada · B. tabla RF + tabla de consultas + recorridos en Cypher + matriz RF↔C · C. solo dos tablas | **B** | El enunciado pide requerimientos y consultas. Los recorridos en Cypher **demuestran** que el modelo resuelve cada consulta y que esta toca 3+ entidades. La matriz conecta ambas partes |
| Número de RF | A. los 10 del KG · B. añadir un RF de autoría (P-09) | **A** | DEC-19: un RF sin entidades que lo soporten rompería la trazabilidad |
| Entidades de C-03 | A. añadir `Simulacion` · B. parametrizar solo por intento · C. reformular | **A** | La pregunta dice "durante una simulación". Generó **DEC-23** (KG actualizado) |
| C-02 sin `nivel_objetivo` (es nullable) | A. clasificar como "sin objetivo" · B. usar como respaldo el mayor `nivel_esperado` de DESARROLLA · C. umbral fijo inventado | **B** (en la ronda 1 se había escrito A) | RF-07 exige clasificar todas las habilidades; B usa datos del modelo; C inventa un valor |

### CoVe
| Pregunta de verificación (respondida contra el KG, no contra el borrador) | Resultado |
|---|---|
| ¿Están los 10 RF con sus IDs y en orden? | ✔ |
| ¿Las descripciones de los RF son las del KG? | ✘ Parafraseadas en RF-02, RF-03, RF-05 y RF-10 → **corregido**: texto literal del KG. Se añadió esta comprobación al script |
| ¿Las 5 consultas tienen el texto literal del KG? | ✔ |
| ¿Las entidades de cada consulta = `related_entities` del KG v1.1? | ✔ (script) |
| ¿Cada relación usada en los Cypher existe con esa dirección? | ✔ (script: 0 relaciones inválidas) |
| ¿Cada propiedad usada en los Cypher existe en su etiqueta o relación? | ✔ (script) |
| ¿Los Cypher son válidos semánticamente? | ✘ C-03 usaba `ORDER BY i.fecha_inicio` después de una agregación sin proyectarla (error en Cypher) → **corregido** proyectando `inicio` |
| ¿C-02 cuenta todos los tipos de retroalimentación? | ✘ Omitía PARCIAL (catálogo DEC-09) → **corregido** |
| ¿Hay ≥8 RF, 5 consultas y ≥2 consultas con 3+ entidades? | ✔ 10 / 5 / 5 |
| ¿La matriz RF↔C es coherente con la columna "RF relacionados"? | ✔ revisada fila por fila |
| Prueba del verificador: ¿detecta errores? | ✔ Se introdujeron 4 errores a propósito (RF inexistente, entidad faltante, relación invertida, propiedad inexistente) → los 6 fallos esperados fueron detectados; luego se restauró el archivo |

### Self-consistency
| Juicio | Ruta 1: lista del KG | Ruta 2: etiquetas del Cypher | Ruta 3: texto de la pregunta | Resultado |
|---|---|---|---|---|
| Entidades de C-01 | 4 | 4 | usuario, simulaciones, progreso, habilidades | 3/3 |
| Entidades de C-02 | 7 | 7 | usuario, fortalezas (habilidad), resultados de simulaciones (intento, respuesta, retroalimentación), progreso | 3/3 |
| Entidades de C-03 | 8 | 8 | usuario, simulación, decisiones (respuesta, paso, opción), consecuencias, retroalimentación | 3/3 |
| Entidades de C-04 | 6 | 6 | usuario, evidencias, habilidad, simulaciones (vía intento), compartir | 3/3 |
| Entidades de C-05 | 5 | 5 | habilidad, tiempo (intentos), simulaciones, usuario, progreso | 3/3 |
| RF-10 incluye `Respuesta` (el KG traza Usuario, Intento, Simulacion) | No | DEC-18: reanudar desde la última `secuencia` | RF-10 "sesiones cortas" requiere reanudar | 2–1 → se mantiene, justificado en las notas |

**Cambios en la ronda 1:** 4 (descripciones literales, ORDER BY de C-03, PARCIAL en C-02, respaldo de objetivo en C-02) + DEC-23. → Nueva ronda.

## Ronda 2 (v2)
- **ToT:** sin decisiones nuevas.
- **CoVe:** se revisaron otra vez los Cypher modificados: C-02 separa la agregación en dos `WITH` (no mezcla agregados con claves de agrupación en una expresión); C-03 ordena por alias proyectados. `verificar.py 1` → **163 OK, 0 fallos**.
- **SC:** se repitieron las 5 derivaciones de entidades; los resultados no cambian.
- **Resultado:** **ronda limpia → entregable cerrado.**
