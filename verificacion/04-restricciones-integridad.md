# Verificación — Entregable 4: Tabla de restricciones de integridad

Archivo: `entregables/04-restricciones-integridad.md` · Fuente: KG v1.1 · Herramienta: `scripts/verificar.py 4`

## Ronda 1 (creación, v1)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Taxonomía | A. categorías propias · B. las 5 del enunciado, con varias por restricción si aplica | **B** | Permite demostrar la cobertura que pide el enunciado |
| Mecanismo | A. no indicarlo · B. nativo o aplicación · C. tres niveles: [N] cualquier edición / [E] solo Enterprise / [A] aplicación | **C** | DEC-12; la diferencia de ediciones cambia lo que garantiza la base |
| Implementación de referencia | A. ninguna · B. solo DDL de constraints · C. DDL + ejemplos de validación transaccional | **C** | Muestra cómo se cumplen en la práctica las reglas que Neo4j no garantiza (RI-08, RI-10, RI-16, RI-22) |
| Unicidades compuestas (RI-08, RI-13, RI-16, RI-18) | A. "Unicidad de identificadores" con nota aclaratoria · B. reclasificarlas como "Consistencia" o "Valores" | **A** | SC: lectura literal del enunciado → B; implementación en el KG ("UNIQUE compuesto") → A; claridad (agrupar unicidades) → A. 2–1 → A, con nota explícita |

### CoVe
| Pregunta de verificación | Resultado |
|---|---|
| ¿25 RI con IDs iguales al KG y estado coherente (Propuesta = PROPOSED)? | ✔ (script) |
| ¿Las 5 categorías cubiertas y la tabla de cobertura igual a las filas? | ✔ (script) |
| ¿Las propiedades y relaciones de los bloques Cypher existen? | ✔ (script; se corrigió el propio verificador para analizar cada sentencia por separado, porque la variable `n` se reutiliza entre sentencias) |
| ¿Las ediciones de Neo4j son correctas? | ✔ Confirmado con una segunda búsqueda: *Cypher Manual* 5 marca existence/type/key como Enterprise; la restricción de tipo es de la versión 5.9; GraphAcademy confirma existence = Enterprise |
| ¿Neo4j tiene CHECK, relaciones obligatorias o unicidad de pares? | ✔ No → mecanismo [A] |
| ¿Las descripciones conservan el significado del KG? | ✘ RI-15 decía que una evidencia PRIVADA "solo se consulta mediante un enlace", lo que excluía a su dueño → **corregido** |
| ¿Las P-xx de RI-24 cubren todos los catálogos que incluye? | ✘ Solo citaba P-03, P-08 y P-09; los catálogos también dependen de P-04, P-06 y P-10 (entregable 2) → **corregido** en E4 y en el KG |
| ¿El Cypher de registro de respuesta es correcto? | ✔ Agregación válida (`coalesce(max(...), 0) + 1`). Se añadió una nota sobre respuestas simultáneas del mismo intento → **añadido** |
| ¿El ejemplo MERGE es el más claro posible? | ✘ `ON CREATE SET` y `ON MATCH SET` repetían lo mismo → **simplificado** a `SET` y explicado |

### Self-consistency
| Juicio | Ruta 1 | Ruta 2 | Ruta 3 | Resultado |
|---|---|---|---|---|
| RI-08 requiere [A] | KG: "UNIQUE compuesto" (sin equivalente en Neo4j) | Documentación: no hay unicidad de pares | Patrón MERGE habitual | 3/3 [A] |
| RI-04 depende de la edición | Documentación: existence = Enterprise | KG `limitations_to_consider` | Curso GraphAcademy | 3/3 |
| RI-25 queda como propuesta | Depende de P-05 | La evidencia de un intento abandonado sería dudosa | El KG la marca PROPOSED | 3/3 |

**Cambios en la ronda 1:** 5 (RI-15, P-xx de RI-24 en E4 y KG, nota de concurrencia, MERGE simplificado, nota de unicidades compuestas) + corrección del verificador. → Nueva ronda.

## Ronda 2 (v2)
- **ToT:** sin decisiones nuevas.
- **CoVe:** coherencia de RI-15 con `Evidencia.visibilidad` del entregable 2 ("accesible para su dueño o mediante una compartición vigente") ✔. `verificar.py 1-4` → **0 fallos**.
- **SC:** sin cambios.
- **Resultado:** **ronda limpia → entregable cerrado.**
