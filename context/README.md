# context/ — empieza aquí

Esta carpeta reúne lo que el equipo necesita para **trabajar**: la guía del profesor, el plan, las reglas y los antecedentes. Lo que el profesor **evalúa** (entregables E1–E8) vive en `docs/`, organizado como pide la guía (§10).

| ¿Dónde va un archivo nuevo? | Carpeta |
|---|---|
| ¿Lo va a calificar el profesor como parte de E1–E8? | `docs/` |
| ¿Solo nos ayuda a entender o a coordinarnos? | `context/` |

## Orden de lectura

**Todos (unos 30 minutos):**
1. [`plan-trabajo.md`](plan-trabajo.md): busca tu perfil en la sección 1 y tus tareas en la sección 4.
2. [`como-trabajar.md`](como-trabajar.md): **el paso a paso del día a día**: preparar tu máquina, usar el tablero, ramas, commits, PR y revisión.
3. [`convenciones.md`](convenciones.md): nombres, ids, fechas, valores permitidos, API y git.
4. [`../docs/modelos/matriz-propiedad.md`](../docs/modelos/matriz-propiedad.md): qué dato vive en qué base. **Es la base de todo.**

**Después, según tu perfil:**

| Perfil | Lee además |
|---|---|
| A — Grafo | `../docs/modelos/analisis-matriz.md`, `../database/graph/README.md`, `../entregables/03` a `06` (modelo de grafo de la actividad anterior) |
| B — Relacional | `../entregables/02-diccionario-entidades.md` (tipos SQL) y `../entregables/04-restricciones-integridad.md` (RI-01 a RI-25) |
| C — Documental e interfaz | `../entregables/01-requerimientos-consultas.md` (RF y consultas) y `../presentacion/qatok-explicado.md` (el proyecto explicado) |

**Si tienes una duda de criterio:** [`guia/Guia_Proyecto_Final_Bases_Datos.pdf`](guia/Guia_Proyecto_Final_Bases_Datos.pdf). Manda la guía.

## Contenido

| Archivo | Qué es |
|---|---|
| `plan-trabajo.md` | Plan vigente: perfiles, fases, tareas, dependencias |
| `como-trabajar.md` | Guía práctica: del tablero al merge |
| `convenciones.md` | Reglas comunes que todos siguen |
| `github.md` | Configuración de GitHub: rama por defecto, CI y por qué no hay protección de ramas |
| `guia/` | Guía del proyecto final del profesor |
| `antecedentes/Reporte_Auditoria_BDLN-U3.pdf` | Auditoría v1 del estado del repo |
| `antecedentes/auditoria-v2.md` | Auditoría v2: confirma y corrige la v1 |
| `antecedentes/plan-reparto.md` | Por qué se eligió el reparto "dueño de base + dueño de flujo" (alternativas y pre-mortem) |

## Fuera de esta carpeta, pero útil

| Ruta | Qué es |
|---|---|
| `docs/KG.json` | Grafo de conocimiento del proyecto: fuente de verdad del dominio (lo valida `scripts/verificar.py`) |
| `docs/decisiones-modelado.md` | Decisiones DEC-01 en adelante |
| `entregables/`, `verificacion/`, `presentacion/` | Actividad anterior (modelo lógico de grafos). Es antecedente, no se edita salvo para corregir |
| `database/graph/` | Scripts Cypher de la actividad anterior (modelo previo a la matriz v2); A los adapta en la fase 1 |
