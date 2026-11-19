#!/usr/bin/env python3
"""Valida database/seed/dataset.json contra la matriz v2, las convenciones y las reglas RI.

Uso: python3 database/seed/validar_dataset.py [ruta/al/dataset.json]
Termina con código 1 si alguna comprobación falla. Sin dependencias externas.
"""
import json
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime
from pathlib import Path

RUTA = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name("dataset.json")
UUID = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$")
PREFIJO = "e0000000-0000-4000-8000-"

CATALOGOS = {
    ("usuario", "estado"): {"ACTIVO", "INACTIVO", "SUSPENDIDO"},
    ("usuario", "rol"): {"ESTUDIANTE", "ADMIN"},
    ("simulacion", "dificultad"): {"BASICA", "INTERMEDIA", "AVANZADA"},
    ("simulacion", "estado"): {"BORRADOR", "PUBLICADA", "INACTIVA"},
    ("intento", "estado"): {"EN_CURSO", "COMPLETADO", "ABANDONADO"},
    ("evidencia", "visibilidad"): {"PRIVADA", "PUBLICA"},
    ("comparticion", "estado"): {"ACTIVA", "REVOCADA"},
}
TIPO_PASO = {
    "CORREO": {"remitente", "asunto", "cuerpo"},
    "REUNION": {"participantes", "agenda"},
    "CONVERSACION": {"interlocutor", "lineas"},
    "TAREA": {"entregables", "plazo_horas"},
    "INCIDENTE": {"cronologia", "severidad"},
}
IMPACTO = {"POSITIVO", "NEUTRO", "NEGATIVO"}
TIPO_CONSECUENCIA = {"RELACIONAL", "TIEMPO", "CALIDAD", "REPUTACION"}
TIPO_RETRO = {"ACIERTO", "PARCIAL", "ERROR"}

ok = fallos = 0


def check(cond, msg):
    global ok, fallos
    if cond:
        ok += 1
    else:
        fallos += 1
        print(f"  [FALLA] {msg}")


def fecha(s):
    return datetime.fromisoformat(s.replace("Z", "+00:00")) if s else None


d = json.loads(RUTA.read_text(encoding="utf-8"))
R, D = d["relacional"], d["documental"]
check("grafo" not in d, "el grafo no debe tener semilla propia (es una proyección)")

# ---- Identificadores ---------------------------------------------------
print("Identificadores")
todos = []
for tabla, filas in R.items():
    for f in filas:
        for k, v in f.items():
            if k.startswith("id_") and v is not None:
                check(bool(UUID.match(v)), f"{tabla}.{k} no es UUID v4 en minúsculas: {v}")
                check(v.startswith(PREFIJO), f"{tabla}.{k} sin el prefijo de datos de prueba: {v}")
        pk = "id_" + tabla
        if pk in f:
            todos.append(f[pk])
for col, docs in D.items():
    for doc in docs:
        check(bool(UUID.match(doc["_id"])), f"{col}._id no es UUID: {doc['_id']}")
dup = [i for i, n in Counter(todos).items() if n > 1]
check(not dup, f"ids de entidad repetidos: {dup}")

# ---- Catálogos y unicidad ---------------------------------------------
print("Catálogos y unicidad")
for (tabla, campo), valores in CATALOGOS.items():
    for f in R[tabla]:
        check(f[campo] in valores, f"{tabla}.{campo} fuera de catálogo: {f[campo]}")
correos = [u["correo"] for u in R["usuario"]]
check(all(c == c.strip().lower() for c in correos), "RI-02 correo sin normalizar")
check(len(set(correos)) == len(correos), "RI-02 correo repetido")
nombres = [h["nombre"] for h in R["habilidad"]]
check(len(set(nombres)) == len(nombres), "RI-03 nombre de habilidad repetido")
for h in R["habilidad"]:
    check(h["nivel_objetivo"] is None or 0 <= h["nivel_objetivo"] <= 100, "RI-24 nivel_objetivo fuera de 0–100")
tokens = [c["token"] for c in R["comparticion"]]
check(len(set(tokens)) == len(tokens), "RI-15 token repetido")

# ---- Índices -------------------------------------------------------------
usuarios = {u["id_usuario"]: u for u in R["usuario"]}
habilidades = {h["id_habilidad"]: h for h in R["habilidad"]}
simulaciones = {s["id_simulacion"]: s for s in R["simulacion"]}
intentos = {i["id_intento"]: i for i in R["intento"]}
evidencias = {e["id_evidencia"]: e for e in R["evidencia"]}
contenidos = {c["_id"]: c for c in D["contenidos_simulacion"]}
pasos, opciones = {}, {}
for sid, c in contenidos.items():
    for p in c["pasos"]:
        pasos[p["id_paso"]] = (sid, p)
        for o in p["opciones"]:
            opciones[o["id_opcion"]] = (p["id_paso"], o)

# ---- DESARROLLA ------------------------------------------------------
print("Simulación–habilidad")
pares = [(x["id_simulacion"], x["id_habilidad"]) for x in R["simulacion_habilidad"]]
check(len(set(pares)) == len(pares), "RI-08 par (simulación, habilidad) repetido")
desarrolla = defaultdict(set)
for x in R["simulacion_habilidad"]:
    check(x["id_simulacion"] in simulaciones and x["id_habilidad"] in habilidades, f"FK rota en simulacion_habilidad {x}")
    check(0 < x["peso"] <= 1, "RI-24 peso fuera de (0,1]")
    check(0 <= x["nivel_esperado"] <= 100, "RI-24 nivel_esperado fuera de 0–100")
    desarrolla[x["id_simulacion"]].add(x["id_habilidad"])

# ---- Contenido de simulaciones ----------------------------------------
print("Contenido (MongoDB)")
for sid, s in simulaciones.items():
    if s["estado"] == "PUBLICADA":
        check(sid in contenidos, f"RI-17 simulación PUBLICADA sin contenido: {s['titulo']}")
        check(bool(desarrolla[sid]), f"simulación PUBLICADA sin habilidades: {s['titulo']}")
for sid, c in contenidos.items():
    check(sid in simulaciones, f"contenido huérfano (sin registro en PG): {sid}")
    ordenes = [p["orden"] for p in c["pasos"]]
    check(all(o > 0 for o in ordenes) and len(set(ordenes)) == len(ordenes) and 1 in ordenes,
          f"RI-18 orden inválido en {sid}: {ordenes}")
    ids_pasos = {p["id_paso"] for p in c["pasos"]}
    for p in c["pasos"]:
        check(p["tipo"] in TIPO_PASO, f"tipo de paso fuera de catálogo: {p['tipo']}")
        check(set(p["contexto"]) == TIPO_PASO.get(p["tipo"], set()),
              f"contexto de {p['tipo']} con campos {sorted(p['contexto'])}, se esperaban {sorted(TIPO_PASO.get(p['tipo'], []))}")
        check(len(p["opciones"]) >= 1, f"RI-17 paso sin opciones: {p['titulo']}")
        for o in p["opciones"]:
            check(0 <= o["valoracion"] <= 100, "RI-24 valoración fuera de 0–100")
            sig = o["id_paso_siguiente"]
            check(sig is None or (sig in ids_pasos and sig != p["id_paso"]),
                  f"RI-11 opción {o['id_opcion'][-4:]} apunta fuera de su simulación o a su propio paso")
            check(len(o["consecuencias"]) >= 1, f"RI-17 opción sin consecuencias: {o['id_opcion'][-4:]}")
            for q in o["consecuencias"]:
                check(q["impacto"] in IMPACTO and q["tipo"] in TIPO_CONSECUENCIA, f"consecuencia fuera de catálogo: {q}")
            r = o["retroalimentacion"]
            check(r["tipo"] in TIPO_RETRO and r["comentario"] and r["recomendacion"], f"retroalimentación incompleta en {o['id_opcion'][-4:]}")

# ---- Intentos y respuestas --------------------------------------------
print("Intentos y respuestas")
por_intento = defaultdict(list)
for r in R["respuesta"]:
    check(r["id_intento"] in intentos, f"FK rota respuesta→intento {r['id_respuesta'][-4:]}")
    por_intento[r["id_intento"]].append(r)
for iid, i in intentos.items():
    s = simulaciones.get(i["id_simulacion"])
    check(i["id_usuario"] in usuarios and s is not None, f"RI-09 intento {iid[-4:]} con usuario o simulación inexistente")
    check(s and s["estado"] == "PUBLICADA", f"RI-19 intento {iid[-4:]} sobre una simulación no PUBLICADA")
    ini, fin = fecha(i["fecha_inicio"]), fecha(i["fecha_fin"])
    check(fin is None or fin >= ini, f"RI-12 fecha_fin < fecha_inicio en {iid[-4:]}")
    check((i["estado"] == "EN_CURSO") == (fin is None), f"RI-12 estado {i['estado']} incoherente con fecha_fin en {iid[-4:]}")
    check(i["puntuacion"] is None or 0 <= i["puntuacion"] <= 100, f"RI-06 puntuación fuera de rango en {iid[-4:]}")
    rs = sorted(por_intento[iid], key=lambda r: r["secuencia"])
    check([r["secuencia"] for r in rs] == list(range(1, len(rs) + 1)), f"RI-16 secuencias no consecutivas desde 1 en {iid[-4:]}")
    # Recorrido: empieza en orden 1 y sigue id_paso_siguiente (RI-10, RI-23)
    c = contenidos.get(i["id_simulacion"])
    actual = next((p["id_paso"] for p in c["pasos"] if p["orden"] == 1), None) if c else None
    valoraciones, terminal = [], False
    for r in rs:
        check(fecha(r["fecha_respuesta"]) >= ini and (fin is None or fecha(r["fecha_respuesta"]) <= fin),
              f"RI-22 respuesta {r['id_respuesta'][-4:]} fuera de las fechas del intento")
        check(not terminal, f"RI-23 respuesta {r['id_respuesta'][-4:]} después de una opción terminal")
        check(r["id_paso"] == actual, f"respuesta {r['id_respuesta'][-4:]} no responde el paso actual del recorrido")
        po = opciones.get(r["id_opcion"])
        check(po is not None and po[0] == r["id_paso"], f"RI-10 la opción de {r['id_respuesta'][-4:]} no pertenece a su paso")
        check(pasos.get(r["id_paso"], (None,))[0] == i["id_simulacion"], f"RI-10 el paso de {r['id_respuesta'][-4:]} no es de la simulación del intento")
        if po:
            valoraciones.append(po[1]["valoracion"])
            actual = po[1]["id_paso_siguiente"]
            terminal = actual is None
    if i["estado"] == "COMPLETADO":
        check(terminal, f"RI-23 intento COMPLETADO {iid[-4:]} sin opción terminal")
        esperado = round(sum(valoraciones) / len(valoraciones), 2) if valoraciones else None
        check(i["puntuacion"] == esperado, f"puntuación de {iid[-4:]} = {i['puntuacion']}, la regla del contrato da {esperado}")
    if i["estado"] == "EN_CURSO":
        check(not terminal and i["puntuacion"] is None, f"intento EN_CURSO {iid[-4:]} ya terminado o con puntuación")

# ---- Evidencias y comparticiones --------------------------------------
print("Evidencias y comparticiones")
ev_docs = {e["_id"]: e for e in D["evidencias"]}
check(len({e["id_intento"] for e in R["evidencia"]}) == len(R["evidencia"]), "una evidencia por intento")
for eid, e in evidencias.items():
    i = intentos.get(e["id_intento"])
    check(i is not None and i["id_usuario"] == e["id_usuario"], f"RI-14 evidencia {eid[-4:]} de un intento ajeno")
    check(i is not None and i["estado"] == "COMPLETADO", f"RI-25 evidencia {eid[-4:]} de un intento no COMPLETADO")
    doc = ev_docs.get(eid)
    check(doc is not None, f"evidencia {eid[-4:]} sin contenido en MongoDB")
    if doc and i:
        check(doc["simulacion"]["id_simulacion"] == i["id_simulacion"], f"instantánea de {eid[-4:]} con otra simulación")
        check(doc["puntuacion"] == i["puntuacion"], f"instantánea de {eid[-4:]} con otra puntuación")
        check({h["id_habilidad"] for h in doc["habilidades"]} == desarrolla[i["id_simulacion"]],
              f"RI-20 habilidades de la instantánea {eid[-4:]} ≠ DESARROLLA de su simulación")
        check(len(doc["decisiones"]) == len(por_intento[i["id_intento"]]), f"instantánea de {eid[-4:]} con otro número de decisiones")
for eid in ev_docs:
    check(eid in evidencias, f"contenido de evidencia huérfano: {eid}")
for c in R["comparticion"]:
    check(c["id_evidencia"] in evidencias, f"FK rota comparticion→evidencia {c['id_comparticion'][-4:]}")
    check(c["fecha_expiracion"] is None or fecha(c["fecha_expiracion"]) > fecha(c["fecha_creacion"]),
          f"RI-21 expiración no posterior a la creación en {c['id_comparticion'][-4:]}")

print(f"\n{ok} comprobaciones OK, {fallos} fallos")
sys.exit(1 if fallos else 0)
