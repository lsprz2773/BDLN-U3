# Guion de exposición — QATO'K

**Fecha:** 12 de noviembre de 2026 · **Versión editable:** documento de Claude Docs (enlace en `presentacion/README.md`)

Guion para presentar las 12 diapositivas en 9 minutos y 40 segundos, con 20 segundos de margen sobre el límite de 10 minutos. El texto está calculado a unas 130 palabras por minuto, un ritmo de exposición pausado.

## Reparto y tiempos

La exposición se divide en dos mitades de casi 5 minutos. La persona A presenta la idea y el porqué del grafo; la persona B, los entregables y las conclusiones. El cambio de expositor ocurre en la diapositiva 7.

| # | Diapositiva | Expositor | Duración | Termina en el minuto |
| --- | --- | --- | --- | --- |
| 1 | Portada | A | 0:30 | 0:30 |
| 2 | Hay una brecha entre estudiar y trabajar | A | 0:50 | 1:20 |
| 3 | Practicar el trabajo antes de tenerlo | A | 0:50 | 2:10 |
| 4 | Tres zonas unidas por Habilidad | A | 0:50 | 3:00 |
| 5 | Por qué una base de datos orientada a grafos | A | 1:00 | 4:00 |
| 6 | Una consulta, un recorrido | A | 0:55 | 4:55 |
| 7 | Los siete entregables | B | 0:50 | 5:45 |
| 8 | El modelo lógico completo | B | 0:45 | 6:30 |
| 9 | Quién garantiza cada regla | B | 1:00 | 7:30 |
| 10 | Decisiones de modelado clave | B | 0:55 | 8:25 |
| 11 | Limitaciones conocidas y pendientes | B | 0:35 | 9:00 |
| 12 | Conclusión | B | 0:40 | 9:40 |

## Diapositivas 1 a 3 · La idea (persona A)

### 1 · Portada — 0:30

“Buenos días. Les presentamos QATO'K, una plataforma de simulaciones profesionales para estudiantes que están por egresar. En los próximos minutos explicaremos la idea del proyecto, los siete entregables del modelo lógico y por qué esta propuesta encaja de forma natural en una base de datos orientada a grafos, con Neo4j como base principal y PostgreSQL como complemento.”

### 2 · Hay una brecha entre estudiar y trabajar — 0:50

“El punto de partida es un problema que muchos conocemos: existe una brecha entre lo que se aprende en la universidad y lo que se pide en un trabajo. Muchos egresados no saben si su experiencia académica es suficiente ni cómo demostrar lo que saben hacer.

Las causas están a la derecha: una formación predominantemente teórica, falta de experiencia laboral formal, pocas oportunidades de decidir con información incompleta, dificultad para comunicar sus competencias en una entrevista y ninguna retroalimentación sobre su desempeño.

Nuestro usuario es el estudiante de último semestre o recién egresado: con poco tiempo, que usa principalmente el celular y que cuida su privacidad.”

### 3 · Practicar el trabajo antes de tenerlo — 0:50

“Nuestra respuesta es practicar el trabajo antes de tenerlo, con simulaciones cortas y repetibles. Funciona en cinco pasos.

Primero, una situación laboral: un correo, una reunión o un incidente. Segundo, el usuario toma una decisión. Tercero, esa decisión tiene consecuencias y lo lleva al siguiente paso. Cuarto, recibe retroalimentación que explica el acierto o el error y cómo mejorar. Y quinto, su nivel en cada habilidad avanza y se genera una evidencia que él decide si comparte con un empleador.

Lo importante para la base de datos es que todo está conectado: cada paso con el siguiente, y todo con las habilidades.”

## Diapositivas 4 a 6 · El modelo y por qué un grafo (persona A)

### 4 · Tres zonas unidas por Habilidad — 0:50

“Con esa idea construimos el modelo: doce entidades y diecisiete relaciones, que agrupamos en tres zonas.

La zona de contenido describe cada simulación: sus pasos, sus opciones y sus consecuencias. La zona de ejecución registra lo que hizo el usuario: sus intentos y cada una de sus respuestas, con su retroalimentación. Y la zona de resultados guarda su progreso y sus evidencias.

*(Señalar el nodo Habilidad.)* El nodo que une las tres zonas es Habilidad: las simulaciones la desarrollan, el progreso la mide y las evidencias la demuestran. Por eso casi todas las preguntas que el sistema necesita responder pasan por este nodo.”

### 5 · Por qué una base de datos orientada a grafos — 1:00

“¿Por qué una base de datos orientada a grafos? Por cuatro razones.

Primera: el contenido ya es un grafo. Cada opción conduce a otro paso y varias rutas pueden llegar al mismo punto; eso son nodos y aristas dirigidas.

Segunda: las preguntas importantes del sistema son recorridos. Nuestras cinco consultas cruzan entre cuatro y ocho entidades conectadas.

Tercera: en un grafo las relaciones guardan datos. La relación DESARROLLA almacena el peso y el nivel esperado de una simulación sobre una habilidad, sin una tabla intermedia.

Y cuarta: el modelo crece sin rediseñarse; agregar, por ejemplo, un historial de progreso es añadir nodos y relaciones. También evaluamos MongoDB, pero lo descartamos porque los documentos no resuelven bien estos recorridos.”

### 6 · Una consulta, un recorrido — 0:55

“Veamos un ejemplo. Una de nuestras consultas pregunta qué decidió un usuario durante una simulación, qué consecuencias tuvo y qué retroalimentación recibió.

*(Recorrer el código de arriba abajo.)* En Neo4j se escribe como un solo patrón que sigue las flechas: del usuario al intento, del intento a cada respuesta, de la respuesta al paso y a la opción elegida, y de ahí a la consecuencia y a la retroalimentación.

Son siete entidades en un solo recorrido. En una base relacional, la misma pregunta necesitaría seis JOIN entre siete tablas. Además, la propiedad secuencia permite reconstruir las decisiones en el orden exacto en que se tomaron.

Ahora mi compañero presentará los entregables.”

## Diapositivas 7 a 9 · Los entregables (persona B)

### 7 · Los siete entregables — 0:50

“Gracias. Los entregables de la actividad son siete.

Primero, la tabla de requerimientos y consultas: diez requerimientos y cinco consultas, que son las que justifican el uso del grafo. Segundo, el diccionario de doce entidades con cincuenta y cinco propiedades; aquí las claves foráneas desaparecen, porque en el grafo se convierten en relaciones. Tercero, el catálogo de diecisiete relaciones. Cuarto, veinticinco restricciones de integridad en cinco categorías. Quinto, las cardinalidades, que indican qué nodos no pueden existir solos. Sexto, el diagrama del modelo lógico. Y séptimo, las conclusiones.

En todos los casos superamos los mínimos que pedía la actividad.”

### 8 · El modelo lógico completo — 0:45

“Este es el diagrama del modelo lógico completo. Cada caja es un tipo de nodo con sus propiedades: la marca U indica que la propiedad es única y el signo de interrogación, que es opcional.

Cada flecha es una relación con su nombre y su cardinalidad. *(Señalar REALIZA.)* Por ejemplo, un usuario realiza de cero a muchos intentos, y cada intento pertenece exactamente a un usuario.

Los colores repiten las tres zonas: gris para el contenido, naranja para la ejecución y verde para los resultados. Las cinco consultas se resuelven recorriendo entre tres y siete relaciones de este diagrama.”

### 9 · Quién garantiza cada regla — 1:00

“Un punto importante es quién garantiza cada regla.

Neo4j, de forma nativa, garantiza la unicidad: los identificadores, el correo del usuario, el nombre de cada habilidad y el token de los enlaces. Las propiedades obligatorias y los tipos de dato solo los ofrece su edición Enterprise.

Neo4j no tiene restricciones CHECK ni puede exigir que una relación exista. Por eso veintitrés de nuestras veinticinco restricciones necesitan validación en la aplicación, dentro de la misma transacción que guarda los datos. Por ejemplo, una respuesta solo se registra si la opción pertenece al paso y el paso a la simulación del intento.

Las cardinalidades completan esto: tres entidades pueden existir solas, y las otras nueve se crean junto con sus relaciones obligatorias.”

## Diapositivas 10 a 12 · Decisiones y cierre (persona B)

### 10 · Decisiones de modelado clave — 0:55

“Estas son cuatro decisiones de modelado clave.

La primera: cada decisión del usuario es un nodo Respuesta y no una relación, porque se conecta con cuatro elementos a la vez —el intento, el paso, la opción y la retroalimentación— y una relación solo puede unir dos nodos.

La segunda: DESARROLLA es una relación directa con propiedades, lo que evita un nodo intermedio.

La tercera: una simulación termina cuando el usuario elige una opción terminal, es decir, una opción sin paso siguiente; así el desenlace queda registrado.

Y la cuarta: toda opción tiene al menos una consecuencia, porque una decisión sin resultado contradiría la idea central de la plataforma.”

### 11 · Limitaciones conocidas y pendientes — 0:35

“También identificamos lo que queda pendiente. Hoy el desempeño se atribuye a cada habilidad por simulación y no por decisión individual. La evolución de una habilidad se aproxima con los intentos, porque falta un historial de progreso. Y falta decidir qué datos irán en PostgreSQL, cómo se sincroniza con Neo4j y cómo se calcula el nivel de cada habilidad. Ninguno de estos puntos obliga a rediseñar el modelo: el grafo permite agregarlos.”

### 12 · Conclusión — 0:40

“Para concluir, respondemos las dos preguntas de la actividad. Identificar las entidades no es suficiente: las entidades son el vocabulario, pero las relaciones y sus reglas son la gramática. Y las consultas, las restricciones y las cardinalidades definen el modelo: las consultas dicen qué relaciones hacen falta, las cardinalidades qué nodos dependen de otros y las restricciones qué debe garantizar la aplicación.

Las preguntas importantes de QATO'K son recorridos, y un grafo está hecho para recorrer. Muchas gracias; quedamos atentos a sus preguntas.”

## Recomendaciones para el ensayo

- **Puntos de control:** al terminar la diapositiva 6 deberían llevar 4:55, y al terminar la 9, 7:30. Si van más de 30 segundos atrasados, resuman la diapositiva 8 a su primera y última frase.
- **Si sobra tiempo:** en la diapositiva 4 pueden mencionar un ejemplo concreto, como la simulación «Cliente molesto por un retraso».
- **No leer:** el guion sirve para ensayar. El día de la exposición basta con recordar la idea de cada párrafo; las notas del orador de cada diapositiva tienen ese resumen.
- **Señalar:** las indicaciones entre paréntesis y en cursiva marcan qué señalar en pantalla.
- **Ensayar el cambio de expositor** al final de la diapositiva 6, para que no se pierdan segundos.
- **Preguntas del maestro:** la guía de estudio tiene diez preguntas probables con respuestas cortas.
