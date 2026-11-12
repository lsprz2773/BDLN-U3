# Verificación — F10: Implementación en Neo4j (restricciones, índices, datos de ejemplo, pruebas de humo, limpieza)

Archivos: `neo4j/` · Motor: Neo4j 5.26.33 Community, embebido (Maven Central; `dist.neo4j.org` y Docker no estaban disponibles en el entorno) · Resultado final: `neo4j/resultado-pruebas.txt`

## Ronda 1 (creación)

### ToT
| Decisión | Ramas | Elegida | Motivo |
|---|---|---|---|
| Dónde ejecutar Neo4j | A. Docker · B. servidor descargado · C. Neo4j embebido vía Maven · D. no ejecutar | **C** | A y B no eran posibles (sin daemon de Docker; `dist.neo4j.org` bloqueado). D dejaría los scripts sin probar. C usa el mismo motor Cypher 5 de Community |
| Versión | A. 2025.x/2026.x (calendario) · B. 5.26 LTS | **B** | Versión de soporte largo y Cypher 5, coherente con la documentación usada en DEC-12 |
| Restricciones Enterprise | A. omitirlas · B. archivo aparte y prueba de que Community las rechaza | **B** | Documenta RI-04/RI-24 y además **verifica** DEC-12 contra el motor real |
| Índices | A. un índice por propiedad · B. solo los que piden consultas y reglas | **B** | Cada índice cita la consulta o regla que lo justifica; los 15 de unicidad ya cubren los ids |
| Identificar los datos de ejemplo para retirarlos | A. etiqueta extra `:Ejemplo` · B. propiedad extra · C. prefijo reservado en los UUID | **C** | A y B alteran el modelo; C no añade nada y permite borrar con un solo patrón |
| Nodos y relaciones | A. un solo script · B. scripts separados, como pidió el usuario | **B** | Se respeta el orden pedido. La nota en 04 aclara que la aplicación crea nodo y relaciones obligatorias en la misma transacción; la prueba C1 verifica que no quedan huérfanos |
| Consultas en las pruebas | A. reescribirlas · B. copiarlas literalmente del entregable 1 sustituyendo parámetros | **B** | Se prueba el Cypher entregado, no una variante |
| Formato de las pruebas | A. script externo en Python · B. Cypher puro que devuelve (prueba, ok, detalle) + marcador `ESPERA_ERROR` | **B** | Se puede ejecutar también a mano en Neo4j Browser |

### CoVe
| Pregunta de verificación | Resultado |
|---|---|
| ¿Los scripts se ejecutan sin errores en Neo4j real? | 1.ª ejecución: **9 errores**, todos en las pruebas: `toString()` sobre listas (no permitido en Cypher) y una agregación con agrupación implícita (E2) → **corregidos** |
| ¿Cada etiqueta, relación y propiedad usada existe en el modelo? | ✔ La prueba B2 cuenta los 17 patrones; C14 confirma los tipos String/Integer/Float/DateTime del entregable 2 |
| ¿DEC-12 (existencia y tipo solo en Enterprise) es cierto? | ✔ **Confirmado con el motor**: Community rechaza ambas con un mensaje que menciona Enterprise (A3, A4) |
| ¿Las pruebas aprueban por la razón correcta? | ✘ **Hallazgo grave:** 12 pruebas de integridad (C1–C8, C10–C12, E3) no devolvían ninguna fila cuando todo estaba bien. Una agregación con clave literal (`'C2' AS prueba`) no produce filas si no hay datos, así que las pruebas pasaban sin comprobar nada. → **corregido**: se agrega antes con `WITH count(...) AS v`. Además, el ejecutor ahora marca como FALLO toda prueba que no devuelva filas |
| ¿Las pruebas detectan errores reales? (prueba de mutación) | ✔ Mutación 1 (opción sin consecuencia, ruta entre simulaciones, nivel cambiado, nombre de habilidad cambiado): 10 fallos, en B2, B3, C1, C3, C4, D1, D3, D4, E5. Mutación 2 (opción de otro paso, secuencia repetida, DEMUESTRA fuera de DESARROLLA, progreso movido de usuario): 8 fallos, en C2, C5, C7, D3, D4… |
| ¿Las propiedades opcionales nulas quedan ausentes? | ✔ Prueba B4 añadida |
| ¿La limpieza deja el esquema intacto? | ✔ L1–L3: 0 nodos, 0 relaciones, 15 restricciones y 9 índices |

### Self-consistency
Los resultados esperados de C-01..C-05 se derivaron por tres caminos: (1) cálculo a mano sobre los datos (por ejemplo, la prioridad de C-01 para Ana: 0.7 × (60 − 40) = 14 contra 0.4 × (60 − 55) = 2); (2) la semántica de cada consulta en el entregable 1; (3) la ejecución en Neo4j. Los tres coinciden en las 5 consultas.

**Cambios en la ronda 1:** correcciones de sintaxis de las pruebas, de las pruebas que pasaban sin comprobar nada y del ejecutor, y la prueba B4 nueva. → Nueva ronda.

## Ronda 2
- **ToT:** sin decisiones nuevas.
- **CoVe:** ejecución completa → **76 pruebas, 0 fallos**; las dos pruebas de mutación siguen detectando los errores introducidos.
- **SC:** los resultados de C-01..C-05 no cambian.
- **Resultado:** **ronda limpia → fase cerrada.**
