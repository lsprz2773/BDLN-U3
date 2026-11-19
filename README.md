# QATO'K

**Simulaciones de situaciones laborales para practicar habilidades profesionales antes de vivirlas.**

[![CI](https://github.com/lsprz2773/BDLN-U3/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/lsprz2773/BDLN-U3/actions/workflows/ci.yml)

Proyecto final de **Bases de Datos en la Nube**, Universidad Politécnica de Chiapas. Es una sola aplicación que usa, de forma coordinada y justificada, una base de datos **relacional** (PostgreSQL), una **documental** (MongoDB) y una **de grafos** (Neo4j).

> **Estado:** fase 0 (fundaciones) terminada en su parte técnica. Las bases, la API base y las pruebas de conectividad funcionan; los flujos de la aplicación se construyen en las fases 1 a 3. Ver [Estado del proyecto](#estado-del-proyecto).

---

## El problema y la solución

Muchos estudiantes por egresar no tienen experiencia laboral formal: no saben si lo que aprendieron sirve en situaciones reales, les cuesta demostrar sus habilidades y nunca han tomado decisiones con consecuencias.

QATO'K les propone **simulaciones cortas** (un correo de un cliente molesto, una reunión con la jefa, tres entregas para el mismo día). En cada paso el estudiante elige qué hacer, ve las **consecuencias**, recibe **retroalimentación** y la plataforma sigue el **progreso de sus habilidades**. Al terminar puede generar **evidencias** y compartirlas con un enlace que vence o se puede revocar.

## Arquitectura

```mermaid
flowchart LR
    UI["Interfaz<br/>Next.js"] -->|HTTP / JSON| API["API REST<br/>Express + TypeScript"]
    subgraph backend["backend/"]
        API --> S["Servicios<br/>reglas de negocio"]
        S --> RR["Repositorio<br/>relacional"]
        S --> RD["Repositorio<br/>documental"]
        S --> RG["Repositorio<br/>grafo"]
    end
    RR --> PG[("PostgreSQL")]
    RD --> MG[("MongoDB")]
    RG --> NJ[("Neo4j")]
    PG -. "outbox: eventos" .-> NJ
```

Cada dato tiene **una sola base dueña** ([matriz de propiedad](docs/modelos/matriz-propiedad.md)):

| Base | Responsabilidad | Por qué este modelo |
|---|---|---|
| **PostgreSQL** | Cuentas, catálogo, estado de simulaciones, intentos y respuestas, evidencias y enlaces compartidos | Transacciones e integridad: registrar una respuesta, cerrar el intento y emitir su evento ocurren juntos o no ocurren |
| **MongoDB** | Contenido de cada simulación y de cada evidencia | Cada simulación es un árbol anidado (pasos → opciones → consecuencias) y cada tipo de paso tiene un contexto con forma distinta |
| **Neo4j** | Recorridos: recomendaciones, fortalezas, decisiones tomadas, evidencias por habilidad, evolución | Consultas de varios saltos sobre conexiones; es dueño del progreso, que es derivado |

Los cambios que el grafo necesita nacen en PostgreSQL junto con un evento (**outbox**), se aplican en Neo4j de inmediato y, si Neo4j no está disponible, se reintentan; un proceso de **reconciliación** detecta y repara diferencias. La API nunca afirma que algo está sincronizado si no lo está.

## Stack

| Capa | Tecnología |
|---|---|
| Interfaz | Next.js (solo consume la API) |
| API | Node.js, TypeScript, Express 5, zod |
| Bases | PostgreSQL 16, MongoDB 7, Neo4j 5 Community (drivers oficiales `pg`, `mongodb`, `neo4j-driver`) |
| Contrato compartido | `@qatok/shared` (esquemas zod que usan backend y frontend) |
| Pruebas | Vitest y Supertest |
| Infraestructura | Docker Compose y GitHub Actions |

## Requisitos

- **Node.js 22 o superior** (recomendado 24, ver `.nvmrc`)
- **Docker Desktop** (o Docker Engine con Compose v2), encendido
- **Python 3** (validadores del dataset y del modelo)
- Git

## Inicio rápido

```bash
git clone git@github.com:lsprz2773/BDLN-U3.git
cd BDLN-U3
git checkout develop

npm install
npm run setup:env        # crea .env con contraseñas y JWT_SECRET aleatorios
npm run db:up            # levanta las 3 bases y espera a que estén sanas
npm run dev:api          # API en http://localhost:4000/api
```

Comprueba que la API ve las tres bases:

```bash
curl http://localhost:4000/api/health
```

```json
{
  "estado": "OK",
  "version": "0.1.0",
  "bases": {
    "relacional": { "ok": true, "latencia_ms": 1 },
    "documental": { "ok": true, "latencia_ms": 1 },
    "grafo": { "ok": true, "latencia_ms": 4 }
  }
}
```

Si una base no responde, el estado es `DEGRADADO`, la respuesta es `503` y esa base aparece con `ok: false`.

## Comandos

| Comando | Qué hace |
|---|---|
| `npm run setup:env` | Crea `.env` a partir de `.env.example` con secretos aleatorios (no sobrescribe uno existente) |
| `npm run db:up` | Levanta PostgreSQL, MongoDB y Neo4j y espera a que estén sanas |
| `npm run db:down` | Detiene las bases (los datos se conservan) |
| `npm run db:reset` | Detiene las bases **y borra sus datos** |
| `npm run db:ps` / `npm run db:logs` | Estado y registros de los contenedores |
| `npm run dev:api` | API con recarga automática |
| `npm run verificar` | Lint, formato, tipos, pruebas unitarias, dataset y modelo: lo mismo que el CI, menos la integración |
| `npm run test:unit` | Pruebas unitarias (sin bases) |
| `npm run test:integration` | Pruebas contra las bases de Docker |
| `npm run format` | Formatea el código con Prettier |

### Puertos

| Servicio | Puerto local | Notas |
|---|---|---|
| API | 4000 | `API_PORT` |
| Interfaz | 3000 | Puerto por defecto de Next.js |
| PostgreSQL | 5433 | No choca con un PostgreSQL local en 5432 |
| MongoDB | 27018 | No choca con un MongoDB local en 27017 |
| Neo4j Browser / Bolt | 7475 / 7688 | No choca con Neo4j Desktop (7474 / 7687) |

Todos se cambian en tu `.env`.

## Estructura del repositorio

```
├── backend/            API: controllers → services → repositories/{relational,document,graph}
├── frontend/           Interfaz Next.js
├── shared/             Esquemas zod y catálogos compartidos (fuente única del contrato)
├── database/
│   ├── relational/     PostgreSQL: esquema, carga y consultas
│   ├── document/       MongoDB: validadores, carga y consultas
│   ├── graph/          Neo4j: scripts Cypher
│   └── seed/           Datos de prueba comunes a las 3 bases + su validador
├── tests/              unit/ · integration/ · e2e/
├── docs/               Entregables evaluables: modelos, contrato de API, pruebas, KG
├── context/            Material del equipo: plan de trabajo, convenciones, guía del profesor
├── docker-compose.yml
└── .env.example
```

`entregables/`, `verificacion/` y `presentacion/` contienen la actividad anterior (modelo lógico de grafos), que es la base del modelo conceptual del proyecto.

## Datos de prueba

`database/seed/dataset.json` es la única fuente de datos de prueba de las tres bases. Usuarios incluidos (contraseña de todos: `Qatok2026!`, solo para desarrollo):

| Usuario | Correo | Rol | Escenario |
|---|---|---|---|
| Ana López | ana.lopez@ejemplo.com | Estudiante | Historial completo: 3 intentos terminados, 1 en curso, una evidencia compartida |
| Bruno Díaz | bruno.diaz@ejemplo.com | Estudiante | Usuario nuevo, sin actividad |
| Carla Ruiz | carla.ruiz@ejemplo.com | Administradora | Gestiona simulaciones y habilidades |

> Los cargadores de cada base llegan en la fase 1. Mientras tanto, `python3 database/seed/validar_dataset.py` comprueba que el dataset cumpla las reglas del modelo.

## Pruebas

- **Unitarias** (`tests/unit/`): servicios con repositorios falsos y el formato de errores de la API. No necesitan bases.
- **Integración** (`tests/integration/`): conectividad real con las tres bases, incluidos los casos de base caída o credenciales incorrectas.
- **CI** (`.github/workflows/ci.yml`): en cada push y pull request levanta las tres bases como servicios y corre todo lo anterior.

La guía del proyecto pide siete tipos de prueba de integración (conectividad, funcional, integridad, integración, consistencia, errores y rendimiento); su responsable y avance están en el [plan de trabajo](context/plan-trabajo.md).

## Documentación

| Documento | Contenido |
|---|---|
| [Plan de trabajo](context/plan-trabajo.md) | Perfiles del equipo, fases y tareas |
| [Cómo trabajamos](context/como-trabajar.md) | Del tablero al merge: el paso a paso del día a día |
| [Convenciones](context/convenciones.md) | Nombres, identificadores, formatos, reglas de la API y de git |
| [Matriz de propiedad de datos](docs/modelos/matriz-propiedad.md) | Qué dato vive en qué base y cómo se sincroniza |
| [Análisis de alternativas](docs/modelos/analisis-matriz.md) | Por qué esta arquitectura y no otra |
| [Contrato de la API](docs/api/contrato-v0.md) | Endpoints, entradas, salidas y errores |
| [Decisiones de modelado](docs/decisiones-modelado.md) | Registro de decisiones DEC-01 a DEC-24 |
| [Grafo de conocimiento](docs/KG.json) | Dominio completo del proyecto (v1.2) |
| [Guía del profesor](context/guia/Guia_Proyecto_Final_Bases_Datos.pdf) | Requisitos del proyecto final |

## Cómo contribuir

La guía paso a paso (tablero, ramas, commits, pull requests y revisión) está en [context/como-trabajar.md](context/como-trabajar.md). En resumen:

1. Crea tu rama desde `develop`: `feature/<perfil>-<tarea>` (por ejemplo, `feature/b-esquema-relacional`).
2. Un commit por implementación, con el formato `<ámbito>: <qué cambia>`.
3. Antes de subir: `npm run verificar` y `npm run test:integration` en verde.
4. Abre un pull request a `develop` con `Closes #N` (el issue de tu tarea) y fusiónalo tú mismo: no hace falta esperar aprobación.

Las reglas completas están en [convenciones §7](context/convenciones.md).

## Estado del proyecto

| Fase | Contenido | Estado |
|---|---|---|
| 0 | Acuerdos (matriz, convenciones, contrato, datos de prueba), estructura, Docker, esqueleto de la API, CI | 🟨 Casi terminada: falta que el equipo revise los acuerdos (issue #2) |
| 1 | Las tres bases: esquemas, carga desde el dataset, consultas y pruebas por base | ⏳ Siguiente |
| 2 | Backend de los flujos y sincronización con el grafo | ⏳ |
| 3 | Interfaz y las siete pruebas de integración | ⏳ |
| 4 | Cierre: rendimiento, documentación final y demostración | ⏳ |

## Solución de problemas

| Síntoma | Causa probable y solución |
|---|---|
| `required variable … is missing a value: Falta .env…` | No existe `.env` o le faltan los secretos: `npm run setup:env` |
| La base rechaza la contraseña (`password authentication failed`) | Regeneraste `.env` pero los volúmenes conservan la contraseña anterior: `npm run db:reset` (borra los datos) y `npm run db:up` |
| `Cannot connect to the Docker daemon` | Docker Desktop está apagado: ábrelo y espera a que termine de arrancar |
| `port is already allocated` | Otro programa usa ese puerto: cambia el puerto correspondiente en tu `.env` |
| La API arranca pero `/api/health` da `503` | Alguna base sigue iniciando (Neo4j tarda unos 20 s): `npm run db:ps` y espera a que aparezca `healthy` |
| `Configuración inválida (revisa tu .env…)` | Falta una variable o tiene un formato inválido: el mensaje dice cuál |

---

Universidad Politécnica de Chiapas · Bases de Datos en la Nube · 2026
