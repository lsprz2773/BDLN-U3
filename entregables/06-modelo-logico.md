# Entregable 6. Diagrama del modelo lógico

**Proyecto:** QATO'K · **Fuente:** KG v1.1 · **Modelo:** grafo de propiedades para Neo4j

El modelo lógico une en un solo grafo lo definido en los entregables 2 (entidades y propiedades), 3 (relaciones), 4 (restricciones) y 5 (cardinalidades).

## 1. Diagrama

![Diagrama del modelo lógico de QATO'K](06-modelo-logico.png)

Fuente del diagrama (Mermaid; se visualiza en GitHub y en editores compatibles):

```mermaid
%%{init: {"flowchart": {"wrappingWidth": 420, "nodeSpacing": 40, "rankSpacing": 110, "curve": "basis"}}}%%
flowchart LR
    Usuario["<b>Usuario</b><br/>id_usuario (U)<br/>nombre<br/>correo (U)<br/>contrasena_hash<br/>fecha_registro<br/>estado"]
    Simulacion["<b>Simulacion</b><br/>id_simulacion (U)<br/>titulo<br/>descripcion<br/>dificultad<br/>duracion_estimada?<br/>estado"]
    Habilidad["<b>Habilidad</b><br/>id_habilidad (U)<br/>nombre (U)<br/>descripcion<br/>categoria<br/>nivel_objetivo?"]
    Paso["<b>Paso</b><br/>id_paso (U)<br/>titulo<br/>descripcion<br/>orden<br/>tipo"]
    Opcion["<b>Opcion</b><br/>id_opcion (U)<br/>descripcion<br/>valoracion?"]
    Consecuencia["<b>Consecuencia</b><br/>id_consecuencia (U)<br/>descripcion<br/>impacto<br/>tipo"]
    Intento["<b>Intento</b><br/>id_intento (U)<br/>fecha_inicio<br/>fecha_fin?<br/>estado<br/>puntuacion?"]
    Respuesta["<b>Respuesta</b><br/>id_respuesta (U)<br/>fecha_respuesta<br/>secuencia"]
    Retroalimentacion["<b>Retroalimentacion</b><br/>id_retroalimentacion (U)<br/>comentario<br/>tipo<br/>recomendacion"]
    Progreso["<b>Progreso</b><br/>id_progreso (U)<br/>nivel_actual<br/>fecha_actualizacion"]
    Evidencia["<b>Evidencia</b><br/>id_evidencia (U)<br/>titulo<br/>descripcion<br/>fecha_generacion<br/>visibilidad"]
    Comparticion["<b>Comparticion</b><br/>id_comparticion (U)<br/>token (U)<br/>fecha_creacion<br/>fecha_expiracion?<br/>estado<br/>destinatario?"]

    Usuario -- "REALIZA [0..N / 1..1]" --> Intento
    Simulacion -- "TIENE [0..N / 1..1]" --> Intento
    Simulacion -- "CONTIENE [0..N / 1..1]" --> Paso
    Simulacion -- "DESARROLLA {peso, nivel_esperado} [0..N / 0..N]" --> Habilidad
    Paso -- "OFRECE [1..N / 1..1]" --> Opcion
    Opcion -- "GENERA [1..N / 1..1]" --> Consecuencia
    Opcion -- "CONDUCE_A [0..1 / 0..N]" --> Paso
    Intento -- "REGISTRA [0..N / 1..1]" --> Respuesta
    Respuesta -- "CORRESPONDE_A [1..1 / 0..N]" --> Paso
    Respuesta -- "SELECCIONA [1..1 / 0..N]" --> Opcion
    Respuesta -- "GENERA [0..N / 1..1]" --> Retroalimentacion
    Usuario -- "TIENE_PROGRESO [0..N / 1..1]" --> Progreso
    Progreso -- "CORRESPONDE_A [1..1 / 0..N]" --> Habilidad
    Usuario -- "GENERA [0..N / 1..1]" --> Evidencia
    Intento -- "PRODUCE [0..N / 1..1]" --> Evidencia
    Evidencia -- "DEMUESTRA [1..N / 0..N]" --> Habilidad
    Evidencia -- "TIENE_COMPARTICION [0..N / 1..1]" --> Comparticion

    classDef contenido fill:#EEEEEE,stroke:#616161,color:#212121
    classDef ejecucion fill:#FFF3E0,stroke:#E65100,color:#4A2300
    classDef resultado fill:#E8F5E9,stroke:#2E7D32,color:#123D16
    class Simulacion,Paso,Opcion,Consecuencia,Habilidad contenido
    class Usuario,Intento,Respuesta,Retroalimentacion ejecucion
    class Progreso,Evidencia,Comparticion resultado
```

## 2. Leyenda

| Elemento | Significado |
|---|---|
| Caja | Nodo con su etiqueta (entidad) y sus propiedades almacenadas |
| `(U)` | Propiedad única (restricción de unicidad nativa en Neo4j) |
| `?` | Propiedad opcional; las demás son obligatorias |
| `destinatario?` en Comparticion | Propiedad *propuesta* (P-06); el resto de los elementos del diagrama forma parte del modelo adoptado |
| Flecha | Relación dirigida, del origen al destino |
| `TIPO {p1, p2}` | Tipo de relación y, entre llaves, sus propiedades |
| `[a / b]` | Cardinalidades: `a` = destinos por cada origen; `b` = orígenes por cada destino (entregable 5) |
| Gris | **Contenido** de las simulaciones: Simulacion, Paso, Opcion, Consecuencia, Habilidad |
| Naranja | **Ejecución** por parte del usuario: Usuario, Intento, Respuesta, Retroalimentacion |
| Verde | **Resultados** del aprendizaje: Progreso, Evidencia, Comparticion |

## 3. Lectura del modelo

El grafo se organiza en tres zonas conectadas:

1. **Contenido (gris).** Una `Simulacion` CONTIENE pasos. Cada `Paso` OFRECE opciones, cada `Opcion` GENERA consecuencias y CONDUCE_A otro paso. Así se forman las ramificaciones (MD-03). Una opción sin CONDUCE_A es terminal y cierra la ruta. El paso inicial es el de `orden = 1`. La simulación DESARROLLA habilidades con un `peso` y un `nivel_esperado` (MD-01).
2. **Ejecución (naranja).** Un `Usuario` REALIZA un `Intento` de una simulación (TIENE). El intento REGISTRA cada `Respuesta`, que CORRESPONDE_A un paso y SELECCIONA una opción. Así queda el recorrido exacto del usuario, ordenado por `secuencia` (MD-04). Cada respuesta puede generar (GENERA) `Retroalimentacion`.
3. **Resultados (verde).** El usuario TIENE_PROGRESO en cada habilidad (MD-02). Sus intentos PRODUCEN `Evidencia` que DEMUESTRA habilidades. Cada evidencia puede compartirse mediante `Comparticion` (MD-05).

`Habilidad` es el nodo que une las tres zonas: la alcanzan DESARROLLA (contenido), CORRESPONDE_A desde Progreso y DEMUESTRA (resultados). Por eso las consultas de recomendación, fortalezas y evidencias se resuelven con recorridos cortos sobre el grafo.

## 4. Comprobación: las consultas se resuelven sobre el diagrama

| Consulta | Recorrido en el diagrama | Saltos |
|---|---|---|
| C-01 Simulaciones según el progreso | Usuario → TIENE_PROGRESO → Progreso → CORRESPONDE_A → Habilidad ← DESARROLLA ← Simulacion | 3 |
| C-02 Fortalezas y áreas de mejora | Usuario → TIENE_PROGRESO → Progreso → CORRESPONDE_A → Habilidad ← DESARROLLA ← Simulacion → TIENE → Intento ← REALIZA ← Usuario; Intento → REGISTRA → Respuesta → GENERA → Retroalimentacion | 7 |
| C-03 Decisiones, consecuencias y retroalimentación | Usuario → REALIZA → Intento ← TIENE ← Simulacion; Intento → REGISTRA → Respuesta → CORRESPONDE_A → Paso; Respuesta → SELECCIONA → Opcion → GENERA → Consecuencia; Respuesta → GENERA → Retroalimentacion | 7 |
| C-04 Evidencias compartibles | Usuario → GENERA → Evidencia → DEMUESTRA → Habilidad; Simulacion → TIENE → Intento → PRODUCE → Evidencia → TIENE_COMPARTICION → Comparticion | 5 |
| C-05 Evolución de una habilidad | Usuario → REALIZA → Intento ← TIENE ← Simulacion → DESARROLLA → Habilidad ← CORRESPONDE_A ← Progreso ← TIENE_PROGRESO ← Usuario | 5 |

Las cinco consultas recorren solo relaciones del diagrama, en la dirección almacenada o en la inversa. Neo4j permite recorrer en ambos sentidos.

## 5. Resumen del modelo

| Elemento | Cantidad |
|---|---|
| Etiquetas de nodo | 12 |
| Relaciones (patrones origen–tipo–destino) | 17 |
| Tipos de relación distintos | 14 |
| Relaciones con propiedades | 1 (DESARROLLA: `peso`, `nivel_esperado`) |
| Propiedades almacenadas en nodos | 55 |
| Restricciones de integridad | 25 (entregable 4) |
