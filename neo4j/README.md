# Neo4j — implementación y pruebas del modelo de QATO'K

Scripts Cypher que llevan el modelo lógico (entregables 1–6) a Neo4j: restricciones, índices, nodos y relaciones de ejemplo, pruebas de humo y limpieza. Se probaron sobre **Neo4j 5.26 LTS, edición Community** (embebida): **76 pruebas, 0 fallos** (`resultado-pruebas.txt`).

## Orden de ejecución

| # | Archivo | Qué hace |
|---|---|---|
| 1 | `01-restricciones.cypher` | 15 restricciones de unicidad: los `id_*` de las 12 etiquetas, `Usuario.correo`, `Habilidad.nombre`, `Comparticion.token` (RI-01, RI-02, RI-03, RI-15) |
| — | `01b-restricciones-enterprise.cypher` | Restricciones de existencia y de tipo (RI-04, RI-18, RI-24). **Solo para Neo4j Enterprise**: no se ejecuta en Community, y las pruebas comprueban que Community las rechaza |
| 2 | `02-indices.cypher` | 9 índices pedidos por las consultas y reglas (más los 15 que ya crean las restricciones) |
| 3 | `03-nodos-ejemplo.cypher` | 51 nodos de ejemplo de las 12 etiquetas |
| 4 | `04-relaciones-ejemplo.cypher` | 71 relaciones de los 17 tipos de patrón (R01–R17) |
| 5 | `05-pruebas-humo.cypher` | Pruebas de humo: esquema, datos, integridad, consultas C-01..C-05 y escrituras validadas |
| 6 | `06-limpieza.cypher` | Retira todos los datos de ejemplo y comprueba que el esquema sigue intacto |

## Cómo ejecutarlo

**Opción A — automática (Java 21 + Maven):**

```bash
neo4j/ejecutar.sh
```

Levanta un Neo4j Community embebido en un directorio temporal, ejecuta los seis scripts en orden, imprime cada resultado y termina con `=== RESUMEN: N pruebas, M fallos ===` (código de salida 1 si algo falla). No necesita un servidor instalado. El ejecutor está en `runner/`.

**Opción B — Neo4j Desktop, Aura o un servidor propio:** pegar cada script en Neo4j Browser (o `cypher-shell -f archivo.cypher`) en el orden de la tabla.
- En `05-pruebas-humo.cypher`, toda fila con `ok = false` es un fallo.
- Las sentencias precedidas por `// ESPERA_ERROR` **deben** fallar: prueban que la base rechaza un duplicado o una restricción exclusiva de Enterprise.
- **En Neo4j Desktop usar `05-desktop-pruebas.cypher`.** Desktop detiene el script en el primer error y sus instancias locales son Enterprise, así que esta versión quita las sentencias que deben fallar (A3, A4 y C15) y en su lugar muestra la edición del servidor. Se ejecuta completa y todas las filas deben dar `ok = true`.

## Datos de ejemplo por consulta

Todos los identificadores empiezan por `e0000000-0000-4000-8000-`, así `06-limpieza.cypher` borra solo estos datos. Son ficticios.

| Consulta | Datos que la ejercitan | Resultado esperado (y comprobado) |
|---|---|---|
| C-01 Simulaciones según el progreso | Ana tiene progreso en 3 habilidades. Bruno es nuevo, sin progreso. Hay 2 simulaciones PUBLICADAS y 1 en BORRADOR | **Ana:** 1.º «Tres entregas para mañana» (Gestión del tiempo 40 < 60), 2.º «Cliente molesto por un retraso» (Resolución de conflictos 55 < 60). **Bruno:** las 2 publicadas. La de BORRADOR nunca aparece |
| C-02 Fortalezas y áreas de mejora | Retroalimentación ACIERTO, PARCIAL y ERROR en 5 respuestas de Ana | Comunicación efectiva = FORTALEZA (78 ≥ 75). Resolución de conflictos y Gestión del tiempo = ÁREA DE MEJORA. Gestión del tiempo no tiene `nivel_objetivo` y usa el nivel esperado (60) como respaldo |
| C-03 Recorrido de decisiones | 2 intentos de Ana en «Cliente molesto…» con ramas distintas, que terminan en opciones terminales | 4 decisiones ordenadas por intento y `secuencia`, cada una con su consecuencia y su retroalimentación |
| C-04 Evidencias compartibles | 1 evidencia PRIVADA de Ana con 3 enlaces: vigente, revocado y expirado | Solo aparece el enlace vigente |
| C-05 Evolución de una habilidad | 3 intentos completados y 1 EN_CURSO | Serie 45 → 92 → 65 en orden de fecha. El intento en curso no cuenta. Nivel consolidado: 78 |

## Qué comprueban las pruebas de humo

| Grupo | Pruebas |
|---|---|
| A. Esquema | Las 15 restricciones y los 9 índices existen y están en línea. Community rechaza las restricciones de existencia y de tipo (confirma DEC-12) |
| B. Datos | Conteo de nodos por etiqueta y de relaciones por patrón (17). Las propiedades opcionales sin valor no se guardan |
| C. Integridad | Relaciones obligatorias por entidad (entregable 5) y reglas RI-05..RI-08, RI-10..RI-14, RI-16..RI-18, RI-20, RI-23, RI-24. Tipos de dato en Neo4j. Rechazo de duplicados por las restricciones de unicidad |
| D. Consultas | C-01..C-05 **copiadas literalmente del entregable 1**, más la búsqueda por texto completo (RF-02) |
| E. Escrituras validadas | El Cypher de referencia del entregable 4 rechaza una respuesta inconsistente (RI-10), crea una válida con `secuencia` 1 (RI-16), `MERGE` no duplica DESARROLLA (RI-08) y no se inician intentos de una simulación en BORRADOR (RI-19) |
| Limpieza | Quedan 0 nodos y 0 relaciones, y las 15 restricciones y los 9 índices se conservan |

Las pruebas se validaron también **al revés**: se introdujeron errores a propósito en copias de los datos (una opción sin consecuencia, una ruta que cruza simulaciones, una opción de otro paso, una secuencia repetida, una habilidad demostrada que la simulación no desarrolla, niveles distintos) y las pruebas correspondientes fallaron. Ver `verificacion/09-neo4j.md`.
