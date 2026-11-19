#!/usr/bin/env node
/**
 * Crea .env a partir de .env.example y genera valores aleatorios para los secretos
 * (contraseñas de las bases y JWT_SECRET). Así ninguna credencial queda escrita en el repo.
 *
 *   npm run setup:env              crea .env (no sobrescribe uno existente)
 *   npm run setup:env -- --forzar  lo reemplaza (las bases ya creadas conservan la contraseña
 *                                  anterior: después ejecuta npm run db:reset)
 */
import { randomBytes } from 'node:crypto';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const raiz = fileURLToPath(new URL('..', import.meta.url));
const ejemplo = `${raiz}.env.example`;
const destino = `${raiz}.env`;
const SECRETOS = ['POSTGRES_PASSWORD', 'MONGO_PASSWORD', 'NEO4J_PASSWORD', 'JWT_SECRET'];

if (existsSync(destino) && !process.argv.includes('--forzar')) {
  console.log('.env ya existe; no se modificó. Para regenerarlo: npm run setup:env -- --forzar');
  process.exit(0);
}

const generados = [];
const contenido = readFileSync(ejemplo, 'utf8')
  .split('\n')
  .map((linea) => {
    const [clave] = linea.split('=');
    if (!SECRETOS.includes(clave) || linea.trim().startsWith('#')) return linea;
    // Hexadecimal: sin caracteres que haya que escapar en URLs de conexión.
    const bytes = clave === 'JWT_SECRET' ? 32 : 16;
    generados.push(clave);
    return `${clave}=${randomBytes(bytes).toString('hex')}`;
  })
  .join('\n');

const faltan = SECRETOS.filter((s) => !generados.includes(s));
if (faltan.length) {
  console.error(`.env.example no tiene las claves: ${faltan.join(', ')}`);
  process.exit(1);
}

writeFileSync(destino, contenido, { mode: 0o600 });
console.log(`.env creado con valores aleatorios para: ${generados.join(', ')}`);
