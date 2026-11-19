# Configuración de GitHub

**Decisión del equipo (2026-11-19): avanzar sin candados.** Los issues y el tablero dicen en qué trabaja cada quien; nadie espera la aprobación de otro para fusionar. Por eso **no hay** protección de ramas, `CODEOWNERS` ni plantilla de PR.

## Qué sí hay

| Qué | Dónde | Para qué |
|---|---|---|
| Rama por defecto `develop` | Settings → General | Los PR se abren contra `develop` y el panel Contributors cuenta el trabajo del equipo |
| CI "Verificar" | `.github/workflows/ci.yml` | Corre lint, tipos, pruebas y las 3 bases en cada push y PR. **Es un aviso**: no bloquea el merge |
| Issues + milestones + etiquetas | Pestaña Issues | Una tarea del plan por issue; milestone = fase; `perfil:A/B/C` = de quién es |
| Tablero | GitHub Project «QATO'K — Proyecto final» (cuenta @The-Tito): https://github.com/users/The-Tito/projects/1 | Ver en qué va cada uno (Todo / In Progress / Done) |
| GitGuardian | App instalada en el repo | Avisa si se sube una credencial. Nunca subir `.env` (ya está en `.gitignore`) |

El flujo diario está en [`como-trabajar.md`](como-trabajar.md).

## Quitar la protección de ramas (solo el admin, @lsprz2773)

En GitHub: **Settings → Branches** (o **Settings → Rules → Rulesets**, según cómo se haya creado) → borrar la regla de `develop` y la de `main`.

O por terminal:

```bash
gh api -X DELETE repos/lsprz2773/BDLN-U3/branches/develop/protection
gh api -X DELETE repos/lsprz2773/BDLN-U3/branches/main/protection   # si existe
```

Comprobar: `gh api repos/lsprz2773/BDLN-U3/branches/develop --jq .protected` debe responder `false`.

## Acceso al tablero

El dueño del Project (@The-Tito) da acceso **Write** a @lsprz2773 y @AngelChame en Project → ⋯ → Settings → Manage access, para que puedan mover sus tarjetas.
