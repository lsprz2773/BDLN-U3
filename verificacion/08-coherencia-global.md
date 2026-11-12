# Verificación — F8: Revisión de coherencia global

Alcance: los 7 entregables entre sí, contra el KG v1.1 y contra las reglas de `CLAUDE.md`. Herramienta: `scripts/verificar.py` sin argumentos, que verifica todos los entregables y añade los cruces globales de F8.

## Ronda 1

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Cómo revisar la coherencia | A. relectura manual · B. solo el script · C. script + cruces nuevos para lo que ningún entregable comprueba solo + revisión manual del marcado de propuestas | **C** | Las comprobaciones por entregable no detectan contradicciones entre entregables |
| ¿Unir los entregables en un solo documento? | A. ahora · B. en F9 (conversión) | **B** | El formato final se decide al convertir; en Markdown cada entregable es más fácil de revisar por separado |

### CoVe
| Cruce | Resultado |
|---|---|
| E1–E7 contra el KG (`verificar.py`) | ✔ 0 fallos |
| KG v1.1 internamente coherente (etiquetas, relaciones, consultas conexas) | ✔ |
| E1 (Cypher) ↔ E3 (consultas que usa cada relación) | ✔ 17/17 (recalculado en F3) |
| E2 (FK y nulabilidad) ↔ E5 (cardinalidad del lado que tiene la FK) | ✔ 15/15 |
| E2 (marcas única/opcional) ↔ E6 (marcas en los nodos) | ✔ (script) |
| E5 ↔ E6 (cardinalidades) | ✔ (script) |
| **E3 (RI por relación) ↔ E4 (relaciones afectadas por cada RI)** | ✘ 3 diferencias: RI-15 sin R17 en E4; RI-23 sin R08 en E4; RI-21 de más en R17 (E3) → **corregido** en E3 y E4 (registrado en sus bitácoras). Cruce incorporado al script |
| P-xx de los catálogos (E2) ↔ RI-24 (E4) ↔ KG | ✔ {P-03, P-04, P-06, P-08, P-09, P-10} |
| Marcado de *propuestas* en todos los entregables (regla de `CLAUDE.md`) | ✘ E6 mostraba `destinatario?` sin marcarla; E7 presentaba el catálogo de `Comparticion.estado` como hecho → **corregido** (registrado en sus bitácoras) |
| Ningún entregable presenta MongoDB ni PostgreSQL como base principal | ✔ |
| Todas las referencias a IDs existen | ✔ (script) |

### Self-consistency
Se comprobó que tres fuentes describen el mismo modelo: (1) KG v1.1, (2) entregables E2 + E3 + E5 y (3) el diagrama E6. Las tres coinciden en 12 etiquetas, 55 propiedades, 17 relaciones, 14 tipos y 17 pares de cardinalidades.

**Cambios en la ronda 1:** 5, en 4 entregables (E3, E4, E6, E7). Cada corrección siguió su propio ciclo ToT → CoVe → SC. → Nueva ronda.

## Ronda 2
- **ToT:** sin decisiones nuevas.
- **CoVe:** `verificar.py` → **832 comprobaciones OK, 0 fallos, 0 avisos**; auditoría estructural del KG sin diferencias.
- **SC:** las tres fuentes siguen coincidiendo.
- **Resultado:** **ronda limpia → modelo coherente. F8 cerrada.**
