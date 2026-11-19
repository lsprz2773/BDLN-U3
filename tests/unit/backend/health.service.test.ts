/**
 * Ejemplo del patrón para el equipo: el servicio se prueba con repositorios FALSOS que
 * cumplen la misma interfaz, sin levantar ninguna base.
 */
import { Salud } from '@qatok/shared';
import { describe, expect, it } from 'vitest';
import {
  crearHealthService,
  type ComprobadorBase,
} from '../../../backend/src/services/health.service.js';
import { loggerSilencioso } from '../../apoyo/app-de-prueba.js';

const sano = (base: ComprobadorBase['base']): ComprobadorBase => ({ base, ping: async () => {} });
const caido = (base: ComprobadorBase['base']): ComprobadorBase => ({
  base,
  ping: async () => {
    throw new Error('ECONNREFUSED');
  },
});
const colgado = (base: ComprobadorBase['base']): ComprobadorBase => ({
  base,
  ping: () => new Promise(() => {}),
});

const servicio = (comprobadores: ComprobadorBase[]) =>
  crearHealthService(comprobadores, { timeoutMs: 50, version: 'prueba', logger: loggerSilencioso });

describe('HealthService', () => {
  it('responde OK cuando las 3 bases contestan, con el formato del contrato', async () => {
    const salud = await servicio([
      sano('relacional'),
      sano('documental'),
      sano('grafo'),
    ]).comprobar();
    expect(Salud.parse(salud)).toEqual(salud);
    expect(salud.estado).toBe('OK');
    expect(Object.values(salud.bases).every((b) => b.ok)).toBe(true);
  });

  it('marca DEGRADADO y SIN_CONEXION si una base rechaza la conexión', async () => {
    const salud = await servicio([
      sano('relacional'),
      caido('documental'),
      sano('grafo'),
    ]).comprobar();
    expect(salud.estado).toBe('DEGRADADO');
    expect(salud.bases.documental).toMatchObject({ ok: false, error: 'SIN_CONEXION' });
    expect(salud.bases.relacional?.ok).toBe(true);
  });

  it('no se queda esperando a una base colgada: TIEMPO_AGOTADO al cumplirse el límite', async () => {
    const inicio = Date.now();
    const salud = await servicio([
      sano('relacional'),
      sano('documental'),
      colgado('grafo'),
    ]).comprobar();
    expect(Date.now() - inicio).toBeLessThan(1000);
    expect(salud.bases.grafo).toMatchObject({ ok: false, error: 'TIEMPO_AGOTADO' });
  });
});
