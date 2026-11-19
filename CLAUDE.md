# CLAUDE.md — Proyecto QATO'K (proyecto final de Bases de Datos en la Nube)

QATO'K es una plataforma de simulaciones profesionales: el estudiante toma decisiones en situaciones laborales, ve consecuencias y recibe retroalimentación, y la plataforma sigue el progreso de sus habilidades y genera evidencias compartibles.

El repositorio está en la etapa del **proyecto final**: una sola aplicación con **tres bases de datos** (relacional, documental y de grafos) coordinadas por una API, con interfaz. La guía del profesor manda: `context/guia/Guia_Proyecto_Final_Bases_Datos.pdf`.

## Leer primero

| Para… | Archivo |
|---|---|
| Saber qué hace cada integrante y en qué fase vamos | `context/plan-trabajo.md` |
| Nombres, ids, fechas, catálogos, API, git | `context/convenciones.md` |
| Qué dato vive en qué base (**la base de todo**) | `docs/modelos/matriz-propiedad.md` (por qué esta y no otra: `analisis-matriz.md`) |
| Endpoints, entradas, salidas y errores | `docs/api/contrato-v0.md` |
| Dominio completo (entidades, relaciones, RI, decisiones) | `docs/KG.json` **v1.2** — fuente de verdad del dominio |
| Historial de decisiones | `docs/decisiones-modelado.md` (DEC-01..DEC-24) |

## Arquitectura vigente (DEC-24, KG v1.2)

```
Next.js (frontend/) ──HTTP──► API REST Express + TS (backend/) ──► PostgreSQL · MongoDB · Neo4j
                              controllers → services → repositories/{relational,document,graph}
```

| Base | Responsabilidad | Es dueña de |
|---|---|---|
| **PostgreSQL** | Cuentas, estados y transacciones | usuario (+rol), habilidad, simulacion (metadatos y estado), simulacion_habilidad, intento, respuesta, evidencia (registro), comparticion, evento_sincronizacion |
| **MongoDB** | Documentos con estructura anidada y variable | contenidos_simulacion (pasos → opciones → consecuencias + retroalimentación; `contexto` distinto por `Paso.tipo`), evidencias (instantánea) |
| **Neo4j** | Proyección para recorridos (C-01..C-05) | Solo datos derivados: `Progreso` y `DEMUESTRA`. El resto son copias parciales (ids + lo que filtran las consultas) |

Reglas que no se rompen:
- **Una entidad existe cuando existe su registro en PostgreSQL.** Un documento de MongoDB sin registro es huérfano.
- **Todo cambio que deba llegar al grafo nace en PostgreSQL** junto con su evento (outbox `evento_sincronizacion`, misma transacción). Se aplica en Neo4j de inmediato y, si falla, se reintenta; efectos idempotentes con `MERGE`.
- La API **nunca** dice que el grafo está al día si el evento no se aplicó: responde con `sincronizacion: { grafo: "PENDIENTE" }`.
- El contenido de una simulación PUBLICADA es inmutable.
- **La interfaz solo consume la API** (guía §7.6): Next.js no importa drivers de bases (ESLint lo bloquea), no usa Route Handlers ni Server Actions como backend y no tiene credenciales de bases.
- El SQL, el MQL y el Cypher solo viven en `backend/src/repositories/` y en `database/`, siempre parametrizados.

## Estructura del repositorio

| Ruta | Qué hay |
|---|---|
| `backend/` | API (Express 5 + TypeScript). `GET /api/health` es la plantilla de capas a copiar |
| `frontend/` | Interfaz Next.js (la arma el responsable del frontend; ver `frontend/README.md`) |
| `shared/` | Esquemas zod y catálogos compartidos: **fuente única** de tipos para backend y frontend |
| `database/` | `relational/`, `document/`, `graph/` (scripts de cada base, con dueño) y `seed/` (datos de prueba comunes) |
| `tests/` | `unit/` (sin bases, repositorios falsos), `integration/` (contra Docker), `e2e/` |
| `docs/` | Lo que **evalúa el profesor** (E1–E8): modelos, API, pruebas |
| `context/` | Lo que ayuda al equipo a **trabajar**: plan, convenciones, guía, antecedentes |
| `entregables/`, `verificacion/`, `presentacion/`, `PLAN.md`, `PROGRESS.md` | **Actividad anterior** (modelo lógico de grafos, v1.1). Antecedente: no se edita salvo para corregir |

## Comandos

```bash
npm run setup:env           # una vez: crea .env con secretos aleatorios
npm install
npm run db:up               # PostgreSQL :5433, MongoDB :27018, Neo4j :7475/:7688 (espera a que estén sanas)
npm run dev:api             # API en http://localhost:4000/api
npm run verificar           # lint + formato + tipos + unitarias + dataset + modelo (debe quedar en verde)
npm run test:integration    # contra las 3 bases de Docker
```

`npm run verificar` y `npm run test:integration` deben pasar antes de cada commit que toque código. `python3 scripts/verificar.py` (incluido en `verificar`) debe seguir en **0 fallos**: valida los entregables de la actividad anterior contra el KG. `python3 database/seed/validar_dataset.py` valida los datos de prueba.

## Reglas de trabajo

- **Idioma:** español. Dominio con los nombres exactos del KG (`Simulacion`, `id_intento`, `CONDUCE_A`, RF-xx, C-xx, RI-xx, P-xx, D-xx, DEC-xx).
- **Gitflow:** `feature/<perfil>-<tarea>` desde `develop` → PR a `develop` con `Closes #N` → su autor lo fusiona (sin aprobación obligatoria ni protección de ramas, decisión del equipo). **Un commit por implementación**, con formato `<ámbito>: <qué cambia>` (convenciones §7). Fusionar con merge commit, no squash. Las tareas son los issues del repo (tablero: GitHub Project «QATO'K — Proyecto final»).
- **Avanzar paso a paso:** terminar un paso del plan, hacer su commit, reportar y esperar el visto bueno antes del siguiente.
- **Decisiones:** distinguir siempre **ACCEPTED/ADOPTADA**, **PRELIMINARY/PRELIMINAR** (pendiente de aprobación del equipo), **PROPOSED/PROPUESTA** (depende de una P-xx) y **pendientes** (P-xx). No presentar como decidido lo que no lo está. Toda decisión nueva se registra como DEC-xx en `docs/decisiones-modelado.md` y, si cambia el dominio o la arquitectura, en el KG con su `changelog`.
- **Documentos de modelo** (matriz, modelos lógicos, contrato): se verifican con ToT → CoVe → self-consistency antes de darlos por buenos. **El código** se verifica con pruebas y CI, no con rondas de documentos.
- **Datos de prueba:** nadie inserta datos a mano; todo sale de `database/seed/dataset.json` (ids con el prefijo `e0000000-0000-4000-8000-`).
- Los documentos y diapositivas **no usan colores azules** (preferencia del usuario).

## Dominio (resumen; el detalle está en el KG)

- **Usuarios:** estudiantes de último semestre y recién egresados (STAKEHOLDER_01) y administradores (`rol = ADMIN`).
- **RF-01..RF-10:** usuarios, escenarios, simulaciones, decisiones, retroalimentación, progreso, fortalezas y áreas de mejora, evidencias, privacidad, acceso flexible.
- **Consultas C-01..C-05:** recomendaciones, fortalezas y áreas de mejora, recorrido de decisiones, evidencias por habilidad, evolución de una habilidad.
- **12 entidades** (modelo conceptual común, todas con UUID): Usuario, Simulacion, Habilidad, Paso, Opcion, Consecuencia, Intento, Respuesta, Retroalimentacion, Progreso, Evidencia, Comparticion. **17 relaciones** R01..R17 y **25 restricciones** RI-01..RI-25.
- **Rutas de una simulación:** el paso inicial es el de `orden = 1`; una opción sin siguiente paso es terminal y completa el intento (RI-23).

## Pendientes abiertos

P-03 (cálculo del nivel de habilidad; la puntuación del intento tiene propuesta D-21), P-04 (ciclos entre pasos), P-05 (autenticidad de evidencias), P-06 (uso de `visibilidad = PUBLICA`), P-07 (historial de progreso), P-08 (catálogo de habilidades), P-09 (flujo de autoría), P-10 (seguridad), P-11 (escalabilidad). P-01 y P-02 quedaron resueltos de forma preliminar por DEC-24.
