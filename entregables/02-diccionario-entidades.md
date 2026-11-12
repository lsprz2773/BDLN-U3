# Entregable 2. Diccionario de entidades y propiedades

**Proyecto:** QATO'K · **Fuente:** KG v1.1 · **Base de datos principal:** Neo4j (modelo de grafo de propiedades)

## Convenciones

- **Entidad = etiqueta de nodo en Neo4j.** Las 12 entidades del dominio se representan como nodos con la etiqueta del mismo nombre.
- **Claves foráneas.** En el modelo relacional original algunas entidades tenían claves foráneas (`id_…`). En Neo4j esas referencias **no se guardan como propiedades**: se representan con relaciones. Por eso las tablas solo listan las propiedades almacenadas en el nodo, y cada entidad indica qué relación sustituye a cada clave foránea.
- **Identificadores.** Cada nodo guarda su UUID como propiedad (`id_…`). No se usa el identificador interno de Neo4j (`elementId`), porque Neo4j puede reutilizarlo después de borrar un nodo y no sirve como referencia estable hacia otros sistemas, como PostgreSQL.
- **Tipo de dato.** Se indica el tipo lógico (notación SQL del KG) y su tipo en Neo4j: UUID → String · VARCHAR/TEXT → String · INTEGER → Integer · DECIMAL → Float · TIMESTAMP → DateTime.
- **Obligatoria.** "Sí" si la propiedad no admite valor nulo (RI-04). Algunas son obligatorias solo bajo una condición, que se indica.
- **Única.** "Sí" si el valor no puede repetirse en ningún otro nodo con la misma etiqueta. Si la unicidad es solo dentro de un grupo (por ejemplo, dentro de una simulación), se indica "No" con la aclaración.
- *Propuesta*: valor o rango que depende de una decisión pendiente (P-xx) y puede cambiar.
- La distribución de entidades entre Neo4j y PostgreSQL está pendiente (P-01). Este diccionario describe el modelo lógico, sin importar dónde se almacene cada dato.

## Entidades

### E01 — Usuario
Persona que utiliza la plataforma para practicar y desarrollar habilidades profesionales.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_usuario | UUID | String | Sí | Sí | Identificador del usuario (RI-01). |
| nombre | VARCHAR(100) | String | Sí | No | Nombre del usuario. |
| correo | VARCHAR(150) | String | Sí | Sí | Correo electrónico. Se guarda normalizado (en minúsculas y sin espacios al inicio o al final) para que la unicidad no distinga mayúsculas (RI-02). |
| contrasena_hash | VARCHAR(255) | String | Sí | No | Hash de la contraseña; nunca se guarda la contraseña en claro. Su ubicación en Neo4j o PostgreSQL depende de P-01 y P-10. |
| fecha_registro | TIMESTAMP | DateTime | Sí | No | Fecha y hora de registro. |
| estado | VARCHAR(20) | String | Sí | No | Estado de la cuenta. Valores (*propuesta*): ACTIVO, INACTIVO, SUSPENDIDO. |

**Claves foráneas:** no tiene. Es el origen de las relaciones REALIZA (R01), TIENE_PROGRESO (R12) y GENERA hacia Evidencia (R14).

### E02 — Simulacion
Experiencia interactiva que representa una situación profesional.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_simulacion | UUID | String | Sí | Sí | Identificador de la simulación (RI-01). |
| titulo | VARCHAR(150) | String | Sí | No | Título visible de la simulación. |
| descripcion | TEXT | String | Sí | No | Contexto y objetivo de la situación profesional. |
| dificultad | VARCHAR(30) | String | Sí | No | Valores: BASICA, INTERMEDIA, AVANZADA (RI-05). |
| duracion_estimada | INTEGER | Integer | No | No | Duración estimada en minutos (unidad *propuesta*); mayor que 0 (RI-24, *propuesta*). Permite elegir sesiones cortas (RF-10). |
| estado | VARCHAR(20) | String | Sí | No | Valores: BORRADOR, PUBLICADA, INACTIVA (RI-05). Solo las PUBLICADAS admiten intentos (RI-19). |

**Claves foráneas:** no tiene. Es el origen de TIENE (R02), CONTIENE (R03) y DESARROLLA (R04).

### E03 — Habilidad
Competencia profesional que puede desarrollarse o demostrarse mediante simulaciones.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_habilidad | UUID | String | Sí | Sí | Identificador de la habilidad (RI-01). |
| nombre | VARCHAR(100) | String | Sí | Sí | Nombre de la habilidad; no se admiten duplicados (RI-03). |
| descripcion | TEXT | String | Sí | No | Qué comprende la competencia. |
| categoria | VARCHAR(50) | String | Sí | No | Agrupación de la habilidad. Su catálogo está pendiente (P-08). |
| nivel_objetivo | INTEGER | Integer | No | No | Nivel recomendado a alcanzar, en la escala 0–100 de `Progreso.nivel_actual` (*propuesta*). |

**Claves foráneas:** no tiene. Es destino de DESARROLLA (R04), CORRESPONDE_A desde Progreso (R13) y DEMUESTRA (R16).

### E04 — Paso
Situación o etapa que forma parte de una simulación.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_paso | UUID | String | Sí | Sí | Identificador del paso (RI-01). |
| titulo | VARCHAR(150) | String | Sí | No | Título de la situación. |
| descripcion | TEXT | String | Sí | No | Situación laboral que se presenta al usuario. |
| orden | INTEGER | Integer | Sí | No (única dentro de su simulación, RI-18) | Orden de autoría, mayor que 0. El paso con `orden = 1` es el paso inicial. |
| tipo | VARCHAR(30) | String | Sí | No | Tipo de situación laboral. Valores (*propuesta*): CORREO, REUNION, CONVERSACION, TAREA, INCIDENTE. |

**Claves foráneas sustituidas por relaciones:** `id_simulacion` → `(Simulacion)-[:CONTIENE]->(Paso)` (R03).

### E05 — Opcion
Alternativa de decisión disponible para el usuario en un paso.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_opcion | UUID | String | Sí | Sí | Identificador de la opción (RI-01). |
| descripcion | TEXT | String | Sí | No | Decisión que puede tomar el usuario. |
| valoracion | DECIMAL(5,2) | Float | No | No | Valoración de la calidad de la decisión. Su escala y su uso en el cálculo de niveles dependen de P-03. |

**Claves foráneas sustituidas por relaciones:** `id_paso` → `(Paso)-[:OFRECE]->(Opcion)` (R05). `id_paso_siguiente` → `(Opcion)-[:CONDUCE_A]->(Paso)` (R07). Si la opción no tiene CONDUCE_A, es una **opción terminal** y finaliza el intento (RI-23).

### E06 — Consecuencia
Resultado asociado a una opción de decisión.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_consecuencia | UUID | String | Sí | Sí | Identificador de la consecuencia (RI-01). |
| descripcion | TEXT | String | Sí | No | Qué ocurre como resultado de la decisión. |
| impacto | VARCHAR(30) | String | Sí | No | Valencia del resultado. Valores (*propuesta*): POSITIVO, NEUTRO, NEGATIVO. |
| tipo | VARCHAR(30) | String | Sí | No | Área afectada. Valores (*propuesta*): RELACIONAL, TIEMPO, CALIDAD, REPUTACION. |

**Claves foráneas sustituidas por relaciones:** `id_opcion` → `(Opcion)-[:GENERA]->(Consecuencia)` (R06).

### E07 — Intento
Ejecución de una simulación por parte de un usuario.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_intento | UUID | String | Sí | Sí | Identificador del intento (RI-01). |
| fecha_inicio | TIMESTAMP | DateTime | Sí | No | Inicio del intento. |
| fecha_fin | TIMESTAMP | DateTime | No (obligatoria si el estado es COMPLETADO, RI-12) | No | Fin del intento; no puede ser anterior a `fecha_inicio` (RI-12). |
| estado | VARCHAR(20) | String | Sí | No | Valores: EN_CURSO, COMPLETADO, ABANDONADO (RI-06). |
| puntuacion | DECIMAL(5,2) | Float | No | No | Resultado global del intento, entre 0 y 100 (RI-06). |

**Claves foráneas sustituidas por relaciones:** `id_usuario` → `(Usuario)-[:REALIZA]->(Intento)` (R01). `id_simulacion` → `(Simulacion)-[:TIENE]->(Intento)` (R02).

### E08 — Respuesta
Registro de una opción seleccionada por el usuario durante un intento.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_respuesta | UUID | String | Sí | Sí | Identificador de la respuesta (RI-01). |
| fecha_respuesta | TIMESTAMP | DateTime | Sí | No | Momento de la decisión; dentro de las fechas del intento (RI-22). |
| secuencia | INTEGER | Integer | Sí | No (única dentro de su intento, RI-16) | Posición de la respuesta en el recorrido del intento (1, 2, 3…). Ordena las decisiones aunque se sincronicen con retraso, y permite reanudar el intento. |

**Claves foráneas sustituidas por relaciones:** `id_intento` → `(Intento)-[:REGISTRA]->(Respuesta)` (R08). `id_paso` → `(Respuesta)-[:CORRESPONDE_A]->(Paso)` (R09). `id_opcion` → `(Respuesta)-[:SELECCIONA]->(Opcion)` (R10).

### E09 — Retroalimentacion
Explicación del desempeño del usuario y recomendaciones de mejora.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_retroalimentacion | UUID | String | Sí | Sí | Identificador de la retroalimentación (RI-01). |
| comentario | TEXT | String | Sí | No | Explicación de por qué la decisión fue acertada o no. |
| tipo | VARCHAR(30) | String | Sí | No | Clasificación de la decisión. Valores (*propuesta*): ACIERTO, PARCIAL, ERROR. |
| recomendacion | TEXT | String | Sí | No | Acción de mejora sugerida al usuario. |

**Claves foráneas sustituidas por relaciones:** `id_respuesta` → `(Respuesta)-[:GENERA]->(Retroalimentacion)` (R11).

### E10 — Progreso
Registro del nivel de desarrollo de una habilidad para un usuario.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_progreso | UUID | String | Sí | Sí | Identificador del progreso (RI-01). |
| nivel_actual | DECIMAL(5,2) | Float | Sí | No | Nivel consolidado de la habilidad, entre 0 y 100 (RI-07). |
| fecha_actualizacion | TIMESTAMP | DateTime | Sí | No | Última vez que se recalculó el nivel. |

**Claves foráneas sustituidas por relaciones:** `id_usuario` → `(Usuario)-[:TIENE_PROGRESO]->(Progreso)` (R12). `id_habilidad` → `(Progreso)-[:CORRESPONDE_A]->(Habilidad)` (R13). Solo puede existir un progreso por cada par usuario–habilidad (RI-13).

### E11 — Evidencia
Registro que representa una habilidad demostrada durante una experiencia de simulación.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_evidencia | UUID | String | Sí | Sí | Identificador de la evidencia (RI-01). |
| titulo | VARCHAR(150) | String | Sí | No | Título de la evidencia. |
| descripcion | TEXT | String | Sí | No | Qué demostró el usuario y en qué contexto. |
| fecha_generacion | TIMESTAMP | DateTime | Sí | No | Momento en que se generó la evidencia. |
| visibilidad | VARCHAR(20) | String | Sí | No | Valores (*propuesta*): PRIVADA, PUBLICA; por defecto PRIVADA. Una evidencia PRIVADA solo es accesible para su dueño o mediante una compartición vigente (RI-15). |

**Claves foráneas sustituidas por relaciones:** `id_usuario` → `(Usuario)-[:GENERA]->(Evidencia)` (R14). `id_intento` → `(Intento)-[:PRODUCE]->(Evidencia)` (R15). Las habilidades demostradas se representan con `(Evidencia)-[:DEMUESTRA]->(Habilidad)` (R16).

### E12 — Comparticion
Mecanismo para controlar el acceso a una evidencia mediante un enlace o permiso.

| Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|
| id_comparticion | UUID | String | Sí | Sí | Identificador de la compartición (RI-01). |
| token | VARCHAR(255) | String | Sí | Sí | Código del enlace de acceso (RI-15). |
| fecha_creacion | TIMESTAMP | DateTime | Sí | No | Creación del enlace. |
| fecha_expiracion | TIMESTAMP | DateTime | No | No | Caducidad del enlace; posterior a `fecha_creacion` (RI-21). Si es nula, el enlace no caduca. |
| estado | VARCHAR(20) | String | Sí | No | Valores (*propuesta*): ACTIVA, REVOCADA. Un enlace está vigente si está ACTIVA y no ha expirado. |
| destinatario | VARCHAR(150) | String | No | No | *Propuesta* (P-06): con quién se comparte (correo o descripción). Si es nulo, puede acceder cualquiera con el enlace vigente. |

**Claves foráneas sustituidas por relaciones:** `id_evidencia` → `(Evidencia)-[:TIENE_COMPARTICION]->(Comparticion)` (R17).

## Propiedades de relaciones

En un grafo de propiedades, las relaciones también pueden tener propiedades. El modelo solo usa esta posibilidad en DESARROLLA (decisión MD-01). Entre una misma simulación y una misma habilidad solo puede existir una relación DESARROLLA (RI-08).

| Relación | Propiedad | Tipo (SQL) | Tipo Neo4j | Obligatoria | Única | Descripción |
|---|---|---|---|---|---|---|
| DESARROLLA | peso | DECIMAL(3,2) | Float | Sí | No | Contribución relativa de la simulación al desarrollo de la habilidad, en el intervalo (0, 1] (*propuesta*, P-03). |
| DESARROLLA | nivel_esperado | INTEGER | Integer | Sí | No | Nivel de la habilidad que la simulación espera desarrollar, en la escala 0–100 (*propuesta*, P-03 y P-08). |

## Catálogos de valores permitidos

| Propiedad | Valores | Estado |
|---|---|---|
| Simulacion.dificultad | BASICA, INTERMEDIA, AVANZADA | Definido (RI-05) |
| Simulacion.estado | BORRADOR, PUBLICADA, INACTIVA | Definido (RI-05) |
| Intento.estado | EN_CURSO, COMPLETADO, ABANDONADO | Definido (RI-06) |
| Usuario.estado | ACTIVO, INACTIVO, SUSPENDIDO | *Propuesta* (P-10) |
| Paso.tipo | CORREO, REUNION, CONVERSACION, TAREA, INCIDENTE | *Propuesta* (P-09) |
| Consecuencia.impacto | POSITIVO, NEUTRO, NEGATIVO | *Propuesta* (P-04) |
| Consecuencia.tipo | RELACIONAL, TIEMPO, CALIDAD, REPUTACION | *Propuesta* (P-04) |
| Retroalimentacion.tipo | ACIERTO, PARCIAL, ERROR | *Propuesta* (P-03) |
| Evidencia.visibilidad | PRIVADA, PUBLICA (por defecto PRIVADA) | *Propuesta* (P-06) |
| Comparticion.estado | ACTIVA, REVOCADA | *Propuesta* (P-06) |
| Habilidad.categoria | Sin catálogo | Pendiente (P-08) |

## Resumen de cumplimiento

| Entidad | Propiedades almacenadas | Obligatorias | Opcionales | Únicas |
|---|---|---|---|---|
| Usuario | 6 | 6 | 0 | 2 |
| Simulacion | 6 | 5 | 1 | 1 |
| Habilidad | 5 | 4 | 1 | 2 |
| Paso | 5 | 5 | 0 | 1 |
| Opcion | 3 | 2 | 1 | 1 |
| Consecuencia | 4 | 4 | 0 | 1 |
| Intento | 5 | 3 | 2 | 1 |
| Respuesta | 3 | 3 | 0 | 1 |
| Retroalimentacion | 4 | 4 | 0 | 1 |
| Progreso | 3 | 3 | 0 | 1 |
| Evidencia | 5 | 5 | 0 | 1 |
| Comparticion | 6 | 4 | 2 | 2 |

Todas las entidades tienen al menos 3 propiedades. Para cada propiedad se indican su nombre, su tipo de dato, si es obligatoria u opcional y si debe ser única.
