#!/usr/bin/env python3
"""Comprobaciones automáticas de los entregables contra docs/KG.json (CoVe mecánico).

Uso: python3 scripts/verificar.py [n ...]   (sin argumentos verifica todos los entregables existentes)
Sale con código 1 si alguna comprobación falla.
"""
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
KG = json.loads((RAIZ / "docs/KG.json").read_text(encoding="utf-8"))["knowledge_graph"]
ENT = RAIZ / "entregables"
DEC_DOC = (RAIZ / "docs/decisiones-modelado.md").read_text(encoding="utf-8")

ENTIDADES = {e["name"]: e for e in KG["domain_model"]["entities"]}
RELS = KG["domain_model"]["relationships"]
TRIPLES = {(r["source"], r["type"], r["target"]) for r in RELS}
TIPOS_REL = {r["type"] for r in RELS}
REL_PROPS = {r["type"]: {p["name"] for p in r.get("relationship_property_definitions", [])} for r in RELS}
RF_IDS = [r["id"] for r in KG["functional_requirements"]]
C = {q["id"]: q for q in KG["system_queries"]}
RI_IDS = [r["id"] for r in KG["integrity_constraints"]]

fallos, avisos, oks = [], [], []


def ok(msg):
    oks.append(msg)


def falla(msg):
    fallos.append(msg)


def check(cond, msg):
    (ok if cond else falla)(msg)


def props_no_fk(ent):
    return [p for p in ENTIDADES[ent]["properties"] if not p.get("foreign_key")]


def tablas(md):
    """Devuelve una lista de tablas; cada tabla es (encabezados, filas)."""
    res, actual = [], None
    for linea in md.splitlines():
        if linea.startswith("|"):
            celdas = [c.strip() for c in linea.strip().strip("|").split("|")]
            if actual is None:
                actual = (celdas, [])
            elif set("".join(celdas)) <= set("-: "):
                continue
            else:
                actual[1].append(dict(zip(actual[0], celdas)))
        else:
            if actual:
                res.append(actual)
            actual = None
    if actual:
        res.append(actual)
    return res


def tabla_con(md, columna):
    return [t for t in tablas(md) if columna in t[0]]


def limpiar(s):
    return re.sub(r"[`*]", "", s).strip()


def lista(s):
    return [limpiar(x) for x in limpiar(s).split(",") if limpiar(x)]


# ---------------------------------------------------------------- referencias
def ids_validos():
    v = set(RF_IDS) | set(C) | set(RI_IDS)
    v |= {r["id"] for r in RELS}
    v |= {e["id"] for e in KG["domain_model"]["entities"]}
    v |= {m["id"] for m in KG["logical_graph_model"]["modeling_decisions"]}
    v |= {d["id"] for d in KG["decisions_and_discards"]}
    v |= {p["id"] for p in KG["pending_decisions"]}
    v |= {o["id"] for o in KG["known_modeling_observations"]}
    v |= {l["id"] for l in KG.get("known_limitations", [])}
    v |= set(re.findall(r"DEC-\d+", DEC_DOC))
    return v


PATRON_ID = re.compile(r"\b(RF-\d{2}|C-\d{2}|RI-\d{2}|R\d{2}|E\d{2}|MD-\d{2}|D-\d{2}|P-\d{2}|OBS-\d{2}|LIM-\d{2}|DEC-\d{2})\b")


def verificar_referencias(nombre, md):
    validos = ids_validos()
    malos = sorted({i for i in PATRON_ID.findall(md) if i not in validos})
    check(not malos, f"[{nombre}] todas las referencias a IDs existen" + (f" (inexistentes: {malos})" if malos else ""))


# ---------------------------------------------------------------- Cypher
NODO = re.compile(r"\((\w*)(?::(\w+))?(?:\s*\{[^}]*\})?\)")
ARISTA = re.compile(r"(<?-)\[(\w*)(?::(\w+))?(?:\s*\{[^}]*\})?\](->|-)")


def verificar_cypher(nombre, bloque):
    var_label = {}
    for m in NODO.finditer(bloque):
        if m.group(1) and m.group(2):
            var_label[m.group(1)] = m.group(2)
    for lab in {m.group(2) for m in NODO.finditer(bloque) if m.group(2)}:
        check(lab in ENTIDADES, f"[{nombre}] etiqueta :{lab} existe")
    var_rel = {}
    # recorrer cadenas nodo-arista-nodo
    for linea in bloque.splitlines():
        pos, prev = 0, None
        while True:
            mn = NODO.search(linea, pos)
            if not mn:
                break
            lab = mn.group(2) or var_label.get(mn.group(1))
            if prev is not None and prev[1] is not None:
                arista, lab_prev = prev
                izq, var, tipo, der = arista.groups()
                if var and tipo:
                    var_rel[var] = tipo
                if izq == "<-":
                    trip = (lab, tipo, lab_prev)
                else:
                    trip = (lab_prev, tipo, lab)
                if None in trip:
                    avisos.append(f"[{nombre}] no se pudo resolver {trip}")
                else:
                    check(trip in TRIPLES, f"[{nombre}] relación ({trip[0]})-[:{trip[1]}]->({trip[2]}) existe en el KG")
            ma = ARISTA.match(linea, mn.end())
            prev = (ma, lab) if ma else None
            pos = ma.end() if ma else mn.end()
    # accesos a propiedades
    for var, prop in re.findall(r"\b([a-z]\w*)\.(\w+)\b", bloque):
        if var in var_label:
            nombres = {p["name"] for p in ENTIDADES[var_label[var]]["properties"]}
            check(prop in nombres, f"[{nombre}] propiedad {var_label[var]}.{prop} existe")
        elif var in var_rel:
            check(prop in REL_PROPS.get(var_rel[var], set()), f"[{nombre}] propiedad de relación {var_rel[var]}.{prop} existe")
    for m in NODO.finditer(bloque):
        if m.group(2) and "{" in m.group(0):
            for prop in re.findall(r"(\w+)\s*:", m.group(0).split("{", 1)[1]):
                nombres = {p["name"] for p in ENTIDADES[m.group(2)]["properties"]}
                check(prop in nombres, f"[{nombre}] propiedad {m.group(2)}.{prop} (filtro) existe")
    return var_label


# ---------------------------------------------------------------- E1
def e1(md):
    t_rf = tabla_con(md, "Requerimiento")[0][1]
    ids = [limpiar(f["ID"]) for f in t_rf]
    check(ids == RF_IDS, f"[E1] RF del entregable = RF del KG ({len(ids)})")
    check(len(ids) >= 8, "[E1] al menos 8 RF")
    por_rf = {r["id"]: r for r in KG["functional_requirements"]}
    for f in t_rf:
        check(limpiar(f["Descripción"]) == por_rf[f["ID"]]["description"], f"[E1] {f['ID']}: descripción = KG")
    for f in t_rf:
        for ent in lista(f["Entidades principales"]):
            check(ent in ENTIDADES, f"[E1] {f['ID']}: entidad {ent} existe")
    t_c = tabla_con(md, "Consulta")[0][1]
    check([f["ID"] for f in t_c] == list(C), "[E1] consultas C-01..C-05")
    n3 = 0
    for f in t_c:
        ents = lista(f["Entidades involucradas"])
        kg_ents = C[f["ID"]]["related_entities"]
        check(sorted(ents) == sorted(kg_ents), f"[E1] {f['ID']}: entidades = KG {sorted(kg_ents)}")
        check(int(f["N.º de entidades"]) == len(ents), f"[E1] {f['ID']}: conteo de entidades correcto")
        check(limpiar(f["Consulta"]) == C[f["ID"]]["description"], f"[E1] {f['ID']}: texto de la consulta = KG")
        n3 += len(ents) >= 3
    check(n3 >= 2, f"[E1] al menos 2 consultas con 3+ entidades ({n3})")
    # Cypher por consulta
    secciones = re.split(r"^### (C-\d{2})", md, flags=re.M)
    for i in range(1, len(secciones), 2):
        cid, cuerpo = secciones[i], secciones[i + 1]
        bloque = re.search(r"```cypher\n(.*?)```", cuerpo, re.S).group(1)
        labels = set(verificar_cypher(f"E1 {cid}", bloque).values())
        labels |= set(re.findall(r"\(\w*:(\w+)", bloque))
        check(labels == set(C[cid]["related_entities"]),
              f"[E1] {cid}: etiquetas del Cypher = entidades de la consulta" + ("" if labels == set(C[cid]["related_entities"]) else f" ({sorted(labels)})"))


# ---------------------------------------------------------------- E2
MAP_NEO = {"UUID": "String", "VARCHAR": "String", "TEXT": "String", "INTEGER": "Integer", "DECIMAL": "Float", "TIMESTAMP": "DateTime"}


def e2(md):
    bloques = re.split(r"^### (E\d{2}) — (\w+)", md, flags=re.M)
    vistos = []
    for i in range(1, len(bloques), 3):
        eid, nom, cuerpo = bloques[i], bloques[i + 1], bloques[i + 2]
        vistos.append(nom)
        check(nom in ENTIDADES and ENTIDADES[nom]["id"] == eid, f"[E2] {eid} {nom} coincide con el KG")
        filas = tabla_con(cuerpo, "Propiedad")[0][1]
        props = {limpiar(f["Propiedad"]): f for f in filas}
        esperadas = {p["name"]: p for p in props_no_fk(nom)}
        check(set(props) == set(esperadas), f"[E2] {nom}: propiedades = KG sin FK" + ("" if set(props) == set(esperadas) else f" (sobran {set(props)-set(esperadas)}, faltan {set(esperadas)-set(props)})"))
        check(len(props) >= 3, f"[E2] {nom}: al menos 3 propiedades ({len(props)})")
        for n, f in props.items():
            if n not in esperadas:
                continue
            p = esperadas[n]
            check(limpiar(f["Tipo (SQL)"]) == p["type"], f"[E2] {nom}.{n}: tipo SQL {p['type']}")
            check(limpiar(f["Tipo Neo4j"]) == MAP_NEO[p["type"].split("(")[0]], f"[E2] {nom}.{n}: tipo Neo4j")
            oblig = limpiar(f["Obligatoria"])
            check(oblig.startswith("No") == bool(p.get("nullable")), f"[E2] {nom}.{n}: obligatoriedad = nullable del KG")
            unica = limpiar(f["Única"])
            debe = bool(p.get("unique") or p.get("primary_key"))
            check(unica.startswith("Sí") == debe, f"[E2] {nom}.{n}: unicidad = KG")
        fks = [p["name"] for p in ENTIDADES[nom]["properties"] if p.get("foreign_key")]
        for fk in fks:
            check(fk in cuerpo, f"[E2] {nom}: FK {fk} explicada como relación")
    check(sorted(vistos) == sorted(ENTIDADES), f"[E2] 12 entidades documentadas ({len(vistos)})")
    for r in RELS:
        for p in r.get("relationship_property_definitions", []):
            check(re.search(rf"\|\s*`?{p['name']}`?\s*\|\s*{re.escape(p['type'])}", md) is not None, f"[E2] propiedad de relación {r['type']}.{p['name']} documentada con tipo {p['type']}")
    for cat in KG["value_catalogs"]:
        if cat["values"]:
            check(all(v in md for v in cat["values"]), f"[E2] catálogo {cat['property']} documentado")


# ---------------------------------------------------------------- E3
def e3(md):
    filas = tabla_con(md, "Relación")[0][1]
    check(len(filas) == 17, f"[E3] 17 relaciones ({len(filas)})")
    por_id = {r["id"]: r for r in RELS}
    for f in filas:
        r = por_id.get(f["ID"])
        check(r is not None, f"[E3] {f['ID']} existe")
        if not r:
            continue
        check((limpiar(f["Entidad origen"]), limpiar(f["Relación"]), limpiar(f["Entidad destino"])) == (r["source"], r["type"], r["target"]), f"[E3] {f['ID']}: origen/tipo/destino = KG")
        check(len(limpiar(f["Descripción"])) > 30, f"[E3] {f['ID']}: tiene descripción")
        esperadas = set(r.get("relationship_properties") or [])
        dadas = set(lista(f["Propiedades"])) - {"—", "-"}
        check(dadas == esperadas, f"[E3] {f['ID']}: propiedades de la relación = KG")


# ---------------------------------------------------------------- E4
CATEGORIAS = ["Unicidad de identificadores", "Propiedades obligatorias", "Valores permitidos", "Consistencia entre entidades", "Reglas de negocio"]


def e4(md):
    filas = tabla_con(md, "Mecanismo")[0][1]
    ids = [limpiar(f["ID"]) for f in filas]
    check(ids == RI_IDS, f"[E4] RI del entregable = KG ({len(ids)})")
    check(len(ids) >= 8, "[E4] al menos 8 restricciones")
    cubiertas = set()
    for f in filas:
        for c in CATEGORIAS:
            if c in f["Categoría"]:
                cubiertas.add(c)
        check(any(c in f["Categoría"] for c in CATEGORIAS), f"[E4] {f['ID']}: categoría válida")
        kg = next(r for r in KG["integrity_constraints"] if r["id"] == limpiar(f["ID"]))
        prop = kg.get("status") == "PROPOSED"
        check(("Propuesta" in f["Estado"]) == prop, f"[E4] {f['ID']}: estado coherente con el KG")
    check(cubiertas == set(CATEGORIAS), f"[E4] las 5 categorías del enunciado cubiertas ({len(cubiertas)})")
    for bloque in re.findall(r"```cypher\n(.*?)```", md, re.S):
        for lab, prop in re.findall(r"FOR \(\w+:(\w+)\) REQUIRE \w+\.(\w+)", bloque):
            check(lab in ENTIDADES and prop in {p["name"] for p in ENTIDADES[lab]["properties"]}, f"[E4] constraint {lab}.{prop} referencia una propiedad existente")


# ---------------------------------------------------------------- E5
def e5(md):
    filas = tabla_con(md, "Origen → destino")[0][1]
    check(len(filas) == 17, f"[E5] 17 relaciones en la tabla de cardinalidades ({len(filas)})")
    por_id = {r["id"]: r for r in RELS}
    for f in filas:
        r = por_id[f["ID"]]
        check(limpiar(f["Origen → destino"]).split(" ")[0] == r["source_cardinality"], f"[E5] {f['ID']}: cardinalidad origen→destino = KG ({r['source_cardinality']})")
        check(limpiar(f["Destino → origen"]).split(" ")[0] == r["target_cardinality"], f"[E5] {f['ID']}: cardinalidad destino→origen = KG ({r['target_cardinality']})")
    preguntas = tabla_con(md, "¿Una o muchas?")[0][1]
    check(len(preguntas) == 17 and all(f["¿Una o muchas?"] and f["Mínimo"] and f["Máximo"] for f in preguntas), "[E5] las 3 preguntas respondidas en las 17 relaciones")
    aisl = tabla_con(md, "¿Puede existir sin relacionarse?")[0][1]
    check(sorted(limpiar(f["Entidad"]) for f in aisl) == sorted(ENTIDADES), "[E5] tabla de existencia sin relaciones cubre las 12 entidades")


# ---------------------------------------------------------------- E6
def e6(md):
    bloque = re.search(r"```mermaid\n(.*?)```", md, re.S).group(1)
    nodos = set(re.findall(r"^\s*(\w+)\[", bloque, re.M))
    check(nodos == set(ENTIDADES), f"[E6] 12 nodos = etiquetas del KG" + ("" if nodos == set(ENTIDADES) else f" ({nodos ^ set(ENTIDADES)})"))
    aristas = re.findall(r"^\s*(\w+)\s*--\s*\"([A-Z_]+)(?:\s*\{[^}]*\})?\s*\[([^\]]+)\]\"\s*-->\s*(\w+)", bloque, re.M)
    trip = {(a, t, b) for a, t, _, b in aristas}
    check(len(aristas) == 17 and trip == TRIPLES, f"[E6] 17 relaciones = KG ({len(aristas)})")
    por_trip = {(r["source"], r["type"], r["target"]): r for r in RELS}
    for a, t, card, b in aristas:
        r = por_trip.get((a, t, b))
        if r:
            esperado = f"{r['source_cardinality']} / {r['target_cardinality']}"
            check(card.strip() == esperado, f"[E6] {r['id']}: cardinalidad en el diagrama = {esperado}")
    for e in ENTIDADES:
        m = re.search(rf"^\s*{e}\[(.*?)\]\s*$", bloque, re.M)
        if m:
            for p in props_no_fk(e):
                check(p["name"] in m.group(1), f"[E6] nodo {e} muestra {p['name']}")


# ---------------------------------------------------------------- E7
def e7(md):
    check("¿Por qué no es suficiente identificar las entidades" in md, "[E7] responde la pregunta 1")
    check("consultas, las restricciones de integridad y las cardinalidades" in md, "[E7] responde la pregunta 2")


ARCHIVOS = {
    1: ("01-requerimientos-consultas.md", e1),
    2: ("02-diccionario-entidades.md", e2),
    3: ("03-catalogo-relaciones.md", e3),
    4: ("04-restricciones-integridad.md", e4),
    5: ("05-cardinalidades.md", e5),
    6: ("06-modelo-logico.md", e6),
    7: ("07-conclusiones.md", e7),
}


def main():
    pedidos = [int(a) for a in sys.argv[1:]] or list(ARCHIVOS)
    for n in pedidos:
        nombre, fn = ARCHIVOS[n]
        ruta = ENT / nombre
        if not ruta.exists():
            avisos.append(f"[E{n}] {nombre} aún no existe")
            continue
        md = ruta.read_text(encoding="utf-8")
        verificar_referencias(f"E{n}", md)
        try:
            fn(md)
        except Exception as ex:  # una estructura inesperada es un fallo, no un crash
            falla(f"[E{n}] error al analizar: {ex!r}")
    for a in avisos:
        print("AVISO ", a)
    for f in fallos:
        print("FALLO ", f)
    print(f"\n{len(oks)} comprobaciones OK, {len(fallos)} fallos, {len(avisos)} avisos")
    sys.exit(1 if fallos else 0)


if __name__ == "__main__":
    main()
