# Verificación — Entregable 2: Diccionario de entidades y propiedades

Archivo: `entregables/02-diccionario-entidades.md` · Fuente: KG v1.1 · Herramienta: `scripts/verificar.py 2`

## Ronda 1 (creación, v1)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Claves foráneas heredadas | A. omitirlas · B. listarlas como filas "representada por relación" · C. sacarlas de la tabla y explicar debajo de cada entidad qué relación sustituye a cada clave | **C** | A pierde la trazabilidad con el modelo relacional; B mezcla en una misma tabla propiedades almacenadas y no almacenadas y engaña al conteo de ≥3 propiedades; C es correcta para Neo4j y conserva la trazabilidad |
| Notación del tipo | A. solo SQL · B. solo Neo4j · C. ambas | **C** | DEC-20; el KG está en SQL y la base principal es Neo4j |
| Unicidad compuesta (`orden`, `secuencia`) | A. "Sí" · B. "No" con aclaración del ámbito · C. columna aparte | **B** | "Sí" sería falso (el valor se repite entre simulaciones o intentos); una columna aparte complica la tabla para solo 2 casos |
| Catálogos | A. solo en la descripción · B. solo en una tabla aparte · C. en ambos | **C** | La fila se lee de forma autónoma y la tabla de catálogos sirve de referencia para E4 |
| Propiedades de relación | A. omitirlas · B. sección propia | **B** | DESARROLLA tiene propiedades (MD-01) y el enunciado pide el tipo de cada propiedad |

### CoVe
| Pregunta de verificación | Resultado |
|---|---|
| ¿12 entidades, con ID y nombre iguales a los del KG? | ✔ (script) |
| ¿Cada tabla tiene exactamente las propiedades del KG sin FK? | ✔ (script) |
| ¿Cada entidad tiene ≥3 propiedades? | ✔ mínimo 3 (Opcion, Respuesta, Progreso) |
| ¿Tipo SQL igual al KG y tipo Neo4j según el mapeo? | ✔ (script, 61 propiedades) |
| ¿Obligatoria = no `nullable` en el KG? | ✔ (script) |
| ¿Única = `unique` o PK en el KG? | ✔ (script) |
| ¿Cada FK del KG aparece explicada con su relación? | ✔ 15/15 (script) |
| ¿Tabla resumen correcta? | ✔ recalculada de forma independiente desde el KG; se añadió la comprobación al script |
| ¿Las descripciones de las entidades son las del KG? | ✔ |
| ¿La convención de "Única" es precisa? | ✘ Decía "ninguna otra entidad del mismo tipo" → **corregido**: "ningún otro nodo con la misma etiqueta" |
| ¿La normalización del correo está bien descrita? | ✘ "sin espacios" era ambiguo → **corregido**: "sin espacios al inicio o al final" |
| ¿Se justifica guardar el UUID como propiedad en Neo4j? | ✘ No se explicaba → **añadido**: `elementId` puede reutilizarse tras borrar un nodo y no sirve como referencia estable hacia PostgreSQL |
| ¿Se menciona RI-08 junto a DESARROLLA? | ✘ → **añadido** |

### Self-consistency (obligatoriedad)
| Propiedad | Ruta 1: `nullable` del KG | Ruta 2: RI-04 / RI-12 | Ruta 3: ciclo de vida (OBS-10, OBS-11, estados) | Resultado |
|---|---|---|---|---|
| Intento.fecha_fin | Opcional | Obligatoria si COMPLETADO | EN_CURSO no tiene fin | Opcional condicional (3/3) |
| Intento.puntuacion | Opcional | Solo rango 0–100 | EN_CURSO sin puntuación | Opcional (3/3) |
| Simulacion.descripcion | Obligatoria | Esencial | Un BORRADOR podría no tenerla | Obligatoria (2–1) |
| Habilidad.nivel_objetivo | Opcional | — | Puede no definirse (P-08) | Opcional (3/3) |
| Comparticion.fecha_expiracion | Opcional | RI-21 si existe | Enlaces sin caducidad | Opcional (3/3) |
| Comparticion.destinatario | Opcional (propuesta) | — | Enlace abierto | Opcional (3/3) |
| Respuesta.secuencia | Obligatoria | RI-16 | Toda respuesta tiene posición | Obligatoria (3/3) |

**Cambios en la ronda 1:** 4 (convención de unicidad, normalización del correo, justificación del UUID, nota RI-08) + nueva comprobación en el script. → Nueva ronda.

## Ronda 2 (v2)
- **ToT:** sin decisiones nuevas.
- **CoVe:** `verificar.py 1 2` → **460 OK, 0 fallos** (incluye la tabla resumen). Se revisaron los cambios: ninguno altera tipos, obligatoriedad ni unicidad.
- **SC:** se repitió la tabla de obligatoriedad; sin cambios.
- **Resultado:** **ronda limpia → entregable cerrado.**
