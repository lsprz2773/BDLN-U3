# Plan de trabajo del proyecto final QATO'K (BDLN-U3)

> Lee la sección 1 para saber tu perfil y luego ve directo a **tu tabla en la sección 4**. Las secciones 2, 3 y 5 explican el orden y de qué dependes.

## Contexto

La guía del profesor (`context/guia/Guia_Proyecto_Final_Bases_Datos.pdf`) pide una sola aplicación con una base relacional, una documental y una de grafos, coordinadas por una API y con interfaz. Hoy el repo solo tiene el modelo y los scripts de Neo4j, que vienen de la actividad anterior (ver `context/antecedentes/auditoria-v2.md`).

Ya está decidido:
- Equipo de 3; stack Node + TypeScript.
- Se sigue la guía completa, con interfaz.
- Estrategia "dueño de base + dueño de flujo" (`context/antecedentes/plan-reparto.md`).
- **El coordinador (perfil A) deja hechas las fundaciones**: acuerdos, estructura, Docker y esqueleto de la API.
- **No se planea con fechas**: se avanza por fases y cada fase se cierra con una "puerta" verificable.

**Resultado esperado:** un archivo `context/plan-trabajo.md` en el repo que cualquier integrante lea y sepa exactamente qué hacer, en qué orden, de qué depende y cómo saber que terminó. Este es ese archivo.


---

## 1. Quién es quién

| Perfil | Persona | Base que posee | Flujo que programa de punta a punta | Tarea transversal |
|---|---|---|---|---|
| **A — Coordinación y grafo** | @The-Tito (coordinador) | Neo4j | **F3a Perfil de habilidades y evidencias** | **Fase 0 completa**; sincronización hacia Neo4j y reconciliación; documento de arquitectura (E3) |
| **B — Relacional y seguridad** | @lsprz2773 | PostgreSQL | **F1 Cuenta y catálogo** + **F3b Compartir evidencias** | Inicio de sesión y roles; pruebas de rendimiento; catálogo de operaciones (E5) |
| **C — Documental e interfaz** | @AngelChame | MongoDB | **F2 Jugar una simulación** | Estructura de la interfaz y cliente de la API; prueba e2e; propuesta (E1) y README |

**Ajuste frente a `plan-reparto.md`:** A asume el esqueleto que antes tenía B. Para equilibrar, B toma la parte de compartir evidencias (tokens, vencimiento y revocación, que es transaccional y le toca a PostgreSQL) y A se queda con perfil y evidencias.

Carga estimada en días-persona: A ≈ 16 (de ellos 5 de fase 0), B ≈ 16, C ≈ 15.

**Qué significa ser "dueño de base":** escribes el esquema, el cargador de datos, las consultas, el repositorio en el backend y las pruebas de esa base. Además eres la referencia de esa base: si alguien la cambia, te avisa.

---

## 2. Mapa de fases (sin fechas, con puertas)

```
FASE 0  Fundaciones ............ A (B y C arrancan lo que no depende de nada)
   └─ PUERTA 0: acuerdos aprobados por los 3 + `docker compose up` y /health en verde en las 3 máquinas
FASE 1  Bases de datos ......... A, B y C en paralelo (cada quien la suya)
   └─ PUERTA 1: las 3 bases se crean y cargan desde cero con un comando; pruebas por base en verde
FASE 2  Backend de los flujos .. A, B y C en paralelo (cada quien su flujo)
   └─ PUERTA 2: endpoints de los flujos con pruebas; la sincronización funciona
FASE 3  Interfaz e integración . A, B y C en paralelo
   └─ PUERTA 3: los flujos se usan desde la interfaz; las 7 pruebas de integración existen y pasan
FASE 4  Cierre ................. los 3
   └─ PUERTA 4: alguien que no programó una parte instala todo desde el README y la usa
```

**Regla de oro:** no se empieza una fase sin pasar la puerta anterior. La excepción son las tareas marcadas como **"sin bloqueo"**.

---

## 3. Fase 0 — Fundaciones (responsable: A)

Mientras A hace esto, **B y C hacen sus tareas "sin bloqueo"** (sección 4).

| # | Entregable | Ubicación | Contenido | Revisa |
|---|---|---|---|---|
| 0.1 | **Reparto de datos** (quién es dueño de cada dato) | `docs/modelos/matriz-propiedad.md` + `analisis-matriz.md` | Por entidad: base dueña, qué se copia a otra base y para qué; alternativas evaluadas y descartadas. Incluye la **tabla de eventos de sincronización** (`evento_sincronizacion`: id, tipo, payload jsonb, estado PENDIENTE/APLICADO/FALLIDO, intentos, creado_en, aplicado_en) y la política ante escrituras parciales: escribir primero en la base dueña, reintentar después y reconciliar | B y C |
| 0.2 | **Convenciones** | `context/convenciones.md` | UUID v4 generados en el backend; nombres del KG (`id_usuario`, `fecha_inicio`…); fechas ISO-8601 en UTC; catálogos de valores del KG (`EN_CURSO`, `PUBLICADA`…); nuevo campo `rol` de usuario {ESTUDIANTE, ADMIN}; nombres de ramas y formato de commits | B y C |
| 0.3 | **Contrato de la API v0** | `docs/api/contrato-v0.md` + esquemas en `shared/` | Endpoints (abajo), formato de error `{ error: { codigo, mensaje, detalles } }`, sesión con `Authorization: Bearer <jwt>` | B y C |
| 0.4 | **Datos de prueba comunes** | `database/seed/dataset.json` | Un solo conjunto con UUID fijos, a partir de los datos de ejemplo de `database/graph/03-nodos-ejemplo.cypher` (prefijo `e0000000-…`: Ana, Bruno, simulaciones, intentos). **Cada dueño escribe el cargador de su base** que lee este archivo | B y C |
| 0.5 | **Estructura del repositorio** | raíz | Carpetas según la sección 10 de la guía; npm workspaces (`backend`, `frontend`, `shared`); `tsconfig`, ESLint y Prettier; `.nvmrc`; `.gitignore` con `.env`, `node_modules` y `.DS_Store`; `neo4j/` se mueve a `database/graph/` | — |
| 0.6 | **Docker** | `docker-compose.yml`, `.env.example` | PostgreSQL 16, MongoDB 7 y Neo4j 5 Community con volúmenes persistentes, memoria de Neo4j limitada y healthchecks | — |
| 0.7 | **Esqueleto de la API** | `backend/src/` | `config/` (valida el `.env`), `db/` (conexión con `pg`, `mongodb` y `neo4j-driver`), `middlewares/` (errores y validación con zod), `routes/` (un archivo por flujo), `controllers/`, `services/` y `repositories/{relational,document,graph}`. **`GET /health` recorre las capas y consulta las 3 bases: es la plantilla a copiar.** Incluye una prueba con Vitest | — |
| 0.8 | ~~Esqueleto de la interfaz~~ **→ pasa al responsable del frontend** | `frontend/` | Decisión del equipo: lo arma quien hará el frontend, porque eligió Next.js. Ya no bloquea la puerta 0. Requisitos y punto de partida en `frontend/README.md` | Responsable del frontend |
| 0.9 | **Reglas en GitHub** | `.github/`, `context/github.md` | CI de GitHub Actions con las 3 bases (como aviso, no bloquea) y `develop` como rama por defecto. **Sin protección de ramas, sin `CODEOWNERS` y sin plantilla de PR, por decisión del equipo** (`context/github.md`) | B (admin del repo) |
| 0.10 | **Documentos de contexto al día** | `CLAUDE.md`, `docs/KG.json`, `docs/decisiones-modelado.md` | DEC-24: MongoDB adoptado (D-10 pasa a SUPERSEDED); la arquitectura pasa a ser de "3 bases con responsabilidades"; `CLAUDE.md` describe la nueva etapa (las rondas ToT/CoVe solo para documentos de modelo; el código se valida con pruebas y CI). `scripts/verificar.py` debe seguir en 0 fallos | — |
| 0.11 | **README de arranque** | `README.md` | Clonar → `npm install` → `npm run setup:env` → `npm run db:up` → `npm run dev:api` | C lo prueba |
| 0.12 | **Tablero** | GitHub Projects | Un issue por cada tarea de las secciones 4 a 6, con su perfil y su fase | — |

**Endpoints v0:** el detalle (entrada, respuesta, errores y bases que toca cada uno) está en `docs/api/contrato-v0.md`. Todas las rutas van bajo `/api`. Resumen por dueño:

| Flujo | Dueño | Rutas |
|---|---|---|
| Salud | A | `GET /health` |
| F1 Cuenta y habilidades | B | `/auth/registro`, `/auth/login`, `/me` (GET, PATCH, DELETE), `/habilidades`, `/admin/habilidades/*` |
| F1 Catálogo y administración | B | `/simulaciones/*`, `/admin/simulaciones/*` (incluye `/contenido`, `/publicar`, `/desactivar`) |
| F2 Jugar | C | `/intentos/*` (iniciar, consultar, responder, abandonar) |
| F3a Perfil y evidencias | A | `/perfil` (**flujo integrado**), `/perfil/habilidades`, `/perfil/recomendaciones`, `/perfil/habilidades/:id/evolucion`, `/perfil/intentos/:id/recorrido`, `/evidencias/*` |
| F3b Compartir | B | `/evidencias/:id/comparticiones`, `/comparticiones/:id`, `/publico/evidencias/:token` |

**Puerta 0:**
- B y C aprueban 0.1 a 0.4.
- Cada integrante corre `npm install && npm run db:up && npm run dev:api` en su máquina y ve las 3 bases en verde en `http://localhost:4000/api/health` (la parte de la interfaz pasó al responsable del frontend, ver 0.8).
- El CI pasa en `develop`.

---

## 4. Tareas por perfil

### Perfil A — Coordinación y grafo
| Fase | Tarea | Hecho cuando… |
|---|---|---|
| 0 | Todo lo de la sección 3 | Pasa la puerta 0 |
| 1 | Pasar los scripts de `database/graph/` al Neo4j de Docker (`cypher-shell -f`); recortar el grafo a su responsabilidad según la matriz (los nodos copiados solo llevan id y lo necesario para recorrer); cargador del grafo desde `dataset.json`; pruebas de humo y de integridad (C1–C14, C-01 a C-05) con resultado **fechado**, con versión y commit | `npm run db:graph:reset` construye el grafo desde cero y las pruebas pasan |
| 1 | Modelo de grafo para E2 (`docs/modelos/grafo.md`), reutilizando los entregables A-03 a A-06 | Documento revisado por B o C |
| 2 | `repositories/graph`: consultas C-01 a C-05 parametrizadas | Pruebas de repositorio en verde |
| 2 | **Sincronización**: proceso que lee `evento_sincronizacion` (PENDIENTE), aplica cada evento en Neo4j con reintento y lo marca APLICADO o FALLIDO; script de **reconciliación** que compara ids entre PostgreSQL y Neo4j y repara diferencias | Prueba: crear una respuesta con Neo4j apagado → queda PENDIENTE → encender Neo4j → queda APLICADO |
| 2 | Backend de F3a: servicio de perfil que **combina las 3 bases** (cuenta e intentos de PostgreSQL, habilidades y recomendaciones de Neo4j, textos de pasos, retroalimentación y evidencias de MongoDB) | Pruebas de integración en verde |
| 3 | Pantallas de F3a: perfil, recomendaciones, recorrido de un intento, evidencias | Se usan desde la interfaz |
| 3 | Pruebas de **integración** (perfil de punta a punta) y de **consistencia** (provocar una diferencia y ver que la reconciliación la detecta y repara) | En verde en CI |
| 4 | E3 Arquitectura (`docs/arquitectura.md`): diagrama, responsabilidades, matriz del stack, fuente de verdad y sincronización | Revisado por B y C |

### Perfil B — Relacional y seguridad
| Fase | Tarea | Hecho cuando… |
|---|---|---|
| 0 · **sin bloqueo** | Borrador de las tablas a partir de A-02 (diccionario) y A-04 (restricciones), sin llaves definitivas; revisar 0.1 a 0.4 | Comentarios entregados a A |
| 1 | `database/relational/schema/`: tablas según la matriz, PK, FK, `CHECK` (RI-05, RI-06, RI-07, RI-12, RI-21), `UNIQUE` (correo normalizado, token, secuencia por intento), índices justificados, tabla `evento_sincronizacion`; cargador desde `dataset.json`; consultas representativas; pruebas de integridad y de transacciones | `npm run db:relational:reset` construye la base desde cero y las pruebas pasan |
| 1 | Modelo relacional para E2 (`docs/modelos/relacional.md`): entidades, claves y cardinalidades | Revisado por A o C |
| 2 | `repositories/relational`; autenticación (bcrypt + JWT, middleware de rol ADMIN) | Pruebas en verde |
| 2 | Backend de F1 según `matriz-propiedad.md` §4: crear simulación (solo PG), cargar contenido (solo Mongo, repositorio de C), publicar (valida el contenido y luego PG + evento), eliminar BORRADOR (PG y después Mongo); cuenta y habilidades con sus eventos | Pruebas de integración en verde, incluido el huérfano que deja eliminar un BORRADOR |
| 2 | Backend de F3b: crear token (vigencia y unicidad), revocar, acceso público por token que valida estado y vencimiento (RI-15, RI-21) | Pruebas: token vencido → 410; revocado → 404 |
| 3 | Pantallas de F1 (registro, login, catálogo, administración) y F3b (compartir y revocar) | Se usan desde la interfaz |
| 3 | Prueba de **conectividad** formal (registro de conexión en CI); prueba de **rendimiento**: F2 y F3 con autocannon o k6, documentando equipo y volumen de datos | Reporte en `docs/pruebas/rendimiento.md` |
| 4 | E5 Catálogo de operaciones (`docs/api/catalogo-operaciones.md`): reúne lo que cada dueño documenta (parámetros, validaciones, casos normales, límite y de error, evidencia) | Todas las operaciones del contrato aparecen |

### Perfil C — Documental e interfaz
| Fase | Tarea | Hecho cuando… |
|---|---|---|
| 0 · **sin bloqueo** | **Esqueleto de la interfaz (antes paso 0.8)**: app Next.js en `frontend/` según `frontend/README.md`, con una página que muestre `/api/health`. Bocetos de las pantallas de los 3 flujos; borrador de E1 (propuesta con los 8 puntos de la guía §4.1 y la prueba de suficiencia §4.2); revisar 0.1 a 0.4 | Bocetos y borrador compartidos |
| 1 | `database/document/`: colecciones (`contenidos_simulacion`: un documento por simulación con pasos, opciones, consecuencias y retroalimentación anidados, y `contexto` polimórfico por tipo de paso; `evidencias`: instantánea del recorrido), validadores `$jsonSchema`, índices, cargador desde `dataset.json`, consultas, pruebas de documentos válidos e inválidos | `npm run db:document:reset` construye la base desde cero y las pruebas pasan |
| 1 | Modelo documental para E2 (`docs/modelos/documental.md`): colecciones, anidamiento y validaciones | Revisado por A o B |
| 2 | `repositories/document` (también lo usan F1 y F3a) | Pruebas en verde |
| 2 | Backend de F2. **Responder un paso**: lee el contenido de MongoDB; en **una transacción de PostgreSQL** registra la respuesta (RI-10, RI-16, RI-22), cierra el intento si la opción es terminal (RI-23) y escribe los eventos de sincronización; devuelve consecuencias y retroalimentación leídas del contenido (no se escribe en Mongo) | Pruebas de integración en verde |
| 3 | Pantallas de F2 (iniciar, avanzar paso a paso, ver consecuencia y retroalimentación, terminar), diseñadas para móvil (RF-10) | Se juega una simulación completa desde la interfaz |
| 3 | Pruebas de **errores**: Neo4j caído al responder (la respuesta se guarda y el evento queda PENDIENTE; la API **no** dice "todo sincronizado"), dato inválido (400 con el formato de error), MongoDB caído (503); una prueba **e2e** con Playwright que recorre registro → jugar → perfil | En verde en CI |
| 4 | E1 final (`docs/propuesta.md`) y README completo (instalación, configuración, carga, ejecución, pruebas) | Lo valida alguien que no lo escribió |

---

## 5. Dependencias entre perfiles

| Quién necesita | Qué | De quién | Mitigación mientras tanto |
|---|---|---|---|
| Todos | Fase 0 | A | Tareas "sin bloqueo" |
| B (F1) | `repositories/document` | C | B escribe primero la parte de PostgreSQL; las pruebas usan un repositorio falso hasta que C fusione |
| A (F3a) | Repositorios de PostgreSQL y MongoDB | B y C | Igual: un repositorio falso con la misma firma |
| C (F2) | Tabla `evento_sincronizacion` | B | Está definida en 0.1; B la crea en la fase 1 |
| A (sincronización) | Que F2 escriba eventos | C | A prueba con eventos insertados a mano en las pruebas |

**Regla:** las firmas de los repositorios (nombre, parámetros y tipo de retorno) se publican en `shared/` **antes** de implementarlas, para que los demás puedan programar contra ellas.

---

## 6. Fase 4 — Cierre (los 3)

- Correr las 7 pruebas de integración y guardar la salida fechada en `docs/pruebas/`.
- Instalación cruzada: cada quien instala desde cero siguiendo el README en una máquina o carpeta limpia y anota lo que falle.
- E2 completo: modelo conceptual común, hecho juntos, más los 3 modelos lógicos y el diccionario.
- Etiqueta `release/2.0.0` y merge a `main`.
- Ensayo de la defensa: **cada quien explica su flujo pasando por las 3 bases**.

## 7. Reglas de trabajo

1. Rama `feature/<perfil>-<tarea>` desde `develop` → PR a `develop` con `Closes #N` → **lo fusiona su autor, sin esperar aprobación** (decisión del equipo). Detalle: `context/como-trabajar.md`.
2. Cada PR trae sus pruebas (el CI avisa si algo se rompe).
3. El SQL, el MQL y el Cypher solo viven en `repositories/` y en `database/`.
4. Nadie inserta datos a mano: todo sale de `dataset.json`.
5. Un cambio a un acuerdo de la fase 0 (matriz, convenciones, contrato, dataset) se hace en un PR propio, avisando a los otros dos antes de fusionarlo.
6. Revisión semanal corta con el tablero: qué cerré, qué me bloquea.

## 8. Si hay que recortar (en este orden)

1. Administración de simulaciones en F1 (se cargan con la semilla).
2. Playwright (e2e manual con capturas).
3. CI (pruebas en local con la salida fechada).

**Nunca se recortan:** las 3 bases, F2, F3a, sincronización, consistencia, errores y el README.

## 9. Responsable de cada entregable y prueba de la guía

| Entregable | Responsable | | Prueba de integración | Responsable |
|---|---|---|---|---|
| E1 Propuesta | C | | Conectividad | B (base en fase 0: A) |
| E2 Modelado | Cada dueño + juntos | | Funcional | Cada dueño de flujo |
| E3 Arquitectura | A | | Integridad | Cada dueño de base |
| E4 Tres bases | Cada dueño | | Integración | A |
| E5 Catálogo | B (integra) | | Consistencia | A |
| E6 Backend y API | A (esqueleto) + dueños de flujo | | Errores | C |
| E7 Aplicación | Dueños de flujo | | Rendimiento | B |
| E8 Pruebas y despliegue | Todos; README C | | | |

---

## 10. Cómo se verifica la fase 0

La fase 0 está terminada cuando:
  - `docker compose up -d`, después `npm run dev` y `GET /health` → las 3 bases en `ok`.
  - `npm test` en verde.
  - `python3 scripts/verificar.py` → 0 fallos después de DEC-24.
  - Scripts de `database/graph/` ejecutados con `cypher-shell` contra el Neo4j de Docker sin fallos.
  - El CI en verde en el PR de `feature/fundaciones`.
