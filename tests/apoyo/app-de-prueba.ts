/** Arma la app real para pruebas, con el logger en silencio. */
import { Router } from 'express';
import { crearApp } from '../../backend/src/app.js';
import { crearLogger } from '../../backend/src/lib/logger.js';

export const loggerSilencioso = crearLogger({ NODE_ENV: 'test' });

export function appConRutas(rutas: Router = Router()) {
  return crearApp({ rutas, logger: loggerSilencioso, corsOrigen: 'http://localhost:3000' });
}
