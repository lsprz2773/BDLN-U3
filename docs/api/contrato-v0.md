# Contrato de la API v0 — QATO'K

- **Paso del plan:** 0.3. **Estado:** PROPUESTA, pendiente de aprobación de B y C (puerta 0). Forma parte de E6 ("documentación del contrato de API").
- **Se apoya en:** `context/convenciones.md` §5 (prefijo `/api`, `snake_case`, formato de error, códigos HTTP) y `docs/modelos/matriz-propiedad.md` §4 (en qué bases escribe cada operación).
- **Del contrato al código:** en el paso 0.7 estas formas se escriben como esquemas zod en `shared/`, y de ahí se genera el OpenAPI (`/api/docs`). Si el código y este documento difieren, se corrige el que esté mal mediante un PR.
- **Para que la interfaz avance sin backend:** C puede simular cualquier endpoint con los ejemplos de este documento.

## 1. Acceso

| Nivel | Quién |
|---|---|
| **Público** | Sin token |
| **Usuario** | Cualquier token válido (`ESTUDIANTE` o `ADMIN`) |
| **Dueño** | El recurso pertenece al `id_usuario` del token. Si no es suyo → `404` (no se revela que existe) |
| **Admin** | Token con `rol = ADMIN` |

## 2. Objetos que se repiten

```jsonc
// Usuario
{ "id_usuario": "uuid", "nombre": "Ana López", "correo": "ana@correo.com",
  "rol": "ESTUDIANTE", "estado": "ACTIVO", "fecha_registro": "2026-11-18T21:30:00.000Z" }

// Habilidad
{ "id_habilidad": "uuid", "nombre": "Comunicación efectiva", "descripcion": "…",
  "categoria": "Blanda", "nivel_objetivo": 70 }

// SimulacionResumen (catálogo)
{ "id_simulacion": "uuid", "titulo": "Cliente molesto por un retraso", "descripcion": "…",
  "dificultad": "INTERMEDIA", "duracion_estimada": 10, "estado": "PUBLICADA",
  "habilidades": [ { "id_habilidad": "uuid", "nombre": "…", "peso": 0.6, "nivel_esperado": 70 } ] }

// PasoVista: lo que ve quien juega. NO incluye valoración, consecuencias ni retroalimentación
{ "id_paso": "uuid", "orden": 1, "tipo": "CORREO", "titulo": "…", "descripcion": "…",
  "contexto": { "remitente": "…", "asunto": "…", "cuerpo": "…" },
  "opciones": [ { "id_opcion": "uuid", "descripcion": "…" } ] }

// Intento
{ "id_intento": "uuid", "id_simulacion": "uuid", "estado": "EN_CURSO",
  "fecha_inicio": "…", "fecha_fin": null, "puntuacion": null }

// Sincronizacion (solo en operaciones que generan eventos)
{ "grafo": "APLICADO", "eventos": ["uuid"] }
```

`ContenidoSimulacion` (solo para admin) es el documento completo de la matriz §3: `pasos[]` con `contexto`, `opciones[]`, `valoracion`, `id_paso_siguiente`, `consecuencias[]` y `retroalimentacion`.

## 3. Endpoints

Columnas: **Bases** = PG / Mongo / Neo4j que toca (L = lectura, E = escritura, *ev* = evento hacia el grafo).

### Salud — dueño A

| Método y ruta | Acceso | Bases | Respuesta | Errores |
|---|---|---|---|---|
| `GET /api/health` | Público | L en las 3 | `200` si las 3 responden; `503` con el mismo cuerpo si alguna falla | — |

```json
{ "estado": "OK", "version": "0.1.0",
  "bases": { "relacional": { "ok": true, "latencia_ms": 3 },
             "documental": { "ok": true, "latencia_ms": 2 },
             "grafo":      { "ok": true, "latencia_ms": 5 } } }
```

`estado` vale `"DEGRADADO"` si alguna base tiene `ok: false`. En ese caso, la base que falla incluye `"error": "SIN_CONEXION" | "TIEMPO_AGOTADO"`; el detalle técnico solo va al log. Este endpoint es la base de la **prueba de conectividad**. Implementado en el paso 0.7: es la plantilla de capas que copian los demás endpoints.

### F1 Cuenta — dueño B (RF-01, RF-09)

| Método y ruta | Acceso | Bases | Entrada | Respuesta | Errores |
|---|---|---|---|---|---|
| `POST /api/auth/registro` | Público | PG E + *ev* | `{ nombre (1–100), correo (email, ≤150), contrasena (8–72) }` | `201 { usuario, token, sincronizacion }` | `400 VALIDACION`, `409 CORREO_DUPLICADO` |
| `POST /api/auth/login` | Público | PG L | `{ correo, contrasena }` | `200 { usuario, token }` | `401 CREDENCIALES_INVALIDAS`, `403 CUENTA_INACTIVA` |
| `GET /api/me` | Usuario | PG L | — | `200 Usuario` | `401` |
| `PATCH /api/me` | Usuario | PG E | `{ nombre? }` | `200 Usuario` | `400` |
| `DELETE /api/me` | Usuario | PG E + *ev* → Mongo E | — | `200 { eliminado: true, sincronizacion }` | `401` |

### F1 Habilidades — dueño B

| Método y ruta | Acceso | Bases | Entrada | Respuesta | Errores |
|---|---|---|---|---|---|
| `GET /api/habilidades` | Usuario | PG L | — | `200 { datos: Habilidad[], total }` | — |
| `POST /api/admin/habilidades` | Admin | PG E + *ev* | `{ nombre, descripcion, categoria, nivel_objetivo? }` | `201 { habilidad, sincronizacion }` | `400`, `409 HABILIDAD_DUPLICADA` |
| `PUT /api/admin/habilidades/:id_habilidad` | Admin | PG E + *ev* | igual que `POST` | `200 { habilidad, sincronizacion }` | `404`, `409 HABILIDAD_DUPLICADA` |
| `DELETE /api/admin/habilidades/:id_habilidad` | Admin | PG E + *ev* | — | `200 { eliminado: true, sincronizacion }` | `404`, `409 HABILIDAD_EN_USO` |

### F1 Catálogo — dueño B (RF-02)

| Método y ruta | Acceso | Bases | Entrada | Respuesta | Errores |
|---|---|---|---|---|---|
| `GET /api/simulaciones` | Usuario | PG L | Query: `texto?`, `id_habilidad?`, `dificultad?`, `limite?`, `desplazamiento?` | `200 { datos: SimulacionResumen[], total }`, solo PUBLICADA | `400` |
| `GET /api/simulaciones/:id_simulacion` | Usuario | PG L | — | `200 SimulacionResumen` | `404` si no existe o no está PUBLICADA |

### F1 Administración de simulaciones — dueño B

| Método y ruta | Acceso | Bases | Entrada | Respuesta | Errores |
|---|---|---|---|---|---|
| `GET /api/admin/simulaciones` | Admin | PG L | Query: `estado?`, paginación | `200 { datos: SimulacionResumen[], total }` | — |
| `POST /api/admin/simulaciones` | Admin | PG E | `{ titulo, descripcion, dificultad, duracion_estimada?, habilidades: [{ id_habilidad, peso, nivel_esperado }] (≥1, sin repetir: RI-08) }` | `201 SimulacionResumen` (BORRADOR) | `400`, `404 HABILIDAD_NO_ENCONTRADA` |
| `PUT /api/admin/simulaciones/:id` | Admin | PG E | igual que `POST` | `200 SimulacionResumen` | `404`, `409 SIMULACION_NO_EDITABLE` |
| `GET /api/admin/simulaciones/:id/contenido` | Admin | Mongo L | — | `200 ContenidoSimulacion` | `404 SIN_CONTENIDO` |
| `PUT /api/admin/simulaciones/:id/contenido` | Admin | PG L → Mongo E | `ContenidoSimulacion` (ids generados por la interfaz o por el backend si faltan) | `200 ContenidoSimulacion` | `400 VALIDACION` (forma del `contexto` por tipo), `404`, `409 SIMULACION_NO_EDITABLE` |
| `POST /api/admin/simulaciones/:id/publicar` | Admin | Mongo L → PG E + *ev* | — | `200 { simulacion, sincronizacion }` | `404`, `409 SIN_CONTENIDO`, `409 CONTENIDO_INCOMPLETO` (RI-17, RI-18), `409 RAMIFICACION_INVALIDA` (RI-11), `409 SIMULACION_NO_EDITABLE` |
| `POST /api/admin/simulaciones/:id/desactivar` | Admin | PG E + *ev* | — | `200 { simulacion, sincronizacion }` | `404`, `409 SIMULACION_NO_PUBLICADA` |
| `DELETE /api/admin/simulaciones/:id` | Admin | PG E → Mongo E | — | `204` | `404`, `409 SIMULACION_PUBLICADA` (solo se elimina un BORRADOR) |

### F2 Jugar una simulación — dueño C (RF-03, RF-04, RF-05)

| Método y ruta | Acceso | Bases | Entrada | Respuesta | Errores |
|---|---|---|---|---|---|
| `POST /api/intentos` | Usuario | PG L, Mongo L → PG E + *ev* | `{ id_simulacion }` | `201 { intento, paso_actual: PasoVista, sincronizacion }` | `404`, `409 SIMULACION_NO_PUBLICADA` (RI-19), `409 INTENTO_EN_CURSO_EXISTENTE` (`detalles.id_intento`, para retomarlo) |
| `GET /api/intentos` | Usuario | PG L | Query: `estado?`, paginación | `200 { datos: Intento[], total }`, solo los propios | — |
| `GET /api/intentos/:id_intento` | Dueño | PG L, Mongo L | — | `200 { intento, paso_actual: PasoVista \| null, respuestas: [{ secuencia, id_paso, id_opcion, fecha_respuesta }] }` | `404` |
| `POST /api/intentos/:id_intento/respuestas` | Dueño | Mongo L → PG E + *ev* | `{ id_paso, id_opcion }` | `201` (abajo) | `404`, `409 INTENTO_NO_EN_CURSO` (RI-22), `409 PASO_NO_ACTUAL`, `400 OPCION_NO_PERTENECE_AL_PASO` (RI-10), `503 BASE_NO_DISPONIBLE` (sin Mongo no se puede validar) |
| `POST /api/intentos/:id_intento/abandonar` | Dueño | PG E + *ev* | — | `200 { intento, sincronizacion }` | `404`, `409 INTENTO_NO_EN_CURSO` |

Respuesta de `POST …/respuestas`:

```json
{
  "respuesta": { "id_respuesta": "uuid", "secuencia": 2, "fecha_respuesta": "…" },
  "consecuencias": [ { "descripcion": "El cliente acepta la nueva fecha", "impacto": "POSITIVO", "tipo": "RELACIONAL" } ],
  "retroalimentacion": { "tipo": "ACIERTO", "comentario": "…", "recomendacion": "…" },
  "siguiente_paso": null,
  "intento": { "id_intento": "uuid", "estado": "COMPLETADO", "fecha_fin": "…", "puntuacion": 78.5 },
  "sincronizacion": { "grafo": "APLICADO", "eventos": ["uuid", "uuid"] }
}
```

- **Paso actual:** el de `orden = 1` si no hay respuestas; después, el `id_paso_siguiente` de la última opción elegida. Una opción sin siguiente es **terminal**: completa el intento (RI-23).
- **Puntuación** (*propuesta* mientras P-03 siga abierta): el promedio de la `valoracion` de las opciones elegidas, entre 0 y 100.

### F3a Perfil y evidencias — dueño A (RF-06, RF-07, RF-08)

| Método y ruta | Acceso | Bases | Entrada | Respuesta | Errores |
|---|---|---|---|---|---|
| `GET /api/perfil` | Usuario | **PG L + Neo4j L + Mongo L** | — | `200` (abajo): **el flujo integrado** | `503` si falta PG; si falta Neo4j o Mongo responde con `datos_incompletos` |
| `GET /api/perfil/habilidades` | Usuario | Neo4j L | — | `200 { datos: HabilidadPerfil[] }` (C-02) | — |
| `GET /api/perfil/recomendaciones` | Usuario | Neo4j L | `limite?` | `200 { datos: [{ simulacion: SimulacionResumen, habilidades_a_reforzar: [nombre] }] }` (C-01) | — |
| `GET /api/perfil/habilidades/:id_habilidad/evolucion` | Usuario | Neo4j L | — | `200 { nivel_actual, puntos: [{ fecha, id_simulacion, titulo, puntuacion }] }` (C-05) | `404` |
| `GET /api/perfil/intentos/:id_intento/recorrido` | Dueño | Neo4j L + Mongo L | — | `200 { intento, decisiones: [{ secuencia, paso: { titulo, tipo }, opcion: { descripcion }, consecuencias[], retroalimentacion }] }` (C-03) | `404` |
| `POST /api/evidencias` | Usuario | Mongo E → PG E + *ev* | `{ id_intento, titulo? }` | `201 { evidencia, sincronizacion }` | `404` (no es suyo: RI-14), `409 INTENTO_NO_COMPLETADO` (RI-25), `409 EVIDENCIA_EXISTENTE` (una por intento) |
| `GET /api/evidencias` | Usuario | PG L (+ Neo4j L si hay filtro) | Query: `id_habilidad?` (C-04), paginación | `200 { datos: [{ id_evidencia, titulo, visibilidad, fecha_generacion, simulacion: { id_simulacion, titulo }, habilidades: [nombre], comparticiones_activas: n }], total }` | — |
| `GET /api/evidencias/:id_evidencia` | Dueño | PG L + Mongo L | — | `200 { evidencia, contenido }` | `404` |
| `PATCH /api/evidencias/:id_evidencia` | Dueño | PG E | `{ titulo?, visibilidad? }` | `200 evidencia` | `400`, `404` |
| `DELETE /api/evidencias/:id_evidencia` | Dueño | PG E + *ev* → Mongo E | — | `200 { eliminado: true, sincronizacion }` | `404` |

Respuesta de `GET /api/perfil`:

```json
{
  "usuario": { "id_usuario": "uuid", "nombre": "Ana López" },
  "resumen": { "intentos_completados": 3, "evidencias": 1 },
  "habilidades": [
    { "id_habilidad": "uuid", "nombre": "Comunicación efectiva", "nivel_actual": 75, "objetivo": 70,
      "clasificacion": "FORTALEZA", "aciertos": 2, "parciales": 1, "errores": 0 } ],
  "recomendaciones": [ { "id_simulacion": "uuid", "titulo": "Tres entregas para mañana", "habilidades_a_reforzar": ["Gestión del tiempo"] } ],
  "evidencias_recientes": [ { "id_evidencia": "uuid", "titulo": "Manejo de un cliente molesto" } ],
  "datos_incompletos": [],
  "sincronizacion_pendiente": 0
}
```

- `usuario` y `resumen` salen de PostgreSQL; `habilidades` y `recomendaciones`, de Neo4j; los títulos y textos, de Mongo cuando hace falta.
- `datos_incompletos` lista las bases que no respondieron (p. ej. `["grafo"]`). Las secciones de esas bases vienen vacías, en lugar de fallar toda la página.
- `sincronizacion_pendiente` = eventos del usuario que aún no llegan al grafo. Si es mayor que 0, la interfaz avisa que el progreso se está actualizando.

### F3b Compartir evidencias — dueño B (RF-09)

| Método y ruta | Acceso | Bases | Entrada | Respuesta | Errores |
|---|---|---|---|---|---|
| `POST /api/evidencias/:id_evidencia/comparticiones` | Dueño | PG E | `{ dias_vigencia? (1–90, por defecto 30), destinatario? (≤150) }` | `201 { id_comparticion, token, url_publica, fecha_expiracion, estado }` | `400`, `404` |
| `GET /api/evidencias/:id_evidencia/comparticiones` | Dueño | PG L | — | `200 { datos: [ … ], total }` (cada una con `vigente: true/false`) | `404` |
| `DELETE /api/comparticiones/:id_comparticion` | Dueño de la evidencia | PG E | — | `204` (pasa a REVOCADA; no se borra) | `404` |
| `GET /api/publico/evidencias/:token` | **Público** | PG L → Mongo L | — | `200 { titulo, fecha_generacion, titular: { nombre }, contenido }` | `404 ENLACE_INVALIDO` (no existe o fue revocado), `410 ENLACE_VENCIDO`, `503 BASE_NO_DISPONIBLE` |

- **Token:** 32 bytes aleatorios en base64url, generados en el backend; único (RI-15).
- **Visibilidad:** en v0 solo el token da acceso público, sin importar `visibilidad`. Para qué sirve `PUBLICA` queda abierto (P-06).

## 4. Rutas por archivo (para no chocar en merges)

| Archivo en `backend/src/routes/` | Rutas | Dueño |
|---|---|---|
| `health.routes.ts` | `/api/health` | A |
| `auth.routes.ts` | `/api/auth/*`, `/api/me` | B |
| `habilidades.routes.ts` | `/api/habilidades`, `/api/admin/habilidades/*` | B |
| `simulaciones.routes.ts` | `/api/simulaciones/*`, `/api/admin/simulaciones/*` | B |
| `intentos.routes.ts` | `/api/intentos/*` | C |
| `perfil.routes.ts` | `/api/perfil/*` | A |
| `evidencias.routes.ts` | `/api/evidencias` (GET lista y detalle, POST, PATCH, DELETE) | A |
| `comparticiones.routes.ts` | `/api/evidencias/:id/comparticiones`, `/api/comparticiones/*`, `/api/publico/*` | B |

## 5. Cobertura

| Requisito | Endpoints |
|---|---|
| Altas, cambios, consultas y bajas por base (nota de la guía) | PG: usuario, habilidad, simulación, intento, comparticion · Mongo: contenido (`PUT`/`GET`/`DELETE`), evidencia · Neo4j: lecturas C-01 a C-05 y escrituras por eventos |
| Flujo integrado (guía §8.1) | `GET /api/perfil` |
| Escritura en varias bases con fallo parcial (guía §9) | `POST /api/evidencias`, `DELETE /api/admin/simulaciones/:id`, `DELETE /api/me` |
| Consistencia (guía §9) | Todo lo que devuelve `sincronizacion` + `GET /api/perfil` (`sincronizacion_pendiente`) |
| RF-01 a RF-09 | Todos cubiertos. RF-10 (móvil, sesiones cortas) se cubre en la interfaz: retomar un intento con `409 INTENTO_EN_CURSO_EXISTENTE` + `GET /api/intentos/:id` |
