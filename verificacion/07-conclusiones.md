# Verificación — Entregable 7: Conclusiones

Archivo: `entregables/07-conclusiones.md` · Herramienta: `scripts/verificar.py 7` + comprobación manual de afirmaciones

## Ronda 1 (creación, v1)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Estructura del argumento | A. teoría y después ejemplos · B. solo ejemplos · C. tesis + argumentos numerados, cada uno con un ejemplo concreto de QATO'K + síntesis | **C** | Responde con claridad, demuestra comprensión general y se apoya en evidencia del propio proyecto |
| Pregunta 2 | A. un párrafo mezclado · B. una subsección por factor (consultas, restricciones, cardinalidades) + síntesis de cómo interactúan | **B** | La pregunta nombra tres factores; la síntesis muestra que se revisan entre sí |
| Ejemplos | Candidatos: MD-01..05, DEC-01/02/03/05/09/23, LIM-01/02, R09/R14, RI-10/13/17/23, P-07 | Todos los que **cambiaron** una decisión del modelo | Un ejemplo que cambió el modelo prueba la influencia mejor que uno que solo la ilustra |

### Self-consistency (tesis central)
Se redactaron tres tesis independientes para la pregunta 1:
- **T1:** las entidades solo definen nodos; el valor del grafo está en las relaciones.
- **T2:** el modelo se guía por las consultas; las entidades no dicen qué recorridos se necesitan.
- **T3:** las entidades no incluyen reglas (obligatoriedad, unicidad, cardinalidad), y Neo4j no impone un esquema.

Argumentos presentes en al menos 2 de 3 tesis (se conservan): relaciones con dirección y significado (T1, T2); nodo, relación o propiedad (T1, T2); necesidad de reglas porque Neo4j no impone un esquema (T1, T3); ambigüedades que aparecen al recorrer (T2, T3). El argumento de las claves foráneas (solo en T3) se conservó porque está respaldado por un cambio real del modelo (DEC-01).

### CoVe (afirmaciones verificadas una por una)
| Afirmación | Fuente | Resultado |
|---|---|---|
| 17 relaciones de 14 tipos | KG / E3 | ✔ |
| 15 claves foráneas → relaciones | KG | ✔ |
| `Respuesta` quedaba con 2 propiedades | KG / auditoría H-01 | ✔ |
| 9 de 12 entidades dependen de una relación obligatoria | E5, sección 4 | ✔ |
| Las consultas recorren de 3 a 7 relaciones | E6, sección 4 (3, 7, 7, 5, 5) | ✔ |
| "19 de las 25 restricciones se validan en la aplicación" | E4, columna de mecanismo | ✘ Recontado de forma automática: **17** solo en la aplicación, **6** mixtas, **2** sin validación en la aplicación → **corregido** |
| "RI-01 y RI-03 las garantiza Neo4j por completo" (redacción intermedia) | E4: RI-01 exige existencia, que es solo Enterprise | ✘ → **corregido**: RI-03 en cualquier edición; RI-01 solo en Enterprise |
| Una relación solo une dos nodos (no hay hiperaristas) | Modelo de grafo de propiedades | ✔ |
| RI-08 y RI-13 llevan a usar `MERGE` | E4 | ✔ |
| Todas las referencias (MD, DEC, LIM, RI, P) existen | script | ✔ |
| Se responden literalmente las 2 preguntas del enunciado | script | ✔ |

**Cambios en la ronda 1:** 1 (conteo de restricciones). → Nueva ronda.

## Ronda 2 (v2)
- **CoVe:** al revisar la frase corregida se detectó que atribuía a RI-01 una garantía completa en cualquier edición → **corregido**. → Nueva ronda.

## Ronda 3 (v3)
- **ToT:** sin decisiones nuevas.
- **CoVe:** se releyeron todas las afirmaciones numéricas; `verificar.py` (E1–E7) → **0 fallos**.
- **SC:** la tesis y los argumentos se mantienen.
- **Resultado:** **ronda limpia → entregable cerrado.**
