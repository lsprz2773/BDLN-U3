/** El formato de error de la API (convenciones §5) es el mismo para todos los casos. */
import { ErrorRespuesta } from '@qatok/shared';
import { Router } from 'express';
import request from 'supertest';
import { describe, expect, it } from 'vitest';
import { z } from 'zod';
import { ErrorApp } from '../../../backend/src/lib/errores.js';
import { appConRutas } from '../../apoyo/app-de-prueba.js';

const rutas = Router();
rutas.get('/negocio', () => {
  throw new ErrorApp('INTENTO_NO_EN_CURSO', 409, 'El intento ya terminó', { estado: 'COMPLETADO' });
});
rutas.post('/validar', (req, res) => {
  const entrada = z.object({ nombre: z.string().min(1) }).parse(req.body);
  res.json(entrada);
});
rutas.get('/inesperado', () => {
  throw new Error('detalle interno que no debe salir');
});
rutas.get('/neo4j-caido', () => {
  throw Object.assign(new Error('Could not perform discovery'), { code: 'ServiceUnavailable' });
});
const app = appConRutas(rutas);

describe('middleware de errores', () => {
  it('ErrorApp → su código HTTP y su código de negocio', async () => {
    const r = await request(app).get('/api/negocio');
    expect(r.status).toBe(409);
    expect(ErrorRespuesta.parse(r.body).error).toEqual({
      codigo: 'INTENTO_NO_EN_CURSO',
      mensaje: 'El intento ya terminó',
      detalles: { estado: 'COMPLETADO' },
    });
  });

  it('ZodError → 400 VALIDACION con los campos', async () => {
    const r = await request(app).post('/api/validar').send({ nombre: '' });
    expect(r.status).toBe(400);
    expect(r.body.error.codigo).toBe('VALIDACION');
    expect(r.body.error.detalles.campos[0].campo).toBe('nombre');
  });

  it('JSON mal formado → 400 VALIDACION', async () => {
    const r = await request(app)
      .post('/api/validar')
      .set('Content-Type', 'application/json')
      .send('{malo');
    expect(r.status).toBe(400);
    expect(r.body.error.codigo).toBe('VALIDACION');
  });

  it('error inesperado → 500 sin filtrar el detalle', async () => {
    const r = await request(app).get('/api/inesperado');
    expect(r.status).toBe(500);
    expect(r.body.error.codigo).toBe('ERROR_INTERNO');
    expect(JSON.stringify(r.body)).not.toContain('detalle interno');
  });

  it('fallo de conexión de un driver → 503 BASE_NO_DISPONIBLE con la base', async () => {
    const r = await request(app).get('/api/neo4j-caido');
    expect(r.status).toBe(503);
    expect(r.body.error).toMatchObject({
      codigo: 'BASE_NO_DISPONIBLE',
      detalles: { base: 'grafo' },
    });
  });

  it('ruta inexistente → 404 NO_ENCONTRADO', async () => {
    const r = await request(app).get('/api/no-existe');
    expect(r.status).toBe(404);
    expect(r.body.error.codigo).toBe('NO_ENCONTRADO');
  });
});
