// =====================================================================
// QATO'K · 03 · Nodos de ejemplo
// Datos ficticios, pensados para que cada consulta C-01..C-05 devuelva
// un resultado conocido (ver README, "Datos de ejemplo por consulta").
// Todos los identificadores empiezan por 'e0000000-0000-4000-8000-'
// para poder retirarlos después (05-limpieza.cypher).
// Las propiedades opcionales sin valor no se guardan (en Neo4j, nulo = ausente).
// =====================================================================

// ---- Usuarios (C-01..C-05). Ana tiene historial; Bruno es nuevo (OBS-10) ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0101', nombre:'Ana López',  correo:'ana.lopez@ejemplo.com',  registro:'2026-09-01T09:00:00Z'},
  {s:'0102', nombre:'Bruno Díaz', correo:'bruno.diaz@ejemplo.com', registro:'2026-11-10T12:00:00Z'}
] AS r
CREATE (:Usuario {id_usuario: px + r.s, nombre: r.nombre, correo: r.correo,
                  contrasena_hash: '$2b$12$hash.ficticio.de.ejemplo', fecha_registro: datetime(r.registro),
                  estado: 'ACTIVO'});

// ---- Habilidades (C-01, C-02, C-04, C-05). Gestión del tiempo sin nivel_objetivo ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0201', nombre:'Comunicación efectiva',    desc:'Expresar ideas con claridad y escuchar al otro.',          cat:'Interpersonal',  obj:75},
  {s:'0202', nombre:'Resolución de conflictos', desc:'Llegar a acuerdos cuando hay intereses en tensión.',        cat:'Interpersonal',  obj:70},
  {s:'0203', nombre:'Gestión del tiempo',       desc:'Priorizar tareas y comunicar riesgos de plazo a tiempo.', cat:'Organizacional', obj:null}
] AS r
CREATE (h:Habilidad {id_habilidad: px + r.s, nombre: r.nombre, descripcion: r.desc, categoria: r.cat})
SET h.nivel_objetivo = r.obj;

// ---- Simulaciones (C-01: la de BORRADOR no debe recomendarse) ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0301', titulo:'Cliente molesto por un retraso', desc:'Un cliente reclama por un pedido que lleva una semana de retraso.', dif:'INTERMEDIA', dur:15,   estado:'PUBLICADA'},
  {s:'0302', titulo:'Tres entregas para mañana',      desc:'Tienes tres tareas con la misma fecha límite y no llegas a todas.', dif:'BASICA',     dur:10,   estado:'PUBLICADA'},
  {s:'0303', titulo:'Presentación ante dirección',    desc:'Debes presentar resultados negativos a la dirección.',              dif:'AVANZADA',   dur:null, estado:'BORRADOR'}
] AS r
CREATE (s:Simulacion {id_simulacion: px + r.s, titulo: r.titulo, descripcion: r.desc, dificultad: r.dif, estado: r.estado})
SET s.duracion_estimada = r.dur;

// ---- Pasos (C-03). P1..P3 de la simulación 0301; Q1 de la 0302 ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0401', titulo:'Correo del cliente',     desc:'El cliente escribe molesto: su pedido lleva una semana de retraso.', orden:1, tipo:'CORREO'},
  {s:'0402', titulo:'Llamada con el cliente', desc:'El cliente acepta hablar por teléfono y pide una solución.',          orden:2, tipo:'CONVERSACION'},
  {s:'0403', titulo:'Reunión con tu jefa',    desc:'Tu jefa quiere saber qué pasó y qué propones.',                       orden:3, tipo:'REUNION'},
  {s:'0404', titulo:'Tres tareas, un día',    desc:'Son las 9:00 y tienes tres entregas para las 18:00.',                 orden:1, tipo:'TAREA'}
] AS r
CREATE (:Paso {id_paso: px + r.s, titulo: r.titulo, descripcion: r.desc, orden: r.orden, tipo: r.tipo});

// ---- Opciones (C-03). Las que no tendrán CONDUCE_A son terminales ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0501', desc:'Responder de inmediato: disculparte y proponer una llamada', val:90.0},
  {s:'0502', desc:'Esperar a tener toda la información antes de responder',    val:50.0},
  {s:'0503', desc:'Reenviar el correo a tu jefa sin responder',                 val:20.0},
  {s:'0504', desc:'Proponer una nueva fecha y comprometerte a avisar',          val:95.0},
  {s:'0505', desc:'Culpar al proveedor del retraso',                            val:30.0},
  {s:'0506', desc:'Explicar el problema con dos alternativas',                  val:80.0},
  {s:'0507', desc:'Minimizar el problema',                                      val:25.0},
  {s:'0508', desc:'Priorizar y avisar del riesgo a tiempo',                     val:90.0},
  {s:'0509', desc:'Intentar terminar todo sin avisar',                          val:40.0}
] AS r
CREATE (:Opcion {id_opcion: px + r.s, descripcion: r.desc, valoracion: r.val});

// ---- Consecuencias (C-03). Una por opción (RI-17) ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0601', desc:'El cliente agradece la rapidez y acepta la llamada',      imp:'POSITIVO', tipo:'RELACIONAL'},
  {s:'0602', desc:'El cliente insiste y escala la queja',                    imp:'NEGATIVO', tipo:'REPUTACION'},
  {s:'0603', desc:'Tu jefa te pide que lo atiendas tú',                      imp:'NEUTRO',   tipo:'TIEMPO'},
  {s:'0604', desc:'El cliente acepta la nueva fecha',                        imp:'POSITIVO', tipo:'RELACIONAL'},
  {s:'0605', desc:'El cliente pierde confianza en la empresa',               imp:'NEGATIVO', tipo:'REPUTACION'},
  {s:'0606', desc:'Tu jefa aprueba una de las alternativas',                 imp:'POSITIVO', tipo:'CALIDAD'},
  {s:'0607', desc:'El problema crece y se pierde un día',                    imp:'NEGATIVO', tipo:'TIEMPO'},
  {s:'0608', desc:'Dos entregas llegan y la tercera se reprograma a tiempo', imp:'POSITIVO', tipo:'TIEMPO'},
  {s:'0609', desc:'Las tres entregas llegan incompletas',                    imp:'NEGATIVO', tipo:'CALIDAD'}
] AS r
CREATE (:Consecuencia {id_consecuencia: px + r.s, descripcion: r.desc, impacto: r.imp, tipo: r.tipo});

// ---- Intentos de Ana (C-02, C-03, C-05). El 0704 sigue EN_CURSO ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0703', ini:'2026-09-20T16:00:00Z', fin:'2026-09-20T16:12:00Z', estado:'COMPLETADO', pts:45.0},
  {s:'0701', ini:'2026-10-01T10:00:00Z', fin:'2026-10-01T10:14:00Z', estado:'COMPLETADO', pts:92.0},
  {s:'0702', ini:'2026-10-10T18:00:00Z', fin:'2026-10-10T18:08:00Z', estado:'COMPLETADO', pts:65.0},
  {s:'0704', ini:'2026-11-11T09:00:00Z', fin:null,                   estado:'EN_CURSO',   pts:null}
] AS r
CREATE (i:Intento {id_intento: px + r.s, fecha_inicio: datetime(r.ini), estado: r.estado})
SET i.fecha_fin = datetime(r.fin), i.puntuacion = r.pts;

// ---- Respuestas (C-02, C-03) ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0801', fecha:'2026-10-01T10:03:00Z', seq:1},
  {s:'0802', fecha:'2026-10-01T10:10:00Z', seq:2},
  {s:'0803', fecha:'2026-10-10T18:05:00Z', seq:1},
  {s:'0804', fecha:'2026-09-20T16:04:00Z', seq:1},
  {s:'0805', fecha:'2026-09-20T16:10:00Z', seq:2}
] AS r
CREATE (:Respuesta {id_respuesta: px + r.s, fecha_respuesta: datetime(r.fecha), secuencia: r.seq});

// ---- Retroalimentación (C-02, C-03). Una por respuesta ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0901', com:'Responder rápido baja la tensión del cliente.',                         tipo:'ACIERTO', rec:'Mantén el tono empático durante la llamada.'},
  {s:'0902', com:'Una fecha concreta con compromiso de aviso recupera la confianza.',     tipo:'ACIERTO', rec:'Confirma el acuerdo por escrito.'},
  {s:'0903', com:'Callar el riesgo deja sin margen a tu equipo.',                         tipo:'ERROR',   rec:'Avisa en cuanto detectes que no llegas.'},
  {s:'0904', com:'Buscar información es bueno, pero el cliente necesitaba una respuesta.', tipo:'PARCIAL', rec:'Acusa recibo aunque aún no tengas la solución.'},
  {s:'0905', com:'Minimizar el problema impide decidir a tiempo.',                        tipo:'ERROR',   rec:'Presenta el problema con su impacto y alternativas.'}
] AS r
CREATE (:Retroalimentacion {id_retroalimentacion: px + r.s, comentario: r.com, tipo: r.tipo, recomendacion: r.rec});

// ---- Progreso consolidado de Ana (C-01, C-02, C-05). Bruno no tiene ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'1001', nivel:78.0, fecha:'2026-10-10T18:10:00Z'},
  {s:'1002', nivel:55.0, fecha:'2026-10-01T10:15:00Z'},
  {s:'1003', nivel:40.0, fecha:'2026-10-10T18:10:00Z'}
] AS r
CREATE (:Progreso {id_progreso: px + r.s, nivel_actual: r.nivel, fecha_actualizacion: datetime(r.fecha)});

// ---- Evidencia de Ana (C-04) ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
CREATE (:Evidencia {id_evidencia: px + '1101', titulo: 'Manejo de un cliente molesto',
                    descripcion: 'Atendió una queja por retraso: respondió rápido, propuso una nueva fecha y recuperó la confianza del cliente.',
                    fecha_generacion: datetime('2026-10-01T10:20:00Z'), visibilidad: 'PRIVADA'});

// ---- Comparticiones (C-04): una vigente, una revocada y una expirada ----
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'1201', token:'tok-ejemplo-vigente',  creada:'2026-10-02T09:00:00Z', expira:null,                   estado:'ACTIVA',   dest:'reclutamiento@empresa-ejemplo.com'},
  {s:'1202', token:'tok-ejemplo-revocado', creada:'2026-10-03T09:00:00Z', expira:null,                   estado:'REVOCADA', dest:null},
  {s:'1203', token:'tok-ejemplo-expirado', creada:'2026-10-05T09:00:00Z', expira:'2026-10-15T09:00:00Z', estado:'ACTIVA',   dest:null}
] AS r
CREATE (c:Comparticion {id_comparticion: px + r.s, token: r.token, fecha_creacion: datetime(r.creada), estado: r.estado})
SET c.fecha_expiracion = datetime(r.expira), c.destinatario = r.dest;
