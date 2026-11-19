# Matriz de propiedad de datos — QATO'K (v2)

- **Paso del plan:** 0.1 (`context/plan-trabajo.md`). Responde a las secciones 5.1 y 5.2 de la guía.
- **Estado:** PROPUESTA. Necesita la aprobación de B y C (puerta 0). Un cambio posterior se hace por PR aprobado por los 3.
- **Por qué esta matriz y no otra:** `analisis-matriz.md` compara 6 repartos y 5 mecanismos de sincronización, los ataca y deja esta como ganadora.
- **Base:** modelo del KG v1.1 (12 entidades, 17 relaciones) y consultas C-01 a C-05 del entregable A-01.

## 1. Reglas

1. **Cada dato tiene una sola base dueña.** Solo ahí se modifica oficialmente.
2. **Una entidad existe cuando existe su registro en PostgreSQL.** MongoDB guarda el *contenido* de algunas entidades. Un documento sin registro es un **huérfano**, y la reconciliación lo elimina.
3. **Todo cambio que deba llegar al grafo nace en PostgreSQL**, en la misma transacción que su evento (outbox). Hay un solo mecanismo de sincronización.
4. **Neo4j es una proyección para recorrer conexiones.** Guarda ids, relaciones y solo las propiedades que C-01 a C-05 usan para filtrar u ordenar. Es dueño de dos datos derivados: `Progreso` y `DEMUESTRA`.
5. **El contenido publicado es inmutable.** Solo se edita en BORRADOR. Por eso la estructura copiada al grafo nunca se desfasa.
6. **Una base por operación siempre que se pueda.** Solo 2 operaciones escriben en dos bases, y su peor caso es un huérfano inofensivo (§4).

## 2. Responsabilidad de cada base

| Base | Responsabilidad | Pregunta de la guía (§3) |
|---|---|---|
| **PostgreSQL** | Cuentas y roles, catálogo de habilidades, metadatos y estado de las simulaciones, intentos, respuestas, registro de evidencias, enlaces compartidos, eventos de sincronización | ¿Qué registro existe, cuál es su estado y qué operación debe mantenerse íntegra? |
| **MongoDB** | Contenido de cada simulación (documento polimórfico y anidado) y contenido de cada evidencia (instantánea autocontenida) | ¿Qué información contextual o flexible pertenece a este registro? |
| **Neo4j** | Ramificaciones entre pasos, recorridos de decisiones, conexión habilidad–simulación–progreso–evidencia, recomendaciones | ¿Cómo se conecta esta entidad con otras y qué rutas existen? |

### Prueba de suficiencia (guía §4.2)

| Si se quita… | Se pierde | Operación que lo demuestra |
|---|---|---|
| **PostgreSQL** | La atomicidad de "registrar respuesta + cerrar intento + emitir evento"; la unicidad de correo, token y secuencia; FK entre usuario, intento, simulación y habilidad; revocación y vencimiento confiables | Responder un paso (F2); compartir y revocar (F3b) |
| **MongoDB** | Guardar, leer y validar **como una unidad** un árbol cuya forma cambia según el tipo de paso. En SQL serían 5 o más tablas con columnas nulas o tablas por tipo, reensambladas en cada lectura | Cargar una simulación para jugarla (F2); ver una evidencia compartida en una sola lectura (F3b) |
| **Neo4j** | Recomendaciones (C-01), recorrido de decisiones (C-03), evidencia–habilidad–simulación (C-04) y evolución (C-05) con consultas de patrón simples. En SQL serían JOIN múltiples o CTE recursivas | Perfil de habilidades (F3a) |

## 3. Matriz por entidad

Leyenda: **●** dueña · **◐** copia parcial (solo los campos listados) · — no está.

| Entidad (KG) | PostgreSQL | MongoDB | Neo4j | Campos copiados → consulta que los usa |
|---|---|---|---|---|
| E01 Usuario | ● `usuario` (nombre, correo normalizado único, contrasena_hash, fecha_registro, estado, **rol**) | — | ◐ `id_usuario` | Ancla de C-01 a C-05. El correo **no** se copia (RF-09) |
| E02 Simulacion — metadatos | ● `simulacion` (titulo, descripcion, dificultad, duracion_estimada, estado) | — | ◐ `id_simulacion`, `titulo`, `estado` | `estado` → C-01; `titulo` → resultados de C-01, C-04 y C-05 |
| E02 Simulacion — contenido | — | ● `contenidos_simulacion` (un documento por simulación) | — | — |
| E03 Habilidad | ● `habilidad` (nombre único, descripcion, categoria, nivel_objetivo) | — | ◐ `id_habilidad`, `nombre`, `nivel_objetivo` | `nombre` → C-04 y C-05; `nivel_objetivo` → C-02 |
| R04 DESARROLLA | ● `simulacion_habilidad` (PK compuesta = RI-08; peso, nivel_esperado) | — | ◐ relación con `peso`, `nivel_esperado` | C-01, C-02, C-05 |
| E04 Paso | — | ● anidado: `pasos[]` (titulo, descripcion, orden, tipo, **contexto según el tipo**) | ◐ `id_paso`, `orden` + `CONTIENE` | Ramificación; orden en C-03 |
| E05 Opcion | — | ● anidada: `pasos[].opciones[]` (descripcion, valoracion, id_paso_siguiente) | ◐ `id_opcion` + `OFRECE`, `CONDUCE_A` | Ramificación; C-03 |
| E06 Consecuencia | — | ● anidada: `opciones[].consecuencias[]` | — **sale del grafo** | No se recorre: siempre se lee con su opción |
| E09 Retroalimentacion | — | ● anidada: `opciones[].retroalimentacion` (comentario, tipo, recomendacion) | ◐ propiedad `Respuesta.tipo_retroalimentacion` — **el nodo sale del grafo** | C-02 cuenta ACIERTO, PARCIAL y ERROR. Era un nodo 1:1 con una sola propiedad útil |
| E07 Intento | ● `intento` (id_usuario FK, id_simulacion FK, fecha_inicio, fecha_fin, estado, puntuacion) | — | ◐ `id_intento`, `estado`, `fecha_inicio`, `fecha_fin`, `puntuacion` + `REALIZA`, `TIENE` | C-02, C-03, C-05 |
| E08 Respuesta | ● `respuesta` (id_intento FK, id_paso, id_opcion, fecha_respuesta, secuencia; UNIQUE (id_intento, secuencia)) | — | ◐ `id_respuesta`, `secuencia`, `tipo_retroalimentacion` + `REGISTRA`, `CORRESPONDE_A`, `SELECCIONA` | C-02, C-03 |
| E10 Progreso | — | — | ● `nivel_actual`, `fecha_actualizacion` + `TIENE_PROGRESO`, `CORRESPONDE_A` | **Derivado**: se recalcula desde cero con los intentos COMPLETADO y DESARROLLA (fórmula: P-03) |
| E11 Evidencia — registro | ● `evidencia` (id_usuario FK, id_intento FK **UNIQUE**: una evidencia por intento, titulo, fecha_generacion, visibilidad) | — | ◐ `id_evidencia`, `titulo` + `GENERA`, `PRODUCE` | C-04 |
| E11 Evidencia — contenido | — | ● `evidencias` (instantánea del recorrido: decisiones, consecuencias, puntuación y habilidades, con forma variable) | — | — |
| R16 DEMUESTRA | — | — | ● derivada al generar la evidencia (habilidades DESARROLLA de la simulación del intento: RI-20) | C-04 |
| E12 Comparticion | ● `comparticion` (id_evidencia FK, token único, fecha_creacion, fecha_expiracion, estado, destinatario) | — | — **sale del grafo** | Dato transaccional (RI-15, RI-21) |
| *Nuevo* Evento | ● `evento_sincronizacion` (§5) | — | — | — |

### Ejemplo del documento de contenido (por qué es documental)

```json
{
  "_id": "<id_simulacion>",
  "pasos": [
    { "id_paso": "…", "orden": 1, "tipo": "CORREO", "titulo": "…",
      "contexto": { "remitente": "cliente@…", "asunto": "Retraso del pedido", "cuerpo": "…" },
      "opciones": [
        { "id_opcion": "…", "descripcion": "…", "valoracion": 90, "id_paso_siguiente": "…",
          "consecuencias": [ { "descripcion": "…", "impacto": "POSITIVO", "tipo": "RELACIONAL" } ],
          "retroalimentacion": { "tipo": "ACIERTO", "comentario": "…", "recomendacion": "…" } } ] },
    { "id_paso": "…", "orden": 2, "tipo": "REUNION",
      "contexto": { "participantes": ["Jefa de proyecto", "Cliente"], "agenda": ["…"] }, "opciones": [ … ] }
  ]
}
```

Cada `tipo` de paso tiene un `contexto` distinto (CORREO: remitente, asunto y cuerpo; REUNION: participantes y agenda; CONVERSACION: líneas de diálogo; TAREA: entregables y plazo; INCIDENTE: cronología). El validador `$jsonSchema` impone la forma de cada uno.

### Cambios al modelo de grafo actual (los aplica A en la fase 1)
- Salen `Consecuencia`, `Retroalimentacion` y `Comparticion`, junto con R06, R11 y R17. Quedan **9 etiquetas y 14 patrones de relación**.
- Los nodos pierden las propiedades de texto.
- Se quita la restricción de unicidad de `Usuario.correo` en Neo4j.
- C-02 lee `Respuesta.tipo_retroalimentacion`.
- C-03 y C-04 pasan a ser consultas que el servicio completa con otras bases.
- La búsqueda por texto (RF-02, antes la prueba D7 del grafo) se hace en PostgreSQL.

## 4. Operaciones y en qué base escriben

| Operación (flujo, dueño) | Escribe en | Si algo falla | La API responde |
|---|---|---|---|
| Registrarse (F1, B) | PG `usuario` + evento `USUARIO_CREADO` | La transacción revierte | `201` + `sincronizacion` |
| Eliminar cuenta (F1, B) | PG (borrado en cascada) + evento `USUARIO_ELIMINADO` → después, Mongo borra sus `evidencias` | Si falla Mongo: evidencias huérfanas, las limpia la reconciliación | `204` |
| Crear, editar o eliminar habilidad (F1, admin, B) | PG + evento `HABILIDAD_GUARDADA` / `HABILIDAD_ELIMINADA` (solo si ninguna simulación la usa: FK RESTRICT) | Revierte | `201` / `200` / `204` / `409` |
| Crear simulación (F1, B) | **Solo PG** (`simulacion` en BORRADOR + `simulacion_habilidad`) | Revierte | `201` |
| Cargar o editar contenido (F1, B) | **Solo Mongo** (reemplaza el documento). Antes verifica en PG que exista y esté en BORRADOR | Nada que compensar | `200` / `409` si está publicada |
| Publicar (F1, B) | Lee el contenido de Mongo y valida RI-17 y RI-11 → **solo PG**: estado PUBLICADA + evento `SIMULACION_PUBLICADA` con la estructura | Revierte | `200` + `sincronizacion` |
| Desactivar (F1, B) | PG estado INACTIVA + evento `SIMULACION_ESTADO_CAMBIADO` | Revierte | `200` |
| Eliminar BORRADOR (F1, B) | PG delete → Mongo delete (**2 bases**) | Si falla Mongo: huérfano, lo limpia la reconciliación | `204` |
| Iniciar intento (F2, C) | PG `intento` (RI-19) + evento `INTENTO_INICIADO` | Revierte | `201` |
| **Responder un paso** (F2, C) | Lee el contenido de Mongo y valida RI-10 → **solo PG**, en una transacción: `respuesta` (RI-16, RI-22) + cerrar el intento si la opción es terminal (RI-23, puntuación calculada) + eventos `RESPUESTA_REGISTRADA` (y `INTENTO_FINALIZADO`) | Revierte | `201` con consecuencias y retroalimentación (leídas del contenido) + `sincronizacion` |
| Abandonar intento (F2, C) | PG + evento `INTENTO_FINALIZADO` | Revierte | `200` |
| Generar evidencia (F3a, A) | 1) Mongo `evidencias` → 2) PG `evidencia` + evento `EVIDENCIA_GENERADA` (**2 bases**) | Si falla PG: se borra el documento (compensación). Si eso también falla, la reconciliación lo limpia | `201` + `sincronizacion` |
| Cambiar visibilidad o eliminar evidencia (F3a, A) | PG (+ Mongo delete si se elimina) | Igual que eliminar BORRADOR | `200` / `204` |
| Compartir y revocar (F3b, B) | Solo PG | Revierte | `201` / `204` |
| Ver evidencia compartida (F3b, B) | Lectura: PG valida token, estado y vencimiento → Mongo da el contenido | Mongo caído → `503` con el formato de error | `200` / `404` / `410` |

**Honestidad de la respuesta (guía §9).** Toda operación que genera eventos devuelve

```json
"sincronizacion": { "grafo": "APLICADO" | "PENDIENTE", "eventos": ["<id_evento>"] }
```

La API nunca afirma que el grafo está al día si el evento no se aplicó.

## 5. Sincronización hacia Neo4j (dueño: A; tabla: B)

**Mecanismo:** outbox transaccional con **aplicación inmediata** y reintento.
1. El servicio escribe el cambio y su evento en la misma transacción de PostgreSQL.
2. Tras el commit, el servicio intenta aplicar el evento en Neo4j de inmediato. Si lo logra, lo marca `APLICADO`.
3. Si no lo logra, queda `PENDIENTE`. Un proceso dentro del backend reintenta cada pocos segundos, tomando los eventos con `FOR UPDATE SKIP LOCKED` en orden de `creado_en`. Hace hasta 5 intentos con espera creciente y después lo marca `FALLIDO`.
4. Todo efecto en el grafo es un `MERGE` por id: **aplicar dos veces da lo mismo**. El progreso se recalcula desde cero, nunca se incrementa.

```sql
CREATE TABLE evento_sincronizacion (
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
CREATE INDEX ix_eventos_pendientes ON evento_sincronizacion (estado, creado_en);
```

| Evento | Lo emite | Efecto en Neo4j |
|---|---|---|
| `USUARIO_CREADO` | F1 | MERGE `Usuario` |
| `USUARIO_ELIMINADO` | F1 | DETACH DELETE del usuario y de sus intentos, respuestas, progresos y evidencias |
| `HABILIDAD_GUARDADA` | F1 | MERGE `Habilidad` (nombre, nivel_objetivo) |
| `HABILIDAD_ELIMINADA` | F1 | DETACH DELETE `Habilidad` |
| `SIMULACION_PUBLICADA` | F1 | MERGE `Simulacion`, `Paso`, `Opcion`, `CONTIENE`, `OFRECE`, `CONDUCE_A`, `DESARROLLA` |
| `SIMULACION_ESTADO_CAMBIADO` | F1 | SET `estado` |
| `INTENTO_INICIADO` | F2 | MERGE `Intento` + `REALIZA` + `TIENE` |
| `RESPUESTA_REGISTRADA` | F2 | MERGE `Respuesta` (secuencia, tipo_retroalimentacion) + `REGISTRA`, `CORRESPONDE_A`, `SELECCIONA` |
| `INTENTO_FINALIZADO` | F2 | SET estado, fecha_fin, puntuacion; **recalcula `Progreso`** del usuario en las habilidades de la simulación |
| `EVIDENCIA_GENERADA` | F3a | MERGE `Evidencia` + `GENERA` + `PRODUCE` + `DEMUESTRA` |
| `EVIDENCIA_ELIMINADA` | F3a | DETACH DELETE `Evidencia` |

## 6. Reconciliación y reconstrucción (dueño: A)

`npm run reconciliar` reporta lo que encuentra y lo que repara:

| Revisión | Detecta | Repara |
|---|---|---|
| PG ↔ Neo4j por etiqueta | Ids que faltan o sobran en el grafo | Reemite el evento / borra el nodo |
| Eventos `FALLIDO` | Eventos sin aplicar | Los reintenta; reporta los que siguen fallando |
| Mongo ↔ PG | Contenidos y evidencias sin registro en PG con más de 10 minutos | Los borra |
| Referencias entre bases | Respuestas cuyo paso u opción no existe en el contenido; simulaciones PUBLICADA sin contenido | Solo reporta (indica un error de programación) |
| Progreso | `nivel_actual` distinto del recálculo | Lo recalcula |

`npm run grafo:reconstruir` es el último recurso: vacía el grafo y lo reconstruye desde PostgreSQL y MongoDB.

La reconciliación es la evidencia de las pruebas de **consistencia** y **errores** de la guía (§9).

## 7. Decisiones que se registran como DEC-24 (paso 0.10)

1. MongoDB se adopta como base documental (D-10 → SUPERSEDED).
2. PostgreSQL es dueño de cuentas, estados y transacciones (resuelve P-01).
3. Sincronización: outbox con aplicación inmediata, reintento idempotente, reconciliación y reconstrucción (resuelve P-02).
4. Salen del grafo `Consecuencia`, `Retroalimentacion` y `Comparticion` (R06, R11, R17); la retroalimentación pasa a ser propiedad de `Respuesta`.
5. El contenido publicado es inmutable; solo se edita en BORRADOR.
6. Se agrega `Usuario.rol` {ESTUDIANTE, ADMIN} y un `contexto` polimórfico por `Paso.tipo` (avanza P-09).
