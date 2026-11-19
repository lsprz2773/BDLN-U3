# Matriz de propiedad de datos — QATO'K

- **Paso del plan:** 0.1 (`docs/plan-trabajo.md`). Responde a las secciones 5.1 y 5.2 de la guía.
- **Estado:** PROPUESTA. Necesita la aprobación de B y C (puerta 0). Un cambio posterior se hace por PR aprobado por los 3.
- **Base:** modelo del KG v1.1 (12 entidades, 17 relaciones) y consultas C-01 a C-05 del entregable A-01.

## 1. Regla general

1. **Cada dato tiene una sola base dueña.** Solo ahí se modifica oficialmente.
2. **Una entidad "existe" cuando existe su registro en PostgreSQL.** MongoDB guarda el *contenido* de algunas entidades, pero un documento sin su registro en PostgreSQL es un **huérfano** y la reconciliación lo elimina.
3. **Neo4j es una proyección** para recorrer conexiones. Solo guarda ids, relaciones y las propiedades que las consultas C-01 a C-05 necesitan para filtrar u ordenar. El único dato que **nace** en el grafo es el **progreso**, que es derivado y se puede recalcular.
4. **Nada se copia "por si acaso".** Cada propiedad copiada indica qué consulta la necesita.

## 2. Qué responsabilidad tiene cada base

| Base | Responsabilidad | Pregunta de la guía (§3) que responde |
|---|---|---|
| **PostgreSQL** | Cuentas, catálogo, estado de las simulaciones, intentos y respuestas, registro de evidencias, enlaces compartidos y eventos de sincronización | ¿Qué registro existe, cuál es su estado y qué operación debe mantenerse íntegra? |
| **MongoDB** | Contenido de cada simulación (un árbol anidado de pasos, opciones, consecuencias y retroalimentación, de forma variable y versionado), retroalimentación entregada y contenido de las evidencias | ¿Qué información contextual o flexible pertenece a este registro? |
| **Neo4j** | Ramificaciones entre pasos, recorridos de decisiones, relación habilidad–simulación–progreso–evidencia y recomendaciones | ¿Cómo se conecta esta entidad con otras y qué rutas existen? |

### Prueba de suficiencia (guía §4.2): ¿qué se pierde si quitamos cada base?

| Si se quita… | Se pierde |
|---|---|
| PostgreSQL | La atomicidad de "registrar respuesta + cerrar intento + emitir evento"; la unicidad de correo, token y secuencia; la revocación y el vencimiento confiables de los enlaces |
| MongoDB | Editar y versionar una simulación como **una unidad**. Habría que partir un árbol de forma variable en 4 tablas o en cientos de nodos y reensamblarlo en cada lectura |
| Neo4j | Las recomendaciones (C-01), los recorridos de decisiones (C-03) y la relación evidencia–habilidad–simulación (C-04, C-05) con consultas simples. En SQL serían JOIN múltiples o CTE recursivas |

## 3. Matriz por entidad

Leyenda: **●** = base dueña · **◐** = copia parcial (solo los campos listados) · — = no está.

| Entidad (KG) | PostgreSQL | MongoDB | Neo4j | Campos copiados y para qué |
|---|---|---|---|---|
| E01 Usuario | ● (`usuario`: nombre, correo normalizado, contrasena_hash, fecha_registro, estado, **rol**) | — | ◐ `id_usuario` | Ancla de C-01 a C-05. El correo **no** se copia (privacidad, RF-09) |
| E02 Simulacion (metadatos) | ● (`simulacion`: titulo, descripcion, dificultad, duracion_estimada, estado, version_contenido) | — | ◐ `id_simulacion`, `titulo`, `estado` | `estado` filtra PUBLICADA en C-01; `titulo` aparece en los resultados de C-01, C-04 y C-05 |
| E02 Simulacion (contenido) | — | ● (`contenidos_simulacion`, un documento por simulación y versión) | — | — |
| E03 Habilidad | ● (`habilidad`: nombre único, descripcion, categoria, nivel_objetivo) | — | ◐ `id_habilidad`, `nombre`, `nivel_objetivo` | `nombre` es parámetro de C-04 y C-05; `nivel_objetivo` lo usa C-02 |
| R04 DESARROLLA {peso, nivel_esperado} | ● (`simulacion_habilidad`, PK (id_simulacion, id_habilidad), RI-08) | — | ◐ relación con `peso`, `nivel_esperado` | C-01 (`nivel_esperado`), C-02, C-05 |
| E04 Paso | — | ● (anidado en `contenidos_simulacion.pasos[]`: titulo, descripcion, orden, tipo) | ◐ `id_paso`, `orden` + `CONTIENE` | Ramificación y C-03 (orden). Los textos los completa el servicio desde MongoDB |
| E05 Opcion | — | ● (anidada en `pasos[].opciones[]`: descripcion, valoracion, id_paso_siguiente) | ◐ `id_opcion` + `OFRECE`, `CONDUCE_A` | Ramificación (`CONDUCE_A`) y C-03 |
| E06 Consecuencia | — | ● (anidada en `opciones[].consecuencias[]`) | — **(sale del grafo)** | No se recorre: siempre se lee junto con su opción. C-03 la completa desde MongoDB |
| E07 Intento | ● (`intento`: id_usuario, id_simulacion, version_contenido, fecha_inicio, fecha_fin, estado, puntuacion) | — | ◐ `id_intento`, `estado`, `fecha_inicio`, `fecha_fin`, `puntuacion` + `REALIZA`, `TIENE` | C-02, C-03 (fecha), C-05 (COMPLETADO, fecha_fin, puntuacion) |
| E08 Respuesta | ● (`respuesta`: id_intento, id_paso, id_opcion, fecha_respuesta, secuencia; UNIQUE (id_intento, secuencia)) | — | ◐ `id_respuesta`, `secuencia` + `REGISTRA`, `CORRESPONDE_A`, `SELECCIONA` | C-03 (orden del recorrido), C-02 |
| E09 Retroalimentacion | — | ● (`retroalimentaciones_entregadas`: id_respuesta, comentario, tipo, recomendacion) | ◐ `id_retroalimentacion`, `tipo` + `GENERA` | C-02 cuenta ACIERTO, PARCIAL y ERROR |
| E10 Progreso | — | — | ● (`nivel_actual`, `fecha_actualizacion`) + `TIENE_PROGRESO`, `CORRESPONDE_A` | **Derivado**: se recalcula a partir de intentos COMPLETADO y DESARROLLA (fórmula pendiente, P-03). Si se pierde, la reconciliación lo reconstruye |
| E11 Evidencia (registro) | ● (`evidencia`: id_usuario, id_intento, titulo, fecha_generacion, visibilidad) | — | ◐ `id_evidencia`, `titulo` + `GENERA`, `PRODUCE` | C-04 |
| E11 Evidencia (contenido) | — | ● (`evidencias_contenido`: resumen del recorrido, decisiones destacadas y métricas, con forma variable) | — | — |
| R16 DEMUESTRA | — | — | ● (derivada al generar: habilidades DESARROLLA de la simulación del intento, RI-20) | C-04 |
| E12 Comparticion | ● (`comparticion`: token único, fecha_creacion, fecha_expiracion, estado, destinatario) | — | — **(sale del grafo)** | Es un dato transaccional (RI-15, RI-21). C-04 pasa a ser una **consulta integrada**: el grafo da evidencia–habilidad–simulación y PostgreSQL filtra por enlace vigente |
| *Nuevo* Evento de sincronización | ● (`eventos_sincronizacion`, ver §5) | — | — | — |

**Cambios frente al modelo de grafo actual (A-02 a A-06), que A aplica en la fase 1:**
- Salen del grafo `Consecuencia` y `Comparticion`, con sus relaciones R06 y R17.
- Los nodos pierden las propiedades de texto, que ahora viven en MongoDB o en PostgreSQL.
- La restricción de unicidad de `Usuario.correo` en Neo4j ya no aplica.
- C-03 y C-04 se reescriben como consultas que el servicio completa con otras bases.

## 4. Operaciones que escriben en más de una base

Patrón común:
1. **Contenido primero** en MongoDB.
2. **Registro después** en PostgreSQL, dentro de una transacción que también escribe el evento.
3. **Proyección al final** en Neo4j, de forma asíncrona y con reintento.

| Operación (flujo, dueño) | Orden de escritura | Si falla el paso 2 | Si falla el paso 3 (Neo4j) | Qué responde la API |
|---|---|---|---|---|
| Registrar usuario (F1, B) | PG `usuario` + evento `USUARIO_CREADO` (misma transacción) | Nada que compensar | Evento queda PENDIENTE y se reintenta | `201` + `sincronizacion` |
| Crear simulación en BORRADOR (F1, B) | 1) Mongo contenido v1 → 2) PG `simulacion` + `simulacion_habilidad` | **Compensación:** borrar el documento de Mongo. Si también falla, la reconciliación lo detecta como huérfano | No aplica: un BORRADOR no se proyecta | `201` / `500` sin huérfano |
| Editar contenido (F1, B) | 1) Mongo nueva versión → 2) PG `version_contenido` | Compensación: borrar la versión nueva | No aplica en BORRADOR | `200` |
| Publicar (F1, B) | Valida RI-17 contra Mongo → PG estado PUBLICADA + evento `SIMULACION_PUBLICADA` con la estructura (pasos, opciones, `CONDUCE_A`, DESARROLLA) | Transacción revierte | Reintento | `200` + `sincronizacion` |
| Eliminar (F1, B) | Solo BORRADOR: PG delete → Mongo delete. PUBLICADA nunca se borra: pasa a INACTIVA + evento | Si falla el borrado en Mongo: huérfano, lo limpia la reconciliación | Reintento | `204` |
| Iniciar intento (F2, C) | PG `intento` (RI-19) + evento `INTENTO_INICIADO` | — | Reintento | `201` |
| **Responder un paso** (F2, C) | Lee contenido de Mongo → **una transacción PG**: `respuesta` (RI-10, RI-16, RI-22) + cerrar intento si la opción es terminal (RI-23) + evento `RESPUESTA_REGISTRADA` (+ `INTENTO_FINALIZADO`) → Mongo `retroalimentaciones_entregadas` | Si falla Mongo después del commit: la retroalimentación se puede **derivar** del contenido, así que la API la devuelve igual y la reconciliación la regenera | Reintento; el progreso se recalcula al aplicar `INTENTO_FINALIZADO` | `201` con la retroalimentación + `sincronizacion` |
| Generar evidencia (F3a, A) | 1) Mongo `evidencias_contenido` → 2) PG `evidencia` + evento `EVIDENCIA_GENERADA` | Compensación: borrar el contenido de Mongo | Reintento; al aplicar se crean `PRODUCE` y `DEMUESTRA` | `201` + `sincronizacion` |
| Compartir y revocar (F3b, B) | Solo PG | — | — | `201` / `204` |

**Honestidad de la respuesta (guía §9):** cada operación que deja trabajo pendiente en otra base incluye

```json
"sincronizacion": { "grafo": "PENDIENTE" | "APLICADO", "id_evento": "<uuid>" }
```

La API **nunca** responde que todo está sincronizado si el evento no se aplicó.

## 5. Sincronización hacia Neo4j (dueño: A; tabla: B)

**Mecanismo:** *outbox* transaccional. El evento se escribe en PostgreSQL **dentro de la misma transacción** que el cambio, así que no puede existir un cambio sin su evento ni un evento sin su cambio. Un proceso dentro del backend lo aplica en Neo4j.

```sql
CREATE TABLE eventos_sincronizacion (
  id_evento     UUID PRIMARY KEY,
  tipo          VARCHAR(40)  NOT NULL,
  id_entidad    UUID         NOT NULL,
  payload       JSONB        NOT NULL,
  estado        VARCHAR(10)  NOT NULL DEFAULT 'PENDIENTE'
                CHECK (estado IN ('PENDIENTE','APLICADO','FALLIDO')),
  intentos      INTEGER      NOT NULL DEFAULT 0,
  ultimo_error  TEXT         NULL,
  creado_en     TIMESTAMPTZ  NOT NULL DEFAULT now(),
  aplicado_en   TIMESTAMPTZ  NULL
);
CREATE INDEX ON eventos_sincronizacion (estado, creado_en);
```

| Tipo de evento | Lo emite | Efecto en Neo4j |
|---|---|---|
| `USUARIO_CREADO` | F1 | MERGE `Usuario` |
| `HABILIDAD_GUARDADA` | F1 (admin) | MERGE `Habilidad` (nombre, nivel_objetivo) |
| `SIMULACION_PUBLICADA` | F1 | MERGE `Simulacion`, `Paso`, `Opcion`, `CONTIENE`, `OFRECE`, `CONDUCE_A`, `DESARROLLA` |
| `SIMULACION_ESTADO_CAMBIADO` | F1 | SET `estado` (p. ej. INACTIVA) |
| `INTENTO_INICIADO` | F2 | MERGE `Intento` + `REALIZA` + `TIENE` |
| `RESPUESTA_REGISTRADA` | F2 | MERGE `Respuesta` + relaciones + `Retroalimentacion {tipo}` |
| `INTENTO_FINALIZADO` | F2 | SET estado, fecha_fin, puntuacion; **recalcula `Progreso`** |
| `EVIDENCIA_GENERADA` | F3a | MERGE `Evidencia` + `GENERA` + `PRODUCE` + `DEMUESTRA` |

Reglas del proceso:
- Todo efecto usa `MERGE` por id, así que **aplicar dos veces da lo mismo** (idempotente). Por eso se puede reintentar sin miedo.
- Los eventos se aplican en orden de `creado_en`.
- Máximo 5 intentos con espera creciente. Después queda `FALLIDO` y lo atiende la reconciliación.

## 6. Reconciliación (dueño: A)

Es un script (`npm run reconciliar`) que se puede correr a mano o de forma periódica. Reporta lo que encontró y lo que reparó:

| Revisión | Detecta | Repara |
|---|---|---|
| PG ↔ Neo4j por etiqueta | Ids que faltan o sobran en el grafo | Reemite el evento / borra el nodo sobrante |
| Eventos `FALLIDO` | Eventos que no se aplicaron | Los reintenta y reporta los que siguen fallando |
| Mongo ↔ PG | Contenidos de simulación o evidencia sin registro en PG (huérfanos) | Los borra (solo si tienen más de 10 minutos, para no pisar una escritura en curso) |
| Retroalimentación | Respuestas sin documento en `retroalimentaciones_entregadas` | La regenera a partir del contenido |
| Progreso | `nivel_actual` distinto del recálculo | Lo recalcula |

Esta reconciliación es la evidencia de las pruebas de **consistencia** y **errores** de la guía (§9).

## 7. Decisiones que esta matriz toma (para registrar como DEC-24 en el paso 0.10)

1. MongoDB se adopta como base documental (D-10 pasa a SUPERSEDED).
2. PostgreSQL deja de ser "complementaria": es dueña de cuentas, estados y transacciones (resuelve P-01).
3. La sincronización se hace con outbox + proceso idempotente + reconciliación (resuelve P-02).
4. Salen del grafo `Consecuencia` y `Comparticion`, junto con R06 y R17.
5. Se agregan `Usuario.rol` {ESTUDIANTE, ADMIN} y `version_contenido` en simulación e intento. Esta última permite editar una simulación sin romper los intentos que ya existen.
