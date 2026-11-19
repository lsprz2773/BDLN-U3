# Convenciones del proyecto QATO'K

- **Paso del plan:** 0.2. **Estado:** PROPUESTA, pendiente de aprobación de B y C (puerta 0).
- **Regla:** si algo no está aquí, se sigue el modelo (`docs/KG.json`) y la matriz (`docs/modelos/matriz-propiedad.md`). Un cambio a este archivo se hace por PR aprobado por los 3.
- **Fuente única en código:** los catálogos y formatos de este documento se implementan **una sola vez** en `shared/` (esquemas zod). El backend y el frontend los importan; nadie los copia.

## 1. Identificadores

| Regla | Detalle |
|---|---|
| Tipo | **UUID v4**, en minúsculas y con guiones: `3f2b8c1e-…` |
| Quién lo genera | **El backend**, con `crypto.randomUUID()`, *antes* de escribir. Así el mismo id llega a las 3 bases. Ninguna base lo genera: nada de `SERIAL`, `gen_random_uuid()` como default ni `ObjectId` |
| PostgreSQL | Columna `UUID` |
| MongoDB | `_id` = el UUID como **string**. En `contenidos_simulacion`, `_id` = `id_simulacion`; en `evidencias`, `_id` = `id_evidencia`. Los ids anidados (`id_paso`, `id_opcion`) también son UUID string |
| Neo4j | Propiedad string `id_<entidad>` con restricción de unicidad |
| Nombre | `id_<entidad>` en todas partes: columna, campo, propiedad y JSON de la API |
| Datos de prueba comunes | Prefijo fijo `e0000000-0000-4000-8000-` (el que ya usan los datos de Neo4j) |
| Datos creados por las pruebas | UUID aleatorio; la prueba los borra al terminar |

## 2. Nombres

El **dominio va en español** con los nombres exactos del KG (`Simulacion`, `id_intento`, `fecha_inicio`, `CONDUCE_A`) para conservar la trazabilidad con los entregables. Los **sufijos técnicos** siguen la guía en inglés (`controllers`, `services`, `repositories`).

| Dónde | Convención | Ejemplos |
|---|---|---|
| Tablas PostgreSQL | singular, `snake_case` | `usuario`, `simulacion_habilidad`, `evento_sincronizacion` |
| Columnas | `snake_case`, igual que en el KG | `id_usuario`, `fecha_expiracion`, `contrasena_hash` |
| Restricciones e índices PG | `pk_<tabla>`, `fk_<tabla>_<referida>`, `uq_<tabla>_<columnas>`, `ck_<tabla>_<regla>`, `ix_<tabla>_<columnas>` | `uq_respuesta_intento_secuencia`, `ck_intento_puntuacion` |
| Colecciones MongoDB | plural, `snake_case` | `contenidos_simulacion`, `evidencias` |
| Campos MongoDB | `snake_case`; arreglos en plural | `pasos[]`, `opciones[]`, `consecuencias[]` |
| Etiquetas Neo4j | `PascalCase` singular (KG) | `Usuario`, `Intento` |
| Relaciones Neo4j | `UPPER_SNAKE_CASE` (KG) | `TIENE_PROGRESO`, `CONDUCE_A` |
| Propiedades Neo4j | `snake_case` (KG) | `nivel_actual` |
| JSON de la API | **`snake_case`, igual que el modelo**. No hay traducción a camelCase: un campo se llama igual en la base, en la API y en la interfaz | `{ "id_intento": "…", "fecha_inicio": "…" }` |
| Variables y funciones TS | `camelCase` | `registrarRespuesta()` |
| Tipos, interfaces, clases TS | `PascalCase` | `Intento`, `IntentoRepository` |
| Archivos TS | `<entidad>.<capa>.ts` | `intento.service.ts`, `intento.repository.ts`, `intentos.routes.ts` |
| Componentes React | `PascalCase.tsx` | `PasoSimulacion.tsx` |
| Scripts de base | `NN-descripcion.<sql\|js\|cypher>`, en orden de ejecución | `01-esquema.sql`, `02-indices.sql` |

## 3. Tipos y formatos

| Dato | PostgreSQL | MongoDB | Neo4j | JSON de la API |
|---|---|---|---|---|
| Fecha y hora | `TIMESTAMPTZ` | `Date` | `DateTime` (`datetime()`) | ISO-8601 en **UTC** con `Z`: `2026-11-18T21:30:00.000Z` |
| Puntuación, niveles (0–100) | `NUMERIC(5,2)` + `CHECK` | `number` | `Float` | `number` (máximo 2 decimales) |
| Peso de DESARROLLA (0,1] | `NUMERIC(3,2)` + `CHECK` | — | `Float` | `number` |
| Textos con límite | `VARCHAR(n)` con la `n` del KG | `string` + `maxLength` en `$jsonSchema` | `String` | `string`; zod aplica el mismo `max(n)` |
| Textos largos | `TEXT` | `string` | — (no se copian al grafo) | `string` |
| Catálogos | `VARCHAR` + `CHECK (x IN (…))` (no `ENUM`: cambiar un `CHECK` es más simple) | `enum` en `$jsonSchema` | `String` | `string` validado con `z.enum` |

**Correo:** se guarda normalizado (`trim().toLowerCase()`) y PostgreSQL además tiene `UNIQUE` sobre `lower(correo)` (RI-02).

**Contraseñas:** solo `contrasena_hash` (bcrypt, costo 10). La contraseña nunca se registra en logs ni viaja en respuestas.

## 4. Catálogos de valores

Los valores son los del KG (`value_catalogs`), más los que añade la matriz v2. Van en **MAYÚSCULAS y sin acentos**.

| Campo | Valores | Base dueña | Origen |
|---|---|---|---|
| `usuario.estado` | `ACTIVO`, `INACTIVO`, `SUSPENDIDO` | PG | KG |
| `usuario.rol` | `ESTUDIANTE`, `ADMIN` | PG | Matriz v2 (nuevo) |
| `simulacion.dificultad` | `BASICA`, `INTERMEDIA`, `AVANZADA` | PG | RI-05 |
| `simulacion.estado` | `BORRADOR`, `PUBLICADA`, `INACTIVA` | PG | RI-05 |
| `intento.estado` | `EN_CURSO`, `COMPLETADO`, `ABANDONADO` | PG | RI-06 |
| `evidencia.visibilidad` | `PRIVADA` (por defecto), `PUBLICA` | PG | KG |
| `comparticion.estado` | `ACTIVA`, `REVOCADA` (la vigencia se calcula con `fecha_expiracion`) | PG | KG |
| `evento_sincronizacion.estado` | `PENDIENTE`, `APLICADO`, `FALLIDO` | PG | Matriz v2 |
| `evento_sincronizacion.tipo` | Los 11 de la matriz §5 | PG | Matriz v2 |
| `pasos[].tipo` | `CORREO`, `REUNION`, `CONVERSACION`, `TAREA`, `INCIDENTE` | Mongo | KG (P-09) |
| `consecuencias[].impacto` | `POSITIVO`, `NEUTRO`, `NEGATIVO` | Mongo | KG |
| `consecuencias[].tipo` | `RELACIONAL`, `TIEMPO`, `CALIDAD`, `REPUTACION` | Mongo | KG |
| `retroalimentacion.tipo` | `ACIERTO`, `PARCIAL`, `ERROR` | Mongo (copiada al grafo como `Respuesta.tipo_retroalimentacion`) | KG |
| `habilidad.categoria` | Texto libre (sin catálogo, P-08) | PG | KG |

**Contexto por tipo de paso** (documento de contenido, matriz §3):

| `tipo` | Campos de `contexto` |
|---|---|
| `CORREO` | `remitente`, `asunto`, `cuerpo` |
| `REUNION` | `participantes[]`, `agenda[]` |
| `CONVERSACION` | `interlocutor`, `lineas[]` (`{ quien, texto }`) |
| `TAREA` | `entregables[]`, `plazo_horas` |
| `INCIDENTE` | `cronologia[]` (`{ momento, hecho }`), `severidad` (`BAJA`, `MEDIA`, `ALTA`) |

## 5. Reglas generales de la API

El contrato completo (endpoints) es el paso 0.3. Estas reglas aplican a **todos** los endpoints.

| Tema | Regla |
|---|---|
| Prefijo | Todo bajo `/api`. Ejemplo: `/api/simulaciones`, `/api/health` |
| Formato | JSON UTF-8, campos en `snake_case` |
| Sesión | `Authorization: Bearer <jwt>`. El token lleva `id_usuario` y `rol`, y vence en 8 h |
| Respuesta de una entidad | El objeto directo: `{ "id_simulacion": "…", … }` |
| Listas | `{ "datos": [ … ], "total": 42 }`; paginación con `?limite=20&desplazamiento=0` (límite máximo 100) |
| Operaciones que generan eventos | Agregan `"sincronizacion": { "grafo": "APLICADO" \| "PENDIENTE", "eventos": ["<id_evento>"] }` (matriz §4) |
| Error | `{ "error": { "codigo": "INTENTO_NO_EN_CURSO", "mensaje": "El intento ya terminó", "detalles": { … } } }`. `codigo` en `UPPER_SNAKE_CASE`, estable para que la interfaz lo use; `mensaje` en español, para mostrarlo al usuario |

**Códigos HTTP:**

| Código | Cuándo |
|---|---|
| `200` / `201` / `204` | OK / creado / sin contenido. Un borrado **sin** eventos responde `204`; un borrado **con** eventos responde `200 { "eliminado": true, "sincronizacion": … }` |
| `400` `VALIDACION` | Entrada inválida (zod); `detalles` lista los campos |
| `401` `NO_AUTENTICADO` | Sin token o token inválido |
| `403` `SIN_PERMISO` | Autenticado pero sin permiso (rol o dueño) |
| `404` `NO_ENCONTRADO` | No existe, o no es tuyo (no se revela que existe) |
| `409` | Conflicto con una regla de negocio (p. ej. `SIMULACION_PUBLICADA`, `CORREO_DUPLICADO`) |
| `410` `ENLACE_VENCIDO` | Token de compartición expirado |
| `500` `ERROR_INTERNO` | Error no previsto (el detalle solo va al log) |
| `503` `BASE_NO_DISPONIBLE` | Una base necesaria para leer o escribir está caída; `detalles.base` dice cuál |

Una escritura que se completó en la base dueña pero dejó el grafo pendiente **no** es un error: responde `2xx` con `sincronizacion.grafo = "PENDIENTE"`.

## 6. Código

1. El SQL, el MQL y el Cypher **solo** viven en `backend/src/repositories/` y en `database/`.
2. **Todas las consultas van parametrizadas** (`$1` en `pg`, filtros como objeto en `mongodb`, `$param` en Neo4j). Nunca se concatenan textos en una consulta.
3. Un controlador solo valida la entrada, llama al servicio y da forma a la respuesta. Las reglas de negocio van en servicios. Un repositorio solo habla con su base.
4. Un servicio que coordina varias bases lo hace siguiendo el orden de escritura de la matriz §4.
5. Errores de negocio: `throw new ErrorApp(codigo, estado, mensaje, detalles?)`; el middleware los convierte al formato de error.
6. Logs con nivel y en JSON (pino). Nunca se registran contraseñas, tokens ni correos completos.
7. Sin `any` en TypeScript (`strict: true`). Lint y formato (ESLint + Prettier) deben pasar antes del PR.
8. **Frontend con Next.js: solo consume la API.** Next puede ejecutar código en el servidor, y eso facilita caer en el error que la guía prohíbe: que la interfaz toque las bases (§7.6 y §12). Por eso:
   - `frontend/` **no** importa `pg`, `mongodb` ni `neo4j-driver` (ESLint lo bloquea) y no tiene credenciales de bases en su entorno.
   - **No** se usan Route Handlers (`app/api/*`) ni Server Actions como backend. Toda lectura y escritura pasa por la API de `backend/` (`NEXT_PUBLIC_API_URL`).
   - Los tipos y esquemas se importan de `@qatok/shared`, no se redefinen.

## 7. Git (gitflow)

| Rama | Para qué | Sale de → vuelve a |
|---|---|---|
| `main` | Versiones entregables | — |
| `develop` | Integración del trabajo | — |
| `feature/<perfil>-<tarea>` | Una tarea del plan | `develop` → `develop` (PR) |
| `release/<x.y.z>` | Preparar una entrega | `develop` → `main` y `develop` |
| `hotfix/<descripcion>` | Corrección urgente sobre `main` | `main` → `main` y `develop` |

Ejemplos de rama: `feature/b-esquema-relacional`, `feature/c-validadores-documental`, `feature/a-sincronizacion`.

**Commits: uno por implementación.** Un commit = un cambio con sentido propio que deja el repo funcionando.

```
<ámbito>: <qué cambia, en presente>

<por qué, si no es obvio; reglas RI-xx o decisiones DEC-xx que toca>
```

Ámbitos: `relacional`, `documental`, `grafo`, `backend`, `frontend`, `sync`, `shared`, `pruebas`, `infra`, `docs`. Ejemplo: `relacional: tabla respuesta con secuencia única por intento (RI-16)`.

**Pull requests:** a `develop`, con `Closes #N` para cerrar el issue. **Cada quien fusiona su propio PR, sin aprobación obligatoria** (decisión del equipo, 2026-11-19). El CI es un aviso, no un bloqueo. Si el PR cambia un acuerdo (matriz, convenciones, contrato o dataset), se avisa a los otros dos antes de fusionar. Se fusiona con *merge commit* (no *squash*), para conservar los commits por implementación.

**Versiones:** la actividad anterior terminó en `1.1.0`. La entrega del proyecto final será `2.0.0`.
