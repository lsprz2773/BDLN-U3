# Auditoría v2 del proyecto BDLN-U3 (QATO'K) frente a la guía del proyecto final

> **Documento vigente para trabajar:** [`context/plan-trabajo.md`](../plan-trabajo.md). Este archivo queda como antecedente.

- **Fecha:** 18 de noviembre de 2026
- **Rama auditada:** `develop`, commit `3d1a719` (80 archivos versionados). Al día con `origin/develop` y `origin/main` después de `git fetch`.
- **Comparado contra:** *Guía_Proyecto_Final_Bases_Datos.pdf* (UPChiapas, 2026, 14 páginas).
- **Base:** *Reporte_Auditoria_BDLN-U3.pdf* (auditoría v1). Este documento la revisa punto por punto, confirma lo que se sostiene y corrige lo que no.

## 0. Veredicto

La auditoría v1 es **correcta en lo esencial**. El repositorio entrega bien **una** de las tres bases (Neo4j, como modelo y scripts verificados), y no existe nada de base relacional, base documental, backend, API, interfaz ni pruebas de integración.

El repositorio responde a la **actividad anterior** (diseño del modelo lógico de grafos, `docs/actividad.jpg`), no al proyecto final. La guía lo prevé: dice (sección 6.2) que lo hecho en Neo4j "se conserva como parte de la implementación de la base de grafos". **No hay que tirar nada**; hay que ampliar.

La contradicción de fondo sigue vigente: `CLAUDE.md` y `docs/KG.json` (D-10) declaran **MongoDB descartado**, y la guía **exige** una base documental. Esa decisión debe reabrirse antes de escribir código.

### Resultado

| Bloque | Cumple | Incompleto | Falta | Cambio frente a v1 |
|---|---|---|---|---|
| 4 reglas de la guía (2.1–2.4) + 3 reglas derivadas | 1 | 4 | 2 | Sin cambio |
| 8 entregables | 0 | 6 | 2 | Sin cambio |
| 10 criterios de "proyecto completo" | 1 | 5 | 4 | Sin cambio |
| 7 pruebas de integración | 0 | 3 | 4 | Sin cambio |

## 1. Qué se confirmó y cómo

| Afirmación de la v1 | Comprobación | Resultado |
|---|---|---|
| 80 archivos en `develop` (3d1a719) | `git ls-files \| wc -l` | ✅ Confirmado |
| `scripts/verificar.py`: 832 OK, 0 fallos | Ejecutado hoy | ✅ Confirmado |
| 15 restricciones Community, 9 índices | Conteo en `neo4j/01` y `neo4j/02` | ✅ Confirmado (además hay 12 restricciones *Enterprise* opcionales en `01b`) |
| 51 nodos, 71 relaciones, 76 pruebas con 0 fallos | `neo4j/resultado-pruebas.txt` | ✅ Confirmado **en el archivo**; no se reprodujo (ver 1.1) |
| Base Neo4j temporal y embebida | Primera línea del resultado: "Neo4j embebido listo (Community). Base temporal" | ✅ Confirmado |
| MongoDB descartado | `docs/KG.json` (D-10, `NOT_SELECTED`) y `CLAUDE.md` | ✅ Confirmado |
| PostgreSQL "complementaria" sin usos definidos | `CLAUDE.md` (usos *potenciales*), P-01 y P-02 pendientes | ✅ Confirmado |
| Sin README raíz, `.env.example`, `package.json`, docker-compose | `git ls-files` | ✅ Confirmado |
| `.gitignore` solo ignora `neo4j/runner/target/` | Leído | ✅ Confirmado (además `.DS_Store` aparece sin seguimiento: conviene ignorarlo) |
| `resultado-pruebas.txt` sin fecha, versión ni commit | Leído | ✅ Confirmado |
| "17 de las 25 reglas dependen de código de aplicación" | El entregable 4 marca 24 apariciones de `[A]` (aplicación) | 🟨 Plausible; el número exacto depende de cómo se cuenten reglas con mecanismo mixto. No cambia la conclusión |

### 1.1 Correcciones y matices a la v1

1. **"Nota del profesor" sobre el alcance de la interfaz (D1).** No aparece en la guía ni en ningún archivo del repositorio. Si existe (mensaje, clase, plataforma), **alguien del equipo debe tenerla por escrito**. Mientras tanto manda la guía: entregable 7 y criterio 7 exigen interfaz.
2. **Choque de numeración.** El repo tiene "entregables 01 a 07" de la actividad anterior; la guía pide "entregables 1 a 8" distintos. La v1 mezcla ambas numeraciones ("entregables 2 a 6"). Propuesta: llamar **A-01…A-07** a los de la actividad y **E1…E8** a los del proyecto final.
3. **Entorno para reproducir Neo4j.** La v1 dijo que hacían falta Java 21 y Maven. En esta máquina hay Java 26 (sin probar compatibilidad) y **no hay Maven**. Lo más simple es dejar de depender del ejecutor embebido y usar **Neo4j en Docker** (lo cual además resuelve "base persistente" y la prueba de conectividad).
4. **Herramientas ya disponibles** (esta máquina): `docker` (instalado, el demonio estaba apagado), `psql`, `mongosh`, `node` 26. No hay bloqueo técnico para arrancar.
5. **La partición de datos propuesta en la v1 (D3) duplica sin decirlo.** Pone pasos, opciones y consecuencias en la base documental, pero las consultas C-03 y la ramificación `CONDUCE_A` los necesitan en el grafo. No está mal replicar, pero hay que decir quién es la fuente de verdad. Ver la propuesta corregida en la sección 3.

## 2. Estado por bloque

### 2.1 Las tres bases

| Base | Estado | Qué hay | Qué falta |
|---|---|---|---|
| Grafo (Neo4j) | 🟨 Incompleto | 12 etiquetas, 17 relaciones, 15 restricciones, 9 índices, datos de ejemplo, consultas C-01…C-05, 76 pruebas con 0 fallos, verificador del modelo | Base persistente (servidor), conexión por driver con URI y credenciales, recortar a su responsabilidad, resultados fechados |
| Relacional (SQL) | 🟥 Falta | Solo tipos SQL en el diccionario de datos (A-02) y reglas RI-01…RI-25 (A-04), que **sí sirven de base** | Esquema, carga, consultas, pruebas |
| Documental | 🟥 Falta | Nada (motor descartado) | Todo, empezando por reabrir la decisión |

### 2.2 Entregables de la guía (E1–E8)

| # | Entregable | Estado | Evidencia reutilizable | Qué falta |
|---|---|---|---|---|
| E1 | Propuesta de aplicación | 🟨 | `docs/KG.json`, A-01, `presentacion/qatok-explicado.md` | Ficha con los 8 puntos de la guía (4.1), alcance y exclusiones, justificación y ejemplos por modelo, prueba de suficiencia (4.2) |
| E2 | Modelado de datos | 🟨 | A-02 a A-06, `docs/decisiones-modelado.md` | Modelo conceptual común, modelo lógico relacional, modelo documental |
| E3 | Arquitectura y tecnología | 🟨 | Sección de arquitectura del KG | Diagrama, responsabilidades por capa, matriz del stack, fuente de verdad y sincronización |
| E4 | Implementación de las 3 bases | 🟨 | `neo4j/` | SQL y documental completas; Neo4j persistente y reproducible |
| E5 | Catálogo de operaciones | 🟨 | C-01…C-05 (A-01), pruebas D1–D7 y E1–E4 | Parámetros, validaciones, casos límite y de error, operaciones de alta/cambio/baja, operaciones integradas, evidencia |
| E6 | Backend y API | 🟥 | — | Todo |
| E7 | Aplicación e integración | 🟥 | `modelo-logico-interactivo.html` no consume datos | Interfaz, flujos por base, caso integrado, evidencia de consistencia |
| E8 | Pruebas, documentación, despliegue | 🟨 | `neo4j/README.md`, `verificar.py` | Pruebas unitarias/integración/e2e, rendimiento, `.env.example`, README raíz, docker-compose |

### 2.3 Reglas

| Regla | Estado | Motivo |
|---|---|---|
| 2.1 Avanzar por etapas | 🟨 | Etapas 1–2 hechas solo para el grafo; 3–10 sin artefactos |
| 2.2 Aplicación concreta | ✅ | Problema, usuarios, objetivo y RF-01…RF-10 definidos |
| 2.3 Tres modelos justificados | 🟥 | MongoDB descartado; PostgreSQL sin responsabilidad definida |
| 2.4 Integración funcional | 🟥 | No hay código que conecte ninguna base |
| Sin duplicación sin propósito (sección 3) | 🟨 | No hay matriz de propiedad de datos |
| Escrituras parciales (5.2, 9) | 🟨 | Riesgo nombrado en el KG, sin política |
| Arquitectura modular, sin microservicios (5.2) | 🟨 | Nada que evaluar todavía |

### 2.4 Criterios de "proyecto completo" (sección 11)

| # | Criterio | Estado |
|---|---|---|
| 1 | Problema, usuarios y operaciones | ✅ |
| 2 | Tres modelos justificados | 🟥 |
| 3 | Modelos coherentes entre sí | 🟨 |
| 4 | Tres bases reproducibles | 🟨 |
| 5 | Consultas y pruebas por base | 🟨 |
| 6 | Backend con componentes separados | 🟥 |
| 7 | Interfaz consume el backend | 🟥 |
| 8 | Flujo integrado | 🟥 |
| 9 | Errores y consistencia | 🟨 |
| 10 | Documentación para instalar y ejecutar | 🟨 |

### 2.5 Las 7 pruebas de integración (sección 9)

| Prueba | Estado | Qué falta |
|---|---|---|
| Conectividad | 🟥 | Conexión real a los 3 motores con variables de entorno y prueba automatizada |
| Funcional | 🟨 | Probar operaciones **de la API**, no solo Cypher |
| Integridad | 🟨 | Validaciones SQL y documentales (el grafo ya tiene C1–C14) |
| Integración | 🟥 | Prueba de extremo a extremo de un flujo que toque 2+ bases |
| Consistencia | 🟥 | Escenario de dato replicado actualizado + reconciliación |
| Errores | 🟨 | Base caída y escritura parcial (hoy solo hay datos inválidos en Neo4j) |
| Rendimiento | 🟥 | Mediciones con entorno y volumen documentados |

## 3. Decisiones que bloquean el trabajo

| # | Decisión | Recomendación | Quién decide |
|---|---|---|---|
| D1 | Alcance de la interfaz | Interfaz web **mínima** que consuma la API (la guía la puntúa). Confirmar con el profesor si hay una nota que la limite | Equipo + profesor |
| D2 | Reabrir la base documental | **MongoDB**, con responsabilidad real (abajo). Actualizar KG (D-10 → SUPERSEDED), `CLAUDE.md` y material | Equipo |
| D3 | Reparto de datos y fuente de verdad | Partir de la matriz de abajo | Equipo |
| D4 | Stack y estilo de API | REST + OpenAPI. Lenguaje: el que más dominen los tres (Node/TypeScript o Python/FastAPI encajan bien con los tres drivers oficiales) | Equipo |
| D5 | Escrituras parciales | Escribir primero en la fuente de verdad; replicar al grafo con reintento; marcar pendientes; script de reconciliación que detecte y corrija diferencias | Equipo |
| D6 *(nueva)* | Fecha de entrega y alcance mínimo viable | Fijar fecha y recortar a 2–3 flujos completos antes que muchos incompletos | Equipo |

### 3.1 Propuesta de matriz de propiedad de datos (corrige la v1)

Criterio: cada dato tiene **un** dueño. El grafo guarda una **proyección** (ids + lo mínimo para recorrer) que se reconstruye desde las otras bases.

| Dato | Fuente de verdad | Réplica | Para qué se replica |
|---|---|---|---|
| Usuario (correo, hash, estado) | **PostgreSQL** | Neo4j: solo `id_usuario` | Anclar recorridos C-01…C-05 |
| Habilidad (catálogo) | **PostgreSQL** | Neo4j: id + nombre | Recorridos por habilidad |
| Simulación: metadatos (título, dificultad, estado) | **PostgreSQL** | Neo4j: id + estado | Filtrar publicadas en C-01 |
| Simulación: contenido (pasos, opciones, consecuencias, textos, retroalimentación de cada opción) | **MongoDB** (un documento por simulación, versionado) | Neo4j: ids de paso/opción + `CONDUCE_A` | Ramificaciones y C-03 |
| Intento (estado, fechas, puntuación) | **PostgreSQL** (transaccional: RI-12, RI-19, RI-22, RI-23) | Neo4j: id + relaciones | C-02, C-05 |
| Respuesta (decisión tomada) | **PostgreSQL** (secuencia única por intento, RI-16) | Neo4j: relaciones `SELECCIONA`/`CORRESPONDE_A` | C-03 |
| Retroalimentación entregada | **MongoDB** (texto variable dentro del registro del intento) | — | — |
| Progreso por habilidad | **Neo4j** (calculado a partir de intentos) | — | C-01, C-02, C-05 |
| Evidencia (contenido, forma variable) | **MongoDB** | PostgreSQL: registro con dueño y visibilidad; Neo4j: `DEMUESTRA` | Permisos y C-04 |
| Compartición (token, expiración, revocación) | **PostgreSQL** (unicidad y atomicidad, RI-15, RI-21) | — | — |

**Prueba de suficiencia (guía 4.2):**

- **Sin PostgreSQL** se pierde la atomicidad de "registrar respuesta y cerrar intento" y la unicidad y revocación de tokens.
- **Sin MongoDB** el contenido de cada simulación (árbol de longitud y forma variable) habría que partirlo en muchas tablas o nodos, y se pierde poder editarlo y versionarlo como una unidad.
- **Sin Neo4j** se pierden las recomendaciones (C-01) y los recorridos de decisiones y evidencias (C-03, C-04) con consultas simples.

> Es una propuesta. Hay que validarla en equipo antes de modelar y comprobar que ningún dato quede en dos bases sin dueño.

### 3.2 Flujo integrado candidato (guía 8.1)

**"Mi perfil de habilidades":** PostgreSQL da la cuenta y los intentos completados; Neo4j da fortalezas, áreas de mejora y simulaciones recomendadas (C-01, C-02); MongoDB da el texto de la retroalimentación y el contenido de las evidencias. El servicio une todo en una respuesta.

Un segundo flujo, de **escritura**, sirve para las pruebas de consistencia y errores: **"responder un paso"**. Se escribe en PostgreSQL, se replica al grafo y se fuerza un fallo de Neo4j para demostrar la política D5.

## 4. Orden de trabajo

| Fase | Contenido | Salida |
|---|---|---|
| 0 | Decisiones D1–D6, matriz de propiedad, identificadores UUID comunes, datos de prueba coherentes entre las tres bases | E1 y parte de E3 |
| 1 | Las tres bases en paralelo + docker-compose desde el día 1 | E2, E4 |
| 2 | Backend: un repositorio por base, servicios, API, flujo integrado | E5, E6 |
| 3 | Interfaz mínima | E7 |
| 4 | Las 7 pruebas (se escriben desde la fase 1), README, demostración | E8 |

## 5. Límites de esta revisión

- **Verificado:** contenido de `develop` (3d1a719), conteos de Neo4j, ejecución de `scripts/verificar.py` (832 OK, 0 fallos), herramientas instaladas en esta máquina.
- **No verificado:** las 76 pruebas de Neo4j no se reprodujeron (falta Maven). La "nota del profesor" que cita la v1 no se encontró.
- **Opinión:** las recomendaciones D1–D6, la matriz de propiedad y los flujos son propuestas para discutir en equipo.
