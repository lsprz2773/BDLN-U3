# Verificación — Entregable 3: Catálogo de relaciones

Archivo: `entregables/03-catalogo-relaciones.md` · Fuente: KG v1.1 · Herramienta: `scripts/verificar.py 3`

## Ronda 1 (creación, v1)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Estilo de las descripciones | A. definición corta · B. significado + a cuántos elementos se liga cada extremo, en palabras · C. con ejemplo concreto | **B** | Explica el significado en ambos sentidos sin repetir la notación de cardinalidad (que corresponde a E5); C alargaría la tabla y dificultaría convertirla a .docx |
| Columna extra de trazabilidad | A. sin ella · B. "Consultas y reglas que la usan" | **B** | Demuestra que ninguna relación sobra; base para las conclusiones |
| `TIENE` | A. renombrar a `DE_SIMULACION` (propuesta) · B. conservarla y explicar su lectura | **B** | DEC-15: fidelidad al KG |
| Tipos reutilizados | A. renombrar (GENERA_CONSECUENCIA…) · B. conservar y explicar | **B** | DEC-16 |

### CoVe
| Pregunta de verificación | Resultado |
|---|---|
| ¿17 relaciones con origen, tipo y destino iguales al KG? | ✔ (script) |
| ¿Solo R04 tiene propiedades, y son `peso` y `nivel_esperado`? | ✔ (script) |
| ¿Las consultas listadas en cada relación son las que de verdad la recorren? | ✔ Se recalcularon **de forma independiente** analizando los Cypher del entregable 1: 17/17 coinciden |
| ¿Las RI listadas en cada relación son todas las que la usan? | ✘ Se derivó por separado, desde el texto de cada RI, qué relaciones toca: faltaban RI-10 y RI-20 en R02, RI-10 y RI-23 en R08, y RI-11 en R05 → **corregido** |
| ¿"14 tipos distintos" es correcto? | ✔ |

### Self-consistency (significado de cada relación)
Para cada relación se comparó la descripción leída (1) desde el origen, (2) desde el destino y (3) desde la consulta que la usa. Ejemplos:
| Relación | Desde el origen | Desde el destino | Desde la consulta | ¿Coinciden? |
|---|---|---|---|---|
| R07 CONDUCE_A | La opción lleva a un paso o a ninguno (terminal) | Varios caminos pueden converger en un paso | RF-03 navegación; RI-23 fin del intento | ✔ |
| R12 TIENE_PROGRESO | Un usuario, un progreso por habilidad | Cada progreso es de un usuario | C-01/C-02/C-05 parten del usuario | ✔ |
| R15 PRODUCE | El intento origina evidencias | La evidencia proviene de un intento | C-04 "en qué simulaciones las obtuvo" | ✔ |
Sin discrepancias en las 17 relaciones.

**Cambios en la ronda 1:** 3 filas de trazabilidad de RI. → Nueva ronda.

## Ronda 2 (v2)
- **ToT:** sin decisiones nuevas.
- **CoVe:** al revisar la nota 4 contra el KG: "Cada relación sustituye a una clave foránea; la excepción es R16" es **falso**: el KG tiene 15 FK para 17 relaciones, y R04 (DESARROLLA) tampoco tiene FK → **corregido**: "15 de 17; las excepciones son R04 y R16". Conteo de FK confirmado con el KG (15).
- **SC:** sin cambios.
- **Cambios:** 1. → Nueva ronda.

## Ronda 3 (v3)
- **ToT:** sin decisiones nuevas.
- **CoVe:** se revisaron las 5 notas una por una contra el KG (deducibilidad de R09 = R10 + R05 y de R14 = R01 + R15; conteo de tipos reutilizados). `verificar.py 1 2 3` → **0 fallos**.
- **SC:** sin cambios.
- **Resultado:** **ronda limpia → entregable cerrado.**
