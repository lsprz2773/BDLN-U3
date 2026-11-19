// =====================================================================
// QATO'K · 04 · Relaciones de ejemplo (las 17 del modelo, R01..R17)
// Cada sentencia busca los nodos por su id y crea la relación.
// En la aplicación real, un nodo y sus relaciones obligatorias se crean en la
// MISMA transacción (entregable 5); aquí van por separado para que cada paso
// del ejemplo se vea claro, y las pruebas de humo comprueban que no queden huérfanos.
// =====================================================================

// R01 · (Usuario)-[:REALIZA]->(Intento): los 4 intentos son de Ana
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0101','0701'],['0101','0702'],['0101','0703'],['0101','0704']] AS p
MATCH (a:Usuario {id_usuario: px + p[0]}), (b:Intento {id_intento: px + p[1]})
CREATE (a)-[:REALIZA]->(b);

// R02 · (Simulacion)-[:TIENE]->(Intento)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0301','0701'],['0301','0703'],['0302','0702'],['0302','0704']] AS p
MATCH (a:Simulacion {id_simulacion: px + p[0]}), (b:Intento {id_intento: px + p[1]})
CREATE (a)-[:TIENE]->(b);

// R03 · (Simulacion)-[:CONTIENE]->(Paso). La simulación en BORRADOR no tiene pasos (OBS-11)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0301','0401'],['0301','0402'],['0301','0403'],['0302','0404']] AS p
MATCH (a:Simulacion {id_simulacion: px + p[0]}), (b:Paso {id_paso: px + p[1]})
CREATE (a)-[:CONTIENE]->(b);

// R04 · (Simulacion)-[:DESARROLLA {peso, nivel_esperado}]->(Habilidad). MERGE: un par, una relación (RI-08)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [
  {s:'0301', h:'0201', peso:0.6, nivel:70},
  {s:'0301', h:'0202', peso:0.4, nivel:60},
  {s:'0302', h:'0203', peso:0.7, nivel:60},
  {s:'0302', h:'0201', peso:0.3, nivel:50},
  {s:'0303', h:'0203', peso:0.5, nivel:70}
] AS d
MATCH (s:Simulacion {id_simulacion: px + d.s}), (h:Habilidad {id_habilidad: px + d.h})
MERGE (s)-[r:DESARROLLA]->(h)
SET r.peso = d.peso, r.nivel_esperado = d.nivel;

// R05 · (Paso)-[:OFRECE]->(Opcion)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0401','0501'],['0401','0502'],['0401','0503'],['0402','0504'],['0402','0505'],
        ['0403','0506'],['0403','0507'],['0404','0508'],['0404','0509']] AS p
MATCH (a:Paso {id_paso: px + p[0]}), (b:Opcion {id_opcion: px + p[1]})
CREATE (a)-[:OFRECE]->(b);

// R06 · (Opcion)-[:GENERA]->(Consecuencia)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0501','0601'],['0502','0602'],['0503','0603'],['0504','0604'],['0505','0605'],
        ['0506','0606'],['0507','0607'],['0508','0608'],['0509','0609']] AS p
MATCH (a:Opcion {id_opcion: px + p[0]}), (b:Consecuencia {id_consecuencia: px + p[1]})
CREATE (a)-[:GENERA]->(b);

// R07 · (Opcion)-[:CONDUCE_A]->(Paso). Las opciones 0504..0509 no tienen: son terminales (DEC-03)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0501','0402'],['0502','0403'],['0503','0403']] AS p
MATCH (a:Opcion {id_opcion: px + p[0]}), (b:Paso {id_paso: px + p[1]})
CREATE (a)-[:CONDUCE_A]->(b);

// R08 · (Intento)-[:REGISTRA]->(Respuesta). El intento 0704 (EN_CURSO) aún no tiene respuestas
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0701','0801'],['0701','0802'],['0702','0803'],['0703','0804'],['0703','0805']] AS p
MATCH (a:Intento {id_intento: px + p[0]}), (b:Respuesta {id_respuesta: px + p[1]})
CREATE (a)-[:REGISTRA]->(b);

// R09 · (Respuesta)-[:CORRESPONDE_A]->(Paso)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0801','0401'],['0802','0402'],['0803','0404'],['0804','0401'],['0805','0403']] AS p
MATCH (a:Respuesta {id_respuesta: px + p[0]}), (b:Paso {id_paso: px + p[1]})
CREATE (a)-[:CORRESPONDE_A]->(b);

// R10 · (Respuesta)-[:SELECCIONA]->(Opcion)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0801','0501'],['0802','0504'],['0803','0509'],['0804','0502'],['0805','0507']] AS p
MATCH (a:Respuesta {id_respuesta: px + p[0]}), (b:Opcion {id_opcion: px + p[1]})
CREATE (a)-[:SELECCIONA]->(b);

// R11 · (Respuesta)-[:GENERA]->(Retroalimentacion)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0801','0901'],['0802','0902'],['0803','0903'],['0804','0904'],['0805','0905']] AS p
MATCH (a:Respuesta {id_respuesta: px + p[0]}), (b:Retroalimentacion {id_retroalimentacion: px + p[1]})
CREATE (a)-[:GENERA]->(b);

// R12 · (Usuario)-[:TIENE_PROGRESO]->(Progreso)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['0101','1001'],['0101','1002'],['0101','1003']] AS p
MATCH (a:Usuario {id_usuario: px + p[0]}), (b:Progreso {id_progreso: px + p[1]})
CREATE (a)-[:TIENE_PROGRESO]->(b);

// R13 · (Progreso)-[:CORRESPONDE_A]->(Habilidad)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND [['1001','0201'],['1002','0202'],['1003','0203']] AS p
MATCH (a:Progreso {id_progreso: px + p[0]}), (b:Habilidad {id_habilidad: px + p[1]})
CREATE (a)-[:CORRESPONDE_A]->(b);

// R14 · (Usuario)-[:GENERA]->(Evidencia)
WITH 'e0000000-0000-4000-8000-00000000' AS px
MATCH (a:Usuario {id_usuario: px + '0101'}), (b:Evidencia {id_evidencia: px + '1101'})
CREATE (a)-[:GENERA]->(b);

// R15 · (Intento)-[:PRODUCE]->(Evidencia): la evidencia sale del intento con 92 puntos
WITH 'e0000000-0000-4000-8000-00000000' AS px
MATCH (a:Intento {id_intento: px + '0701'}), (b:Evidencia {id_evidencia: px + '1101'})
CREATE (a)-[:PRODUCE]->(b);

// R16 · (Evidencia)-[:DEMUESTRA]->(Habilidad): solo habilidades que desarrolla su simulación (RI-20)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND ['0201','0202'] AS h
MATCH (a:Evidencia {id_evidencia: px + '1101'}), (b:Habilidad {id_habilidad: px + h})
CREATE (a)-[:DEMUESTRA]->(b);

// R17 · (Evidencia)-[:TIENE_COMPARTICION]->(Comparticion)
WITH 'e0000000-0000-4000-8000-00000000' AS px
UNWIND ['1201','1202','1203'] AS c
MATCH (a:Evidencia {id_evidencia: px + '1101'}), (b:Comparticion {id_comparticion: px + c})
CREATE (a)-[:TIENE_COMPARTICION]->(b);
