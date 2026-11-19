# Datos de prueba comunes

`dataset.json` es la **única fuente** de datos de prueba de las 3 bases (paso 0.4 del plan). Nadie inserta datos a mano: si falta un caso, se agrega aquí por PR y se vuelve a validar.

## Estructura

| Sección | Contiene | Quién escribe el cargador |
|---|---|---|
| `relacional` | Una clave por tabla de PostgreSQL (`usuario`, `habilidad`, `simulacion`, `simulacion_habilidad`, `intento`, `respuesta`, `evidencia`, `comparticion`), con los nombres de columna exactos | B (`npm run db:relational:reset`) |
| `documental` | Una clave por colección de MongoDB (`contenidos_simulacion`, `evidencias`); `_id` es el UUID de la entidad | C (`npm run db:document:reset`) |
| *(no hay `grafo`)* | El grafo **no tiene semilla propia**: se proyecta a partir de `relacional` y `documental` con las mismas reglas que los eventos (matriz §3 y §5). Ahí también se calculan los derivados: `Progreso`, `DEMUESTRA` y `Respuesta.tipo_retroalimentacion` | A (`npm run db:graph:reset`) |

`_meta` explica los escenarios (Ana con historial, Bruno nuevo, Carla admin, simulación en BORRADOR sin contenido) y qué cambió respecto a los datos de ejemplo de Neo4j.

## Validar

```bash
python3 database/seed/validar_dataset.py
```

Comprueba ids, catálogos y la forma del `contexto` por tipo de paso. Además verifica las reglas RI-02, 03, 06, 08, 09, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23 y 25, la puntuación según la regla del contrato y que no haya huérfanos entre bases. Debe terminar con **0 fallos** después de cualquier cambio al dataset.

**Contraseña de los usuarios de prueba:** `_meta.contrasena_demo`. El cargador relacional la convierte en `contrasena_hash` (bcrypt).
