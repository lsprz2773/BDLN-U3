# Configuración de GitHub (paso 0.9)

Lo que vive en el repo ya está hecho: `CODEOWNERS` y el CI (`.github/workflows/ci.yml`). Lo que sigue se configura **en GitHub** y requiere permisos de **administrador** del repositorio (`lsprz2773/BDLN-U3`). Hoy solo @lsprz2773 los tiene. Hay que hacerlo **después del primer push** de `develop` con el CI, porque la protección exige el nombre del job.

## 1. Rama por defecto → `develop`

Hoy la rama por defecto es `claude/cool-allen-ni30jv`, así que los PR se abrirían contra ella. En gitflow, el trabajo diario va a `develop`.

```bash
gh repo edit lsprz2773/BDLN-U3 --default-branch develop
```

(o en GitHub: Settings → General → Default branch).

## 2. Proteger `develop` y `main`

| Regla | Valor | Por qué |
|---|---|---|
| Cambios solo por PR | Sí, con 1 aprobación | Convenciones §7: un PR, una revisión |
| Exigir revisión de dueños de código | Sí | Activa `CODEOWNERS`: cambios en una base los aprueba su dueño o su suplente |
| Descartar aprobaciones si llegan commits nuevos | Sí | La aprobación vale para lo que se revisó |
| CI obligatorio | Job `Verificar (lint, tipos, pruebas y 3 bases)`, rama al día con la base | Nada entra a `develop` con pruebas en rojo |
| Push forzado y borrado de la rama | Bloqueados | Proteger el historial |
| Aplicar también a administradores | No | Deja una salida si el CI falla por algo ajeno al código |

Comando (lo corre @lsprz2773, una vez por rama):

```bash
for RAMA in develop main; do
gh api -X PUT "repos/lsprz2773/BDLN-U3/branches/$RAMA/protection" --input - <<JSON
{
  "required_status_checks": { "strict": true, "contexts": ["Verificar (lint, tipos, pruebas y 3 bases)"] },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "require_code_owner_reviews": true,
    "dismiss_stale_reviews": true
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
done
```

Comprobar: `gh api repos/lsprz2773/BDLN-U3/branches/develop/protection --jq '.required_pull_request_reviews'`.

## 3. Pendiente

- **Usuario de GitHub de C:** completar `.github/CODEOWNERS` (las instrucciones están dentro del archivo).
- Que C tenga permiso de escritura en el repo (Settings → Collaborators).
- La plantilla de PR quedó fuera por decisión del equipo.
