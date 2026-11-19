/**
 * PLANTILLA DE CONTROLADOR. Solo: leer y validar la entrada (esquemas de @qatok/shared con
 * .parse(); un ZodError se convierte en 400), llamar al servicio y dar forma a la respuesta.
 * Express 5 pasa al middleware de errores cualquier excepción de un handler async.
 */
import type { Request, Response } from 'express';
import type { HealthService } from '../services/health.service.js';

export function crearHealthController(servicio: HealthService) {
  return {
    async obtener(_req: Request, res: Response) {
      const salud = await servicio.comprobar();
      res.status(salud.estado === 'OK' ? 200 : 503).json(salud);
    },
  };
}

export type HealthController = ReturnType<typeof crearHealthController>;
