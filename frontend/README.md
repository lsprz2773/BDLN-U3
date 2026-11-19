# frontend/ — interfaz de QATO'K (Next.js)

> **Nota de traspaso (fase 0, paso 0.8).** El esqueleto de la interfaz **no** lo dejó hecho la fase 0: el equipo decidió que lo arme **quien hará el frontend**, porque fue quien eligió Next.js. Esta carpeta solo tiene el `package.json` mínimo del workspace. Es la primera tarea del frontend en el plan (`context/plan-trabajo.md`, perfil C, fase 0 "sin bloqueo") y **no bloquea a nadie**: la API ya funciona sin interfaz.

## Qué hay que hacer (paso 0.8)

1. Crear la app Next.js (App Router + TypeScript) **dentro de esta carpeta**, conservando el nombre del workspace `@qatok/frontend` en `package.json` (el resto del repo lo usa así).
2. Agregar `@qatok/shared` como dependencia (`"@qatok/shared": "*"`) e importar de ahí los tipos y esquemas (`Salud`, `PasoVista`, `Usuario`…). No se redefinen.
   - `shared` exporta código TypeScript sin compilar: en `next.config` hay que agregar `transpilePackages: ['@qatok/shared']`.
3. `lib/api.ts`: cliente que llama a la API usando **solo** `NEXT_PUBLIC_API_URL` (en `.env.example`: `http://localhost:4000/api`). Debe entender el formato de error del contrato (`{ error: { codigo, mensaje, detalles } }`) y mostrar `mensaje` al usuario.
4. Una página inicial que muestre el estado de las 3 bases desde `GET /api/health` (verde/rojo por base). Es la versión visual de la prueba de conectividad.
5. Scripts en `package.json`: `dev` (puerto 3000), `build`, `start`, `typecheck` (`tsc --noEmit`). La raíz ya ejecuta `typecheck` de todos los workspaces, y `npm run lint` y `npm run format:check` incluyen `frontend/`.

## Reglas que no se negocian (convenciones §6.8 y guía §7.6)

- La interfaz **solo** consume la API de `backend/`. ESLint ya bloquea importar `pg`, `mongodb` o `neo4j-driver` aquí.
- **No** usar Route Handlers (`app/api/*`) ni Server Actions como backend.
- **No** hay credenciales de bases en el entorno del frontend: la única variable es `NEXT_PUBLIC_API_URL`.

## Lo que ya está listo del lado de la API

| Qué | Dónde |
|---|---|
| API corriendo en `http://localhost:4000/api` | `npm run db:up` y luego `npm run dev:api` |
| CORS abierto para `http://localhost:3000` | `CORS_ORIGEN` en `.env` |
| Contrato de los 39 endpoints, con ejemplos JSON para simularlos mientras no existan | `docs/api/contrato-v0.md` |
| Tipos y esquemas compartidos | `shared/src/` |
| Formato de error y códigos HTTP | `context/convenciones.md` §5 |
