/** PLANTILLA DE RUTAS: un archivo por flujo (contrato §4), solo asocia rutas y controladores. */
import { Router } from 'express';
import type { HealthController } from '../controllers/health.controller.js';

export function healthRoutes(controller: HealthController): Router {
  const router = Router();
  router.get('/health', controller.obtener);
  return router;
}
