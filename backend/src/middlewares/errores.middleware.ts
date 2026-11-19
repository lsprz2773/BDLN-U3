/**
 * Convierte cualquier error en el formato de la API (convenciones §5):
 *   { "error": { "codigo", "mensaje", "detalles"? } }
 * El detalle técnico de un error inesperado solo va al log, nunca a la respuesta.
 */
import type { ErrorRespuesta } from '@qatok/shared';
import type { ErrorRequestHandler, RequestHandler } from 'express';
import { ZodError } from 'zod';
import { baseNoDisponible, ErrorApp } from '../lib/errores.js';
import type { Logger } from '../lib/logger.js';

const cuerpo = (codigo: string, mensaje: string, detalles?: Record<string, unknown>) =>
  ({ error: { codigo, mensaje, ...(detalles ? { detalles } : {}) } }) satisfies ErrorRespuesta;

export const rutaNoEncontrada: RequestHandler = (req) => {
  throw new ErrorApp('NO_ENCONTRADO', 404, `La ruta ${req.method} ${req.path} no existe`);
};

export function manejarErrores(logger: Logger): ErrorRequestHandler {
  return (error: unknown, _req, res, _next) => {
    if (error instanceof ErrorApp) {
      res.status(error.estado).json(cuerpo(error.codigo, error.message, error.detalles));
      return;
    }
    if (error instanceof ZodError) {
      const campos = error.issues.map((i) => ({ campo: i.path.join('.'), mensaje: i.message }));
      res.status(400).json(cuerpo('VALIDACION', 'Datos de entrada inválidos', { campos }));
      return;
    }
    // JSON mal formado en el cuerpo (lo lanza express.json()).
    if (
      error instanceof SyntaxError &&
      (error as { type?: string }).type === 'entity.parse.failed'
    ) {
      res.status(400).json(cuerpo('VALIDACION', 'El cuerpo no es un JSON válido'));
      return;
    }
    const base = baseNoDisponible(error);
    if (base) {
      logger.error({ err: error, base }, 'base no disponible');
      res
        .status(503)
        .json(cuerpo('BASE_NO_DISPONIBLE', 'Un servicio de datos no está disponible', { base }));
      return;
    }
    logger.error({ err: error }, 'error no previsto');
    res.status(500).json(cuerpo('ERROR_INTERNO', 'Ocurrió un error inesperado'));
  };
}
