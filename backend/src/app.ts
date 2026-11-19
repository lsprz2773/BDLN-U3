/**
 * Arma la aplicación Express sin abrir puertos ni conexiones, para poder probarla con supertest.
 */
import cors from 'cors';
import express, { type Router } from 'express';
import { pinoHttp } from 'pino-http';
import type { Logger } from './lib/logger.js';
import { manejarErrores, rutaNoEncontrada } from './middlewares/errores.middleware.js';

export function crearApp(opciones: { rutas: Router; logger: Logger; corsOrigen: string }) {
  const app = express();
  app.disable('x-powered-by');
  app.use(pinoHttp({ logger: opciones.logger }));
  app.use(cors({ origin: opciones.corsOrigen }));
  app.use(express.json({ limit: '1mb' }));

  app.use('/api', opciones.rutas);

  app.use(rutaNoEncontrada);
  app.use(manejarErrores(opciones.logger));
  return app;
}
