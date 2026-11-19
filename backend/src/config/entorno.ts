/**
 * Configuración externa (guía §7.6): todo sale de variables de entorno, validadas al arrancar.
 * En local se leen de la raíz del repo (.env); en CI llegan como variables del sistema.
 */
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { z } from 'zod';

const ARCHIVO_ENV = fileURLToPath(new URL('../../../.env', import.meta.url));

const puerto = z.coerce.number().int().min(1).max(65535);
const texto = z.string().min(1);

const EsquemaEntorno = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  API_PORT: puerto.default(4000),
  CORS_ORIGEN: z.url().default('http://localhost:3000'),
  DB_TIMEOUT_MS: z.coerce.number().int().positive().default(2000),
  JWT_SECRET: z.string().min(32, 'debe tener al menos 32 caracteres'),

  POSTGRES_HOST: texto,
  POSTGRES_PORT: puerto,
  POSTGRES_DB: texto,
  POSTGRES_USER: texto,
  POSTGRES_PASSWORD: texto,

  MONGO_HOST: texto,
  MONGO_PORT: puerto,
  MONGO_DB: texto,
  MONGO_USER: texto,
  MONGO_PASSWORD: texto,

  NEO4J_HOST: texto,
  NEO4J_BOLT_PORT: puerto,
  NEO4J_USER: texto,
  NEO4J_PASSWORD: z.string().min(8),
});

export type Entorno = z.infer<typeof EsquemaEntorno>;

/**
 * Valida la configuración. Si falta algo, falla con la lista de variables a corregir.
 * Las variables ya definidas en el sistema tienen prioridad sobre el archivo .env.
 */
export function cargarEntorno(fuente: NodeJS.ProcessEnv = process.env): Entorno {
  if (fuente === process.env && existsSync(ARCHIVO_ENV)) process.loadEnvFile(ARCHIVO_ENV);
  const resultado = EsquemaEntorno.safeParse(fuente);
  if (!resultado.success) {
    const lineas = resultado.error.issues.map((i) => `  - ${i.path.join('.')}: ${i.message}`);
    throw new Error(
      `Configuración inválida (revisa tu .env o créalo con npm run setup:env):\n${lineas.join('\n')}`,
    );
  }
  return resultado.data;
}
