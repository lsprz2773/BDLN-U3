# Cómo trabajamos: del tablero al merge

Guía práctica para el día a día: cómo tomar una tarea, hacerla y entregarla. **Regla de oro del equipo: avanzar sin esperar a nadie.** Los issues y el tablero dicen en qué trabaja cada quien; nadie necesita la aprobación de otro para fusionar. Las reglas detalladas están en [`convenciones.md`](convenciones.md) §7; aquí está el **paso a paso**.

| Quién | Perfil | Tus tareas |
|---|---|---|
| @The-Tito | A — Coordinación y grafo | Etiqueta `perfil:A` |
| @lsprz2773 | B — Relacional y seguridad | Etiqueta `perfil:B` |
| @AngelChame | C — Documental e interfaz | Etiqueta `perfil:C` |

Las tareas de los tres llevan la etiqueta `equipo`.

---

## 1. Una sola vez: preparar tu máquina

Necesitas Node.js 22 o superior, Docker Desktop **encendido**, Python 3 y Git.

```bash
git clone git@github.com:lsprz2773/BDLN-U3.git
cd BDLN-U3
git checkout develop
npm install
npm run setup:env      # crea tu .env con contraseñas aleatorias (no se sube a git)
npm run db:up          # levanta PostgreSQL, MongoDB y Neo4j
npm run dev:api        # API en http://localhost:4000/api
```

Abre http://localhost:4000/api/health: las tres bases deben aparecer con `"ok": true`. Si algo falla, revisa la tabla de **Solución de problemas** del [README](../README.md).

Lee también, una vez (unos 30 minutos): [`plan-trabajo.md`](plan-trabajo.md) (tu perfil y tus tareas), [`convenciones.md`](convenciones.md) y la [matriz de propiedad](../docs/modelos/matriz-propiedad.md).

---

## 2. El tablero

**Tablero:** https://github.com/users/The-Tito/projects/1 ("QATO'K — Proyecto final"). Cada tarjeta es un issue del repo, es decir, una tarea del plan.

| Columna (Status) | Significa |
|---|---|
| **Todo** | Pendiente. Aquí empiezan todas |
| **In Progress** | Alguien la está haciendo y ya tiene rama |
| **Done** | Terminada: su PR se fusionó en `develop` |

Cómo leer una tarjeta:

- **Milestone** = la fase (0 a 4), en el orden recomendado. La descripción del milestone dice qué debería estar listo antes de pasar a la siguiente fase. Es una guía, no un candado: si puedes adelantar algo sin depender de otro, adelántalo.
- **Etiquetas:** `perfil:X` dice de quién es; `base:relacional`, `base:documental` y `base:grafo` dicen qué bases toca; `entregable` marca un documento que evalúa el profesor (E1–E8).
- **Cuerpo del issue:** qué hacer y **"Hecho cuando…"**, que es el criterio para darla por terminada.

Para ver solo lo tuyo, filtra el tablero con `assignee:@me` o `label:perfil:B` (cambia la letra).

---

## 3. El ciclo de una tarea

### Paso 1. Toma la tarea
1. En el tablero, elige una tarjeta **tuya**, en **Todo**, de la fase actual.
2. Muévela a **In Progress**.
3. Si vas a tardar más de un día, comenta en el issue qué vas a hacer primero.

### Paso 2. Crea tu rama desde `develop`
```bash
git checkout develop
git pull                                  # siempre parte de lo último
git checkout -b feature/b-esquema-relacional
```
Nombre de la rama: `feature/<tu letra>-<tarea-corta>`, por ejemplo `feature/a-sincronizacion`, `feature/b-esquema-relacional` o `feature/c-validadores-documental`.

### Paso 3. Trabaja con commits pequeños
**Un commit por implementación:** cada commit es un cambio con sentido propio que deja el repo funcionando.

```bash
git add database/relational/schema/01-esquema.sql
git commit -m "relacional: tabla respuesta con secuencia única por intento (RI-16)"
```

Formato: `<ámbito>: <qué cambia, en presente>`. Los ámbitos son `relacional`, `documental`, `grafo`, `backend`, `frontend`, `sync`, `shared`, `pruebas`, `infra` y `docs`.

Mientras trabajas:
- Las consultas (SQL, MQL o Cypher) solo van en `backend/src/repositories/` y en `database/`, **siempre con parámetros**.
- Los tipos se importan de `@qatok/shared`; no los copies.
- Los datos de prueba salen de `database/seed/dataset.json`. Nada se inserta a mano.
- Si necesitas algo que todavía no existe en la base de otro perfil, programa contra un **repositorio falso** con la misma firma (ver `tests/unit/backend/health.service.test.ts`) y no te detengas.

### Paso 4. Verifica antes de subir
```bash
npm run verificar            # lint, formato, tipos, unitarias, dataset y modelo
npm run test:integration     # contra las 3 bases (deben estar arriba: npm run db:up)
```
Si `verificar` se queja del formato: `npm run format`. **No subas nada en rojo**: el CI corre lo mismo y va a fallar igual.

### Paso 5. Sube y abre el pull request
```bash
git push -u origin feature/b-esquema-relacional
gh pr create --base develop      # o desde GitHub: botón "Compare & pull request"
```
En la descripción del PR:
- Qué cambia y por qué, en 2 o 3 líneas.
- Cómo probarlo.
- **`Closes #N`**, donde N es el número del issue. Así, al fusionar, el issue se cierra y la tarjeta pasa sola a **Done**.

**Base del PR: siempre `develop`**, nunca `main` ni otra rama.

### Paso 6. Fusiona tú mismo
**No hay que esperar aprobación** (decisión del equipo): cuando tu PR esté listo, fusiónalo.
- Mira el check **Verificar** (CI). Es un **aviso**, no un bloqueo: si sale en rojo, arréglalo antes de fusionar, salvo que sepas exactamente por qué falla.
- Botón **Merge pull request**, con la opción **"Create a merge commit"** (no "Squash"), para conservar los commits.
- El issue se cierra solo (por el `Closes #N`) y la tarjeta pasa a **Done**.
- Actualiza tu `develop` local: `git checkout develop && git pull`.

¿Quieres una segunda opinión? Pide revisión a quien quieras en el PR (Reviewers). Es opcional, salvo en un caso: si tu PR **cambia un acuerdo** (sección 5), avisa a los otros dos antes de fusionar.

---

## 4. Revisar el PR de un compañero (opcional)

Si alguien te pide opinión:
1. Lee la descripción y el issue que cierra: ¿cumple el "Hecho cuando…"?
2. Si hace falta, bájalo y pruébalo: `git fetch origin && git checkout feature/<rama>` y luego `npm run verificar`.
3. Comenta en GitHub. Para dar el visto bueno: pestaña **Files changed** → **Review changes** → **Approve** → **Submit review**.

---

## 5. Cuando algo no encaja

| Situación | Qué hacer |
|---|---|
| Hay que cambiar un acuerdo (matriz, convenciones, contrato, dataset) | No lo cambies en silencio: abre un PR solo con ese cambio y avisa a los otros dos (menciónalos en el PR) antes de fusionarlo |
| Te bloquea el trabajo de otro perfil | Coméntalo en tu issue mencionándolo (`@usuario`) y sigue con un repositorio falso |
| Encontraste un error fuera de tu tarea | Abre un issue nuevo con su etiqueta de perfil y la fase |
| La tarea es más grande de lo que parecía | Divídela: crea issues hijos y agrégalos al tablero |
| `develop` cambió mientras trabajabas | No es obligatorio actualizar tu rama. Si hay conflictos, en el PR usa **Update branch** o, en local: `git checkout develop && git pull && git checkout <tu-rama> && git merge develop` |
| No sabes qué toca después | Revisa tus tarjetas en **Todo** de la fase actual en el tablero |

---

## 6. Trabajar con Claude en el repo

`CLAUDE.md`, en la raíz, le da a Claude el contexto del proyecto: la arquitectura, las reglas y los comandos. Al pedirle algo:

- Dile **qué issue** estás haciendo (por ejemplo, "voy con el #15").
- Pídele que trabaje **paso a paso**, con un commit por implementación, en tu rama `feature/...`.
- Revisa lo que propone antes de aceptar commits y **nunca le pidas que haga push a `develop` o `main` directamente**: todo entra por PR.

---

## Resumen en una línea

**Tarjeta a In Progress → rama desde `develop` → commits pequeños → `npm run verificar` → PR a `develop` con `Closes #N` → lo fusionas tú (merge commit) → tarjeta en Done.**
