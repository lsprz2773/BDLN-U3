/**
 * PRUEBA DE CONECTIVIDAD (guía §9): el backend se conecta a los 3 motores con la configuración
 * del entorno. Requiere las bases de Docker: npm run db:up
 */
import { Salud } from '@qatok/shared';
import request from 'supertest';
import { afterAll, describe, expect, it } from 'vitest';
import { cargarEntorno } from '../../backend/src/config/entorno.js';
import { crearControladores } from '../../backend/src/contenedor.js';
import {
  cerrarConexiones,
  crearConexiones,
  type Conexiones,
} from '../../backend/src/db/conexiones.js';
import { crearRutas } from '../../backend/src/routes/index.js';
import { appConRutas, loggerSilencioso } from '../apoyo/app-de-prueba.js';

cargarEntorno(); // lee el .env de la raíz hacia process.env

const abiertas: Conexiones[] = [];
function appConEntorno(cambios: Record<string, string> = {}) {
  const entorno = cargarEntorno({ ...process.env, ...cambios });
  const conexiones = crearConexiones(entorno);
  abiertas.push(conexiones);
  return appConRutas(crearRutas(crearControladores(conexiones, entorno, loggerSilencioso)));
}
afterAll(async () => {
  await Promise.all(abiertas.map(cerrarConexiones));
});

describe('conectividad con las 3 bases', () => {
  it('GET /api/health → 200 OK con las 3 bases disponibles', async () => {
    const r = await request(appConEntorno()).get('/api/health');
    const salud = Salud.parse(r.body);
    expect(r.status, JSON.stringify(salud)).toBe(200);
    expect(salud.bases).toMatchObject({
      relacional: { ok: true },
      documental: { ok: true },
      grafo: { ok: true },
    });
  });

  it('con credenciales de Neo4j incorrectas → 503 DEGRADADO y solo el grafo en falla', async () => {
    const r = await request(appConEntorno({ NEO4J_PASSWORD: 'clave-incorrecta' })).get(
      '/api/health',
    );
    expect(r.status).toBe(503);
    expect(r.body.estado).toBe('DEGRADADO');
    expect(r.body.bases.grafo.ok).toBe(false);
    expect(r.body.bases.relacional.ok).toBe(true);
    expect(r.body.bases.documental.ok).toBe(true);
  });

  it('con PostgreSQL en un puerto sin servicio → 503 y la falla se reporta en relacional', async () => {
    const r = await request(appConEntorno({ POSTGRES_PORT: '6' })).get('/api/health');
    expect(r.status).toBe(503);
    expect(r.body.bases.relacional).toMatchObject({ ok: false });
  });
});
