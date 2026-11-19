# Plan de reparto del trabajo — proyecto final QATO'K

> **Documento vigente para trabajar:** [`context/plan-trabajo.md`](../plan-trabajo.md). Este archivo queda como antecedente.

- **Fecha:** 18 de noviembre de 2026
- **Equipo:** 3 personas (A, B y C; asignen nombres en la sección 4)
- **Parte de:** `context/antecedentes/auditoria-v2.md`
- **Decisiones ya tomadas:** se sigue la guía completa, **con interfaz** (D1). El stack es **Node.js con TypeScript** (D4).
- **Pendiente:** la fecha de entrega. El calendario está en semanas relativas; si hay menos tiempo, ver la sección 6.

---

## 1. Resumen

**Estrategia elegida: híbrida, "dueños de base + dueños de flujo".**

1. **Cada persona es dueña de una base de datos.** Escribe su esquema, sus datos, su repositorio en el backend y sus pruebas, y aprueba cualquier cambio que otro haga en ella.
2. **Cada persona es dueña de un flujo de usuario completo.** Hace el servicio, los endpoints, las pantallas y las pruebas. Cada flujo toca las tres bases, así que **todos programan contra las tres**.
3. **Cada persona tiene una tarea transversal**: infraestructura, sincronización o interfaz.

| | Base que posee | Flujo que posee | Tarea transversal |
|---|---|---|---|
| **A** | Neo4j | F3. Perfil de habilidades y evidencias compartidas | Sincronización hacia el grafo y reconciliación; datos semilla comunes; documento de arquitectura (E3) |
| **B** | PostgreSQL | F1. Cuenta y catálogo de simulaciones | Esqueleto del backend, autenticación, manejo de errores, contrato OpenAPI, Docker y CI |
| **C** | MongoDB | F2. Jugar una simulación (responder pasos) | Estructura de la interfaz y cliente de la API; propuesta (E1) y README |

La sección 2 explica por qué se eligió esta estrategia frente a otras tres, y la sección 3 cómo puede fallar y qué hacer en cada caso.

---

## 2. Árbol de alternativas (ToT)

### 2.1 Las cuatro ramas

| Rama | Idea | Ejemplo |
|---|---|---|
| **S1. Vertical por base** | Cada quien hace una base de principio a fin | A Neo4j, B PostgreSQL, C MongoDB; la integración se hace al final |
| **S2. Horizontal por capa** (la de la auditoría v1) | Cada quien hace una capa | A diseño y grafo, B las dos bases nuevas, C backend, pruebas e interfaz |
| **S3. Vertical por flujo** | Cada quien hace un flujo completo y toca todas las bases y capas | A perfil, B cuenta, C jugar; los esquemas los editan los tres |
| **S4. Híbrida** | Dueño de base (esquema y revisión) + dueño de flujo (de punta a punta) | La tabla de la sección 1 |

### 2.2 Cómo falla cada rama

**S1. Vertical por base**
- La integración queda para el final. Es justo el error que la guía señala: "probar cada motor por separado y afirmar que la integración funciona".
- Nadie es dueño de la sincronización. Pasa entre dos bases y no cae de forma natural en una persona.
- Neo4j ya está casi hecho, así que A está ocioso al inicio, mientras B hace la base más pesada (PostgreSQL más autenticación).
- **Riesgo de ausencia alto:** si una persona falla, se cae una base entera y con ella el criterio 2.
- En la exposición cada quien solo sabe explicar su motor.

**S2. Horizontal por capa**
- C es un cuello de botella. Backend, interfaz y pruebas dependen de que las tres bases existan, así que C espera durante la fase 1 y se satura en las fases 2 a 4.
- B carga dos bases y A queda ligero después del diseño.
- Las pruebas se juntan al final en una sola persona: otro error explícito de la guía.

**S3. Vertical por flujo**
- Tres personas editan los mismos esquemas a la vez. Eso trae conflictos de merge en el SQL y en los validadores, convenciones distintas y nadie que responda por la integridad de cada base.
- Las tres personas tienen que aprender los tres drivers desde el día uno, lo que hace lento el arranque.
- A cambio, es la mejor para integrar temprano y para que todos sepan explicar todo.

**S4. Híbrida**
- Tiene más costo de coordinación: cada cambio de esquema pasa por el dueño.
- Hay que cambiar de rol a mitad del proyecto (de "mi base" a "mi flujo").
- Hereda lo bueno de S1 (un responsable por la integridad de cada base) y de S3 (integración temprana y conocimiento repartido).

### 2.3 Evaluación

Escala de 1 a 5, donde **5 es mejor**. Los puntajes son juicio del equipo, no una medición; lo que importa es por qué pierde cada rama.

| Criterio | S1 | S2 | S3 | S4 |
|---|---|---|---|---|
| Trabajo en paralelo desde el inicio | 4 | 2 | 3 | 4 |
| Sin cuellos de botella | 3 | 1 | 4 | 4 |
| Integración temprana (no "big bang" al final) | 2 | 1 | 5 | 4 |
| Todos pueden defender el proyecto completo | 2 | 2 | 5 | 4 |
| Tolera la ausencia de un integrante | 2 | 2 | 4 | 4 |
| Pocos conflictos de merge y esquemas estables | 4 | 4 | 1 | 4 |
| Poca coordinación necesaria | 4 | 3 | 2 | 3 |
| **Total** | **21** | **15** | **24** | **27** |

**S2 se descarta**: es la única que concentra las pruebas al final. **S1 se descarta** porque deja la integración, que es el corazón de la guía, sin dueño y al final. **S3 contra S4:** S3 integra igual de bien, pero su punto débil (esquemas sin dueño) pega justo donde se evalúa: integridad, coherencia de modelos y pruebas por base. S4 lo corrige a cambio de algo más de coordinación.

### 2.4 Verificación de la elección (CoVe)

| Pregunta de verificación | Respuesta | ¿Se sostiene S4? |
|---|---|---|
| ¿Cada uno de los 8 entregables tiene un responsable? | Sí, ver la sección 4.3 | ✅ |
| ¿Cada una de las 7 pruebas de integración tiene un responsable? | Sí, ver la sección 4.4 | ✅ |
| ¿Algún flujo depende de otra persona antes de poder empezar? | Todos dependen del esqueleto del backend (B) y de la semilla común (A). Ambos tienen límite de 2 días y los demás avanzan mientras tanto con su base | ✅ con mitigación |
| ¿Cada flujo usa de verdad las tres bases? | F1: PostgreSQL + MongoDB (+ Neo4j al publicar). F2: las tres. F3: las tres | ✅ |
| ¿La sincronización tiene dueño? | A (destino del grafo). B es dueño de la tabla de eventos en PostgreSQL | ✅ |
| ¿La carga es pareja? | Estimación de la sección 4.2: A 15, B 15, C 14 días-persona (C lleva el flujo más difícil) | ✅ |
| ¿La interfaz empieza temprano? | C arma la estructura contra un API simulado desde la semana 1 | ✅ |

### 2.5 Prueba de consistencia: ¿la elección cambia con otro escenario?

| Escenario | S1 | S3 | S4 | ¿S4 sigue siendo la mejor? |
|---|---|---|---|---|
| Solo hay 2 semanas | Se pierde la integración | Se pierde tiempo aprendiendo drivers | Se recorta F1 (sección 6) | ✅ |
| Un integrante abandona a la mitad | Se pierde una base | Los otros dos siguen | Los otros dos siguen; cada base tiene un suplente que ya revisó sus PR | ✅ |
| El profesor pregunta a cualquiera en la defensa | Débil | Fuerte | Fuerte: cada flujo cruza las tres bases | ✅ |
| Cambia el modelo a mitad del proyecto | Fácil | Caótico | Lo coordina el dueño de la base | ✅ |

En los cuatro escenarios S4 queda igual o mejor que la siguiente alternativa, así que **se elige S4**.

---

## 3. Pre-mortem: cómo puede fallar S4 y qué hacemos

Imaginemos que es el día de la entrega y salió mal. Estas son las causas probables, de la más a la menos peligrosa.

| # | Falla | Señal temprana | Prevención | Si de todos modos pasa |
|---|---|---|---|---|
| 1 | **Integración en "big bang" al final** | En la semana 2 ningún endpoint toca dos bases | Esqueleto que ya funciona punta a punta en la semana 1: `GET /health` consulta las tres bases (es además la prueba de conectividad) | Congelar funciones nuevas y dedicar a los tres a F3 |
| 2 | **Datos de prueba incoherentes entre bases** (Ana existe en PostgreSQL con un UUID y en Neo4j con otro) | La prueba de integración falla por "no encontrado" | Un solo script de semilla escribe en las tres bases con los mismos UUID fijos (se parte de los datos de ejemplo `e0000000-…` de Neo4j). Una prueba comprueba que cada id existe donde debe | A rehace la semilla; nadie inserta datos a mano |
| 3 | **El esqueleto del backend (B) se retrasa** y bloquea los flujos | Al día 3 de la fase 1 no hay servidor | Límite de 2 días con un esqueleto mínimo (servidor, configuración, `/health`, middleware de errores). Mientras tanto, A y C prueban sus repositorios directo contra Docker, sin servidor | A toma el esqueleto y B pasa a su base |
| 4 | **Alguien cambia un esquema y rompe a otros** | Las pruebas de otro flujo fallan sin que hayan tocado nada | El esquema solo cambia por PR aprobado por su dueño. El SQL y el Cypher solo viven dentro de `repositories/` | Revertir el PR y abrir uno nuevo con la migración |
| 5 | **El contrato de la API se desfasa de la interfaz** | La interfaz recibe campos `undefined` | Esquemas zod en un paquete `shared/`: de ahí salen la validación, el OpenAPI y los tipos del frontend | El error aparece al compilar, no en la demo |
| 6 | **La sincronización con el grafo nadie la prueba** | Sin prueba de consistencia en la semana 2 | A es dueño. Usa una tabla de eventos pendientes en PostgreSQL, escrita en la misma transacción, y un proceso que la aplica a Neo4j con reintento. La prueba de consistencia corre en CI | Documentar la reconciliación manual (script) como política mínima: la guía la acepta si está documentada |
| 7 | **Docker no corre en la máquina de alguien** (RAM, Windows sin WSL) | Fallo el día 1 de la fase 0 | Probar `docker compose up` en las tres máquinas el primer día. Limitar la memoria de Neo4j en el compose | Usar servicios en la nube gratuitos (Neon o Supabase para PostgreSQL, MongoDB Atlas, Neo4j AuraDB Free) con el mismo `.env`. Encaja con la materia |
| 8 | **La interfaz se come el tiempo** (perfeccionar el diseño) | Más de 2 días en una sola pantalla | Una librería de componentes y pantallas funcionales sin animaciones. La guía evalúa que consuma la API, no el diseño | Recortar a las pantallas de F2 y F3 |
| 9 | **Las pruebas quedan para el final** | PR sin pruebas | Regla: un PR sin prueba no entra. CI con las tres bases como servicios en GitHub Actions | Semana de pruebas con funciones congeladas |
| 10 | **Documentos desactualizados**: el KG sigue diciendo "MongoDB descartado" y `verificar.py` falla al cambiarlo | Contradicciones entre la propuesta y el código | A registra la decisión DEC-24 (MongoDB adoptado, D-10 pasa a SUPERSEDED), actualiza el KG y `CLAUDE.md`, y corre `verificar.py` | El profesor nota la contradicción: eso resta en el criterio 3 |
| 11 | **Un integrante se ausenta o abandona** | Sin commits en 4 días | Cada base tiene un suplente (quien más revisa sus PR) y cada flujo se puede demostrar por separado | Prioridad de rescate: F2 y F3 (cubren integración, consistencia y errores) antes que F1 |
| 12 | **En la defensa alguien no sabe explicar una parte** | — | Cada flujo cruza las tres bases y las revisiones de PR rotan. Un ensayo de la defensa en la última semana | — |
| 13 | **Carga desigual** | Una persona cierra la mitad de las tareas de la semana | Tablero (GitHub Projects) y revisión semanal de 15 minutos | Mover una tarea transversal a quien vaya adelantado |
| 14 | **El proceso de `CLAUDE.md` frena el código** (rondas ToT/CoVe y aprobación entre fases para todo) | PR detenidos esperando "verificación" | Actualizar `CLAUDE.md` para la nueva etapa: rondas de verificación solo para documentos de modelo; el código se valida con pruebas y CI | — |
| 15 | **Conflictos de merge en archivos compartidos** (`package.json`, rutas, `docker-compose.yml`) | Conflictos en cada PR | B crea toda la estructura en la fase 0; cada flujo registra sus rutas en su propio archivo | — |

---

## 4. Reparto detallado

### 4.1 Stack (D4 resuelta: Node y TypeScript)

| Componente | Propuesta | Por qué |
|---|---|---|
| Backend | Node + TypeScript + **Express** (o Fastify si ya lo conocen) | El más conocido; la guía no pide nada especial |
| Validación y contrato | **zod** + generación de OpenAPI (`@asteasolutions/zod-to-openapi`) | Una sola fuente para validar, documentar el contrato y tipar el frontend |
| Drivers | `pg`, `mongodb`, `neo4j-driver` (oficiales) | La guía pide drivers oficiales y consultas parametrizadas. **Sin ORM**: el SQL a la vista demuestra el modelo relacional |
| Frontend | **Vite + React + TypeScript** | Separado del backend: es evidente que la interfaz no toca las bases. No conviene Next.js, que difumina esa frontera |
| Pruebas | **Vitest** (unitarias e integración) + **Playwright** (1 o 2 casos e2e) | Un solo runner para todo |
| Entorno | `docker-compose.yml` con PostgreSQL 16, MongoDB 7 y Neo4j 5 | Reproducible (criterio 4) |
| CI | GitHub Actions con las tres bases como servicios | Evidencia automática de las pruebas |

Estructura del repositorio, siguiendo la sección 10 de la guía:

```
database/{relational,document,graph}/   ← cada dueño
backend/src/{controllers,services,repositories/{relational,document,graph}}
frontend/
shared/            ← esquemas zod compartidos
tests/{unit,integration,e2e}
docs/{propuesta.md, modelos/, arquitectura.md, decisiones-tecnologicas.md, api/, pruebas/}
```

El material actual de `neo4j/` se mueve a `database/graph/`. Los entregables de la actividad anterior pasan a `docs/modelos/grafo/` como antecedente.

### 4.2 Tareas y carga estimada (días-persona)

| Tarea | A | B | C |
|---|---|---|---|
| Base propia: esquema, índices, validaciones, carga, consultas, pruebas por base | Neo4j: adaptar lo existente, Docker, driver **2** | PostgreSQL desde cero **4** | MongoDB: colecciones, `$jsonSchema`, índices **3** |
| Transversal | Semilla común **2** + sincronización y reconciliación **4** | Esqueleto, autenticación, errores, OpenAPI **4** + Docker y CI **2** | Estructura de la interfaz, cliente de la API, API simulado **3** |
| Flujo propio | F3 **5** | F1 **4** | F2 **6** |
| Documentos | E3 arquitectura **2** | E5 catálogo (cada quien documenta sus operaciones; B lo integra) **1** | E1 propuesta + README de instalación **2** |
| **Total** | **15** | **15** | **14** |

Además, los tres juntos: fase 0 (unos 3 días), E2 (cada quien el modelo de su base; el modelo conceptual común se hace juntos), rendimiento, y ensayo y demostración (unos 2 días).

### 4.3 Los flujos

| Flujo | Qué hace el usuario | PostgreSQL | MongoDB | Neo4j | Cubre |
|---|---|---|---|---|---|
| **F1. Cuenta y catálogo** (B) | Registrarse, iniciar sesión, ver y filtrar simulaciones. Un administrador crea, edita, publica y elimina una simulación | Usuario, metadatos de la simulación, transacción de publicación | Documento de contenido de la simulación | Al publicar, se proyectan simulación y pasos | RF-01, RF-02, altas, cambios y bajas |
| **F2. Jugar una simulación** (C) | Iniciar un intento, ver el paso, elegir una opción, ver la consecuencia y la retroalimentación, terminar | Intento y respuesta en una transacción (RI-16, RI-19, RI-22, RI-23) + evento pendiente | Lee el contenido; guarda la retroalimentación entregada | Réplica de la respuesta (sincronización) | RF-03 a RF-05; **escritura en varias bases, consistencia y errores** |
| **F3. Perfil y evidencias** (A) | Ver fortalezas, áreas de mejora y recomendaciones; generar una evidencia; compartirla con un enlace que vence; revocarlo | Cuenta, intentos, token de compartición (RI-15, RI-21) | Contenido de la evidencia | C-01, C-02, C-04, C-05 | RF-06 a RF-09; **flujo integrado de lectura** (guía 8.1) |

### 4.4 Quién responde por cada prueba de integración

| Prueba | Responsable | Evidencia |
|---|---|---|
| Conectividad | B | `/health` + prueba automatizada (semana 1) |
| Funcional | Cada dueño de flujo | Casos por operación del catálogo E5 |
| Integridad | Cada dueño de base | Consultas de validación SQL, `$jsonSchema` y C1–C14 de Neo4j |
| Integración | A (F3) | Prueba de extremo a extremo del perfil |
| Consistencia | A, con C | Responder un paso → réplica en el grafo → reconciliación detecta una diferencia forzada |
| Errores | C (F2) | Neo4j caído durante "responder": la respuesta se guarda, el evento queda pendiente y luego se aplica. Más datos inválidos |
| Rendimiento | B | Mediciones de F2 y F3 con volumen y equipo documentados |

### 4.5 Reglas de trabajo

1. Flujo git que ya usan: `feature/<persona>-<tarea>` desde `develop` y PR a `develop`.
2. Todo PR lleva pruebas y lo revisa otra persona. Si toca una base, lo revisa su dueño.
3. Nadie inserta datos a mano: todo pasa por la semilla.
4. El SQL, el MQL y el Cypher solo viven en `repositories/`.
5. Revisión semanal de 15 minutos con el tablero.

---

## 5. Calendario (semanas relativas)

| Etapa | A | B | C | Hito de salida |
|---|---|---|---|---|
| **Fase 0** (3 días, juntos) | Matriz de propiedad de datos, DEC-24 en el KG | Estructura del monorepo, compose, `.env.example` | Ficha de propuesta (E1) | Las 3 bases levantan en las 3 máquinas; contrato OpenAPI v0; lista de UUID de la semilla |
| **Semana 1** | Neo4j en Docker + repositorio + semilla común | Esqueleto (2 días) + esquema PostgreSQL | Validadores MongoDB + estructura de la interfaz con API simulado | `/health` con las 3 bases en verde, en CI |
| **Semana 2** | Sincronización + F3 (lectura) | F1 | F2 (backend) | Primera prueba de integración y primera de consistencia en verde |
| **Semana 3** | F3 (compartir) + reconciliación | F1 (administración) + rendimiento | F2 (interfaz y errores) | Las 7 pruebas existen; flujos completos en la interfaz |
| **Semana 4** | E3 + revisión cruzada | E5 + mediciones | README + e2e | Instalación desde cero por alguien que no lo programó; ensayo de la defensa |

## 6. Si el plazo es menor

Recortes en este orden, del primero que se quita al último:

1. Administración de simulaciones en F1: se cargan por semilla y solo queda la lectura del catálogo.
2. Playwright: la prueba e2e se hace manual y documentada con capturas.
3. CI: se corren las pruebas en local y se guarda la salida fechada.
4. **Nunca se recortan:** las tres bases, F2, F3, la prueba de consistencia, la de errores y el README.

## 7. Decisiones que siguen abiertas

- **Fecha de entrega**: cambia el calendario y los recortes.
- **Asignación de A, B y C a personas.** Sugerencia: B para quien tenga más experiencia en backend; C para quien tenga más experiencia en frontend; A para quien mejor conozca el modelo de grafo actual.
- Validar en equipo la matriz de propiedad de datos (`auditoria-v2.md`, sección 3.1).
