# CLAUDE.md — Proyecto QATO'K

Repositorio de entregables de la unidad 3 (BDLN) para el proyecto **QATO'K**. El grafo de conocimiento completo está en `docs/KG.json` (**v1.1**, 2026-11-12; v1.0 conservada en `docs/KG-v1.0.json`). Las decisiones que originaron la v1.1 (DEC-01..DEC-22) y su justificación están en `docs/decisiones-modelado.md`; este archivo resume lo esencial. **Si hay duda o se necesita detalle, consultar `docs/KG.json`, que es la fuente de verdad.**

## Reglas de trabajo para los entregables

- El estado de los entregables de la actividad se lleva en `PROGRESS.md` (enunciado en `docs/actividad.jpg`). **Actualizar `PROGRESS.md` (estado, checklist y bitácora) cada vez que se avance o corrija un entregable.**

- **Plan y verificación:** seguir `PLAN.md`. Cada creación o corrección de un entregable pasa por el ciclo ToT → CoVe → self-consistency, repitiéndolo hasta una ronda sin cambios (máx. 3 rondas; si no converge, consultar al usuario). Registrar cada ronda en `verificacion/`. Trabajar fase por fase y esperar aprobación del usuario entre fases.
- **Carpetas:** todos los entregables van en `entregables/`; los registros de verificación en `verificacion/`.
- Idioma: **español**.
- Formato de trabajo: **Markdown (.md)** mientras se modela. Al terminar, cada entregable se convertirá al formato final que le corresponda (p. ej. .docx para tablas/documentos; otro formato si el entregable lo requiere, como un diagrama). Escribir el .md pensando en que se convertirá: tablas Markdown estándar, encabezados claros, sin HTML.
- Distinguir siempre entre decisiones **confirmadas** (ACCEPTED), **preliminares** (PRELIMINARY) y **pendientes** (P-xx). No presentar como decidido lo que está pendiente; si un entregable necesita una propuesta sobre un tema pendiente, marcarla explícitamente como *propuesta*.
- Arquitectura vigente: **Neo4j principal + PostgreSQL complementaria**. La recomendación antigua (PostgreSQL principal) está **SUPERSEDED**: no usarla.
- **MongoDB fue evaluado y NO seleccionado**: solo mencionarlo como alternativa descartada.
- Usar los nombres exactos de etiquetas, relaciones, IDs (RF-xx, C-xx, RI-xx, MD-xx, D-xx, P-xx) y propiedades del modelo para mantener trazabilidad.

## Proyecto

- **Nombre:** QATO'K — *Sistema de simulación y aprendizaje de habilidades profesionales mediante experiencias interactivas*.
- **Categoría:** plataforma educativa y de simulación profesional.
- **Objetivo:** reducir la brecha entre la formación académica y las exigencias laborales mediante simulaciones prácticas.
- **Concepto central:** aprender mediante simulaciones con decisiones contextualizadas, consecuencias y retroalimentación.
- **Público objetivo:** estudiantes universitarios próximos a egresar, recién egresados, personas con formación académica y poca experiencia laboral formal.
- **Propuesta de valor:** practicar situaciones laborales antes de vivirlas; aprender por decisiones y consecuencias; retroalimentación orientada a mejora; identificar fortalezas/áreas de oportunidad; generar evidencias para empleadores.

### Stakeholder principal (STAKEHOLDER_01)
Estudiante de último semestre, sin experiencia laboral ni prácticas, CV corto, LinkedIn incompleto; solo experiencia académica.
- **Problemas:** no sabe si su experiencia académica es relevante, le cuesta demostrar y comunicar habilidades, inseguridad en entrevistas, poca experiencia con problemas reales.
- **Preferencias:** ejercicios prácticos, contextos realistas, decisiones con consecuencias, repetir simulaciones, retroalimentación explicada, sesiones cortas.
- **Restricciones:** poco tiempo, uso móvil, conectividad limitada, sensibilidad al costo, privacidad y control de lo que comparte.

### Análisis del problema
- **Problema central:** brecha entre formación académica y capacidad de enfrentar, resolver y demostrar competencias en situaciones profesionales reales.
- **Causas:** CAUSE_01 formación teórica predominante · CAUSE_02 falta de experiencia formal · CAUSE_03 pocas oportunidades de decidir bajo incertidumbre · CAUSE_04 dificultad para comunicar competencias en entrevistas · CAUSE_05 ausencia de retroalimentación.
- **Consecuencias:** inseguridad laboral, dificultad ante ambigüedad, poca demostración de habilidades blandas, no identifica áreas de mejora, CV con pocas evidencias.
- **Solución:** plataforma de simulaciones interactivas con decisiones, consecuencias, retroalimentación y seguimiento de habilidades.

## Requerimientos funcionales

| ID | Nombre | Descripción breve |
|---|---|---|
| RF-01 | Gestión de usuarios | Registro, inicio de sesión, administración de cuenta |
| RF-02 | Gestión de escenarios | Consultar y seleccionar simulaciones |
| RF-03 | Desarrollo de simulaciones | Presentar situaciones y avanzar con decisiones |
| RF-04 | Gestión de decisiones | Registrar decisiones y mostrar consecuencias |
| RF-05 | Retroalimentación personalizada | Explicar aciertos, errores y mejoras |
| RF-06 | Seguimiento del progreso | Registrar resultados y evolución de habilidades |
| RF-07 | Fortalezas y áreas de mejora | Identificar habilidades desarrolladas y a reforzar |
| RF-08 | Generación de evidencias | Evidencias de habilidades demostradas |
| RF-09 | Control de privacidad | Decidir qué se comparte y con quién |
| RF-10 | Acceso flexible | Sesiones cortas, uso móvil |

## Consultas clave del sistema (justifican el uso de grafos)

- **C-01** Simulaciones disponibles para un usuario según su progreso y habilidades a fortalecer (Usuario, Progreso, Habilidad, Simulacion).
- **C-02** Fortalezas y áreas de mejora según resultados (Usuario, Intento, Respuesta, Retroalimentacion, Progreso, Habilidad, Simulacion). Limitación LIM-01: atribución por simulación, no por decisión.
- **C-03** Decisiones tomadas en una simulación, consecuencias y retroalimentación (Usuario, Simulacion, Intento, Respuesta, Paso, Opcion, Consecuencia, Retroalimentacion; Simulacion añadida por DEC-23).
- **C-04** Evidencias compartibles de una habilidad y simulaciones de origen, respetando permisos (Usuario, Evidencia, Habilidad, Intento, Simulacion, Comparticion).
- **C-05** Evolución de una habilidad en el tiempo y simulaciones que contribuyeron (Usuario, Progreso, Habilidad, Intento, Simulacion). Limitación LIM-02: aproximación por intentos (P-07).

## Modelo de dominio (12 entidades / etiquetas Neo4j)

Todas con PK `UUID`.

| ID | Etiqueta | Propiedades (además del id) |
|---|---|---|
| E01 | `Usuario` | nombre VARCHAR(100), correo VARCHAR(150) UNIQUE, contrasena_hash VARCHAR(255), fecha_registro TIMESTAMP, estado VARCHAR(20) |
| E02 | `Simulacion` | titulo VARCHAR(150), descripcion TEXT, dificultad VARCHAR(30), duracion_estimada INTEGER NULL, estado VARCHAR(20) |
| E03 | `Habilidad` | nombre VARCHAR(100) UNIQUE, descripcion TEXT, categoria VARCHAR(50), nivel_objetivo INTEGER NULL |
| E04 | `Paso` | id_simulacion FK, titulo VARCHAR(150), descripcion TEXT, orden INTEGER, tipo VARCHAR(30) |
| E05 | `Opcion` | id_paso FK, descripcion TEXT, valoracion DECIMAL(5,2) NULL, id_paso_siguiente FK NULL |
| E06 | `Consecuencia` | id_opcion FK, descripcion TEXT, impacto VARCHAR(30), tipo VARCHAR(30) |
| E07 | `Intento` | id_usuario FK, id_simulacion FK, fecha_inicio TIMESTAMP, fecha_fin TIMESTAMP NULL, estado VARCHAR(20), puntuacion DECIMAL(5,2) NULL |
| E08 | `Respuesta` | id_intento FK, id_paso FK, id_opcion FK, fecha_respuesta TIMESTAMP, **secuencia INTEGER** (DEC-01) |
| E09 | `Retroalimentacion` | id_respuesta FK, comentario TEXT, tipo VARCHAR(30), recomendacion TEXT |
| E10 | `Progreso` | id_usuario FK, id_habilidad FK, nivel_actual DECIMAL(5,2), fecha_actualizacion TIMESTAMP |
| E11 | `Evidencia` | id_usuario FK, id_intento FK, titulo VARCHAR(150), descripcion TEXT, fecha_generacion TIMESTAMP, visibilidad VARCHAR(20) |
| E12 | `Comparticion` | id_evidencia FK, token VARCHAR(255) UNIQUE, fecha_creacion TIMESTAMP, fecha_expiracion TIMESTAMP NULL, estado VARCHAR(20), *destinatario VARCHAR(150) NULL* (propuesta, DEC-13) |

Ids: `id_usuario`, `id_simulacion`, `id_habilidad`, `id_paso`, `id_opcion`, `id_consecuencia`, `id_intento`, `id_respuesta`, `id_retroalimentacion`, `id_progreso`, `id_evidencia`, `id_comparticion`.

## Relaciones (17)

| ID | Patrón | Card. (origen / destino) |
|---|---|---|
| R01 | `(Usuario)-[:REALIZA]->(Intento)` | 0..N / 1..1 |
| R02 | `(Simulacion)-[:TIENE]->(Intento)` | 0..N / 1..1 |
| R03 | `(Simulacion)-[:CONTIENE]->(Paso)` | 0..N / 1..1 |
| R04 | `(Simulacion)-[:DESARROLLA {peso, nivel_esperado}]->(Habilidad)` | 0..N / 0..N (propuesta DEC-08: peso DECIMAL(3,2) en (0,1], nivel_esperado INTEGER 0–100) |
| R05 | `(Paso)-[:OFRECE]->(Opcion)` | 1..N / 1..1 |
| R06 | `(Opcion)-[:GENERA]->(Consecuencia)` | **1..N** / 1..1 (v1.1, DEC-02) |
| R07 | `(Opcion)-[:CONDUCE_A]->(Paso)` | 0..1 / 0..N |
| R08 | `(Intento)-[:REGISTRA]->(Respuesta)` | 0..N / 1..1 |
| R09 | `(Respuesta)-[:CORRESPONDE_A]->(Paso)` | 1..1 / 0..N |
| R10 | `(Respuesta)-[:SELECCIONA]->(Opcion)` | 1..1 / 0..N |
| R11 | `(Respuesta)-[:GENERA]->(Retroalimentacion)` | 0..N / 1..1 |
| R12 | `(Usuario)-[:TIENE_PROGRESO]->(Progreso)` | 0..N / 1..1 |
| R13 | `(Progreso)-[:CORRESPONDE_A]->(Habilidad)` | 1..1 / 0..N |
| R14 | `(Usuario)-[:GENERA]->(Evidencia)` | 0..N / 1..1 |
| R15 | `(Intento)-[:PRODUCE]->(Evidencia)` | 0..N / 1..1 |
| R16 | `(Evidencia)-[:DEMUESTRA]->(Habilidad)` | 1..N / 0..N |
| R17 | `(Evidencia)-[:TIENE_COMPARTICION]->(Comparticion)` | 0..N / 1..1 |

Tipos de relación (14): REALIZA, TIENE, CONTIENE, DESARROLLA, OFRECE, GENERA, CONDUCE_A, REGISTRA, CORRESPONDE_A, SELECCIONA, TIENE_PROGRESO, PRODUCE, DEMUESTRA, TIENE_COMPARTICION. Nota: `GENERA` y `CORRESPONDE_A` se reutilizan entre distintos pares de etiquetas.

**Convención de cardinalidad (DEC-07):** `origen / destino` = nº de destinos por cada origen / nº de orígenes por cada destino. **Rutas (DEC-03):** no hay pasos finales; una opción sin `CONDUCE_A` es terminal y completa el intento; el paso inicial es el de `orden = 1`.

## Restricciones de integridad

- **RI-01** UUID único y obligatorio en todas las entidades.
- **RI-02** Correo único sin distinguir mayúsculas (normalizar).
- **RI-03** Nombre de habilidad único.
- **RI-04** Propiedades esenciales NOT NULL.
- **RI-05** `dificultad` ∈ {BASICA, INTERMEDIA, AVANZADA}; estado de simulación ∈ {BORRADOR, PUBLICADA, INACTIVA}.
- **RI-06** Estado de intento ∈ {EN_CURSO, COMPLETADO, ABANDONADO}; `puntuacion` entre 0 y 100.
- **RI-07** `nivel_actual` de progreso entre 0 y 100.
- **RI-08** Par (simulación, habilidad) único en DESARROLLA.
- **RI-09** Todo intento pertenece a un usuario y una simulación existentes.
- **RI-10** La opción respondida pertenece al paso respondido, y el paso a la simulación del intento (validación transaccional/aplicación).
- **RI-11** El paso siguiente de una opción pertenece a la misma simulación que el paso origen.
- **RI-12** `fecha_fin` ≥ `fecha_inicio`; intento COMPLETADO requiere `fecha_fin`.
- **RI-13** Un único Progreso consolidado por (usuario, habilidad).
- **RI-14** Evidencia e intento de origen pertenecen al mismo usuario.
- **RI-15** Token de compartición único; evidencia privada no accesible sin autorización vigente (estado y expiración).

Añadidas en v1.1 (DEC-11): **RI-16** `secuencia` ≥1 y única por intento · **RI-17** contenido mínimo de simulación PUBLICADA · **RI-18** `orden` >0, único por simulación, `orden = 1` inicial · **RI-19** intentos solo de simulaciones PUBLICADAS · **RI-20** DEMUESTRA ⊆ DESARROLLA de la simulación del intento · **RI-21** `fecha_expiracion` > `fecha_creacion` · **RI-22** respuestas dentro de las fechas del intento y solo en EN_CURSO · **RI-23** COMPLETADO al elegir opción terminal · *RI-24* catálogos y rangos propuestos (propuesta) · *RI-25* evidencia solo de intento COMPLETADO (propuesta, P-05).

**Catálogos propuestos (DEC-04/09, `value_catalogs` del KG):** `Usuario.estado` {ACTIVO, INACTIVO, SUSPENDIDO} · `Paso.tipo` {CORREO, REUNION, CONVERSACION, TAREA, INCIDENTE} · `Consecuencia.impacto` {POSITIVO, NEUTRO, NEGATIVO} · `Consecuencia.tipo` {RELACIONAL, TIEMPO, CALIDAD, REPUTACION} · `Retroalimentacion.tipo` {ACIERTO, PARCIAL, ERROR} · `Evidencia.visibilidad` {PRIVADA, PUBLICA} (por defecto PRIVADA) · `Comparticion.estado` {ACTIVA, REVOCADA} (vigencia calculada con `fecha_expiracion`) · `Habilidad.categoria` sin catálogo (P-08).

**Neo4j (DEC-12):** uniqueness nativa en cualquier edición; existence/type/key solo Enterprise; reglas entre nodos en lógica de aplicación.

## Arquitectura (DECISION_TAKEN)

Arquitectura híbrida orientada a grafos:
- **Neo4j — principal (SELECTED).** Dominio fuertemente relacionado, ramificaciones paso→opción→paso, decisiones→consecuencias→retroalimentación, habilidades conectadas con simulaciones/progreso/evidencias, consultas de múltiples saltos y caminos. Consideraciones: constraints de unicidad, índices, evitar nodos/relaciones huérfanas, transacciones multi-entidad, respaldos, autenticación/autorización. Limitaciones: diseño cuidadoso de etiquetas/índices; restricciones complejas requieren validación adicional.
- **PostgreSQL — complementaria (SELECTED).** Integridad referencial, CHECK/UNIQUE/NOT NULL, transacciones, datos estructurados. Usos *potenciales* (no definitivos): catálogos y datos administrativos, usuarios/autenticación, datos transaccionales. Limitación: recorridos complejos requieren JOIN múltiples o consultas recursivas.
- **MongoDB — NOT_SELECTED.** Evaluado por flexibilidad de esquema y estructuras anidadas; descartado porque el dominio depende de relaciones, la flexibilidad documental no resuelve recorridos y añadiría complejidad.
- **Sincronización Neo4j↔PostgreSQL: PENDING_DESIGN.** Riesgos: duplicados desactualizados, referencias inconsistentes, operaciones parciales, pérdida de sincronización, conflictos de actualización.

## Decisiones de modelado lógico (PRELIMINARY_MODEL)

- **MD-01** Simulacion–Habilidad como relación directa `DESARROLLA {peso, nivel_esperado}`.
- **MD-02** `Progreso` como nodo independiente (habilita historial futuro; hoy solo uno consolidado por usuario-habilidad).
- **MD-03** Pasos y opciones como nodos conectados (ramificaciones).
- **MD-04** Decisiones como nodos `Respuesta` ligados a Intento, Paso y Opcion (reconstruir recorridos).
- **MD-05** `Evidencia` y `Comparticion` como nodos independientes.

## Decisiones registradas

ACCEPTED: D-01 nombre QATO'K · D-02 simulador de habilidades con experiencias interactivas · D-03 público universitario/egresados · D-04 escenarios con decisiones, consecuencias y retroalimentación · D-05 progreso por habilidad · D-06 evidencias · D-07 control de privacidad · D-08 Neo4j principal · D-09 PostgreSQL complementaria · D-11 DESARROLLA con propiedades · D-12 Progreso como nodo.
NOT_SELECTED: D-10 MongoDB. SUPERSEDED: D-13 PostgreSQL como fuente de verdad. ACCEPTED: D-14 resolución de la auditoría (DEC-01..22, KG v1.1).

## Decisiones pendientes

- **P-01** Distribución de entidades entre Neo4j y PostgreSQL.
- **P-02** Mecanismo de sincronización.
- **P-03** Cálculo del nivel de habilidad.
- **P-04** Modelado formal de ramificaciones, condiciones y consecuencias.
- **P-05** Autenticidad de evidencias.
- **P-06** Compartición: destinatarios, permisos, expiración, revocación.
- **P-07** Historial de progreso (nodo consolidado + mediciones históricas).
- **P-08** Catálogo de habilidades (categorías, niveles, criterios).
- **P-09** Formato de autoría/publicación de simulaciones.
- **P-10** Seguridad (authN/authZ, datos personales).
- **P-11** Escalabilidad (rendimiento, concurrencia, respaldos).

## Trazabilidad problema → solución

| Problema | Solución | RF | Entidades |
|---|---|---|---|
| Falta de experiencia práctica | Simulaciones profesionales | RF-02, RF-03 | Simulacion, Paso, Opcion, Intento |
| Decisiones en ambigüedad | Decisiones con consecuencias | RF-03, RF-04 | Paso, Opcion, Consecuencia, Respuesta |
| Sin retroalimentación útil | Retroalimentación personalizada | RF-05 | Respuesta, Retroalimentacion |
| No identifica fortalezas/debilidades | Seguimiento del progreso | RF-06, RF-07 | Usuario, Habilidad, Progreso, Intento |
| Difícil demostrar habilidades | Evidencias compartibles | RF-08, RF-09 | Evidencia, Comparticion, Habilidad |
| Tiempo y conectividad limitados | Acceso flexible, sesiones cortas | RF-10 | Usuario, Intento, Simulacion |

## Observaciones de modelado

OBS-01 simulación con múltiples pasos · OBS-02 paso con múltiples opciones · OBS-03 opción con una o más consecuencias (ahora coherente con R06 1..N) · OBS-04 opción conduce a otro paso o termina la ruta · OBS-05 usuario con múltiples intentos · OBS-06 respuesta ligada a intento, paso y opción · OBS-07 respuesta puede generar retroalimentación · OBS-08 Simulacion–Habilidad N:M · OBS-09 evidencia demuestra una o varias habilidades · OBS-10 usuario nuevo sin intentos/progreso/evidencias · OBS-11 simulación BORRADOR puede no tener pasos; PUBLICADA necesita contenido · OBS-12 progreso actual ≠ historial de evolución.

## Estado de la actividad

Los 7 entregables están terminados y verificados en `entregables/` (ver `PROGRESS.md`). La verificación automática se ejecuta con `python3 scripts/verificar.py` y debe dar 0 fallos después de cualquier cambio. Conversión a .docx hecha (`entregables/docx/`, `node scripts/md2docx.js`). Material de presentación en `presentacion/` (guía de estudio y diapositivas; ver su README). Los documentos y diapositivas no usan colores azules, por petición del usuario.

## Neo4j (F10)

Scripts en `neo4j/` (orden 01→06). Ejecutar todo con `neo4j/ejecutar.sh` (Neo4j 5.26 Community embebido vía Maven; necesita Java 21). Debe terminar con 0 fallos después de cualquier cambio en el modelo o en las consultas del entregable 1. Las consultas de `05-pruebas-humo.cypher` (sección D) son copia literal del entregable 1: si este cambia, actualizar esa sección. Los datos de ejemplo usan ids con el prefijo `e0000000-0000-4000-8000-`.

## Estado general

Definido: proyecto, público, necesidades, consultas del sistema. Preliminar: requerimientos, entidades, relaciones, restricciones, modelo lógico. Seleccionado: Neo4j (principal), PostgreSQL (complementaria). Pendiente: distribución de responsabilidades entre BD y sincronización. Implementación: no definida aún.
