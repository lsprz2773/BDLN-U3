/**
 * Errores de la aplicación (convenciones §5 y §6.5). Un servicio que detecta una violación
 * de una regla de negocio lanza un ErrorApp; el middleware lo convierte al formato de error.
 *
 *   throw new ErrorApp('INTENTO_NO_EN_CURSO', 409, 'El intento ya terminó', { estado });
 */
import type { NombreBase } from '@qatok/shared';

export class ErrorApp extends Error {
  constructor(
    readonly codigo: string,
    readonly estado: number,
    mensaje: string,
    readonly detalles?: Record<string, unknown>,
  ) {
    super(mensaje);
    this.name = 'ErrorApp';
  }
}

export const noEncontrado = (mensaje = 'El recurso no existe') =>
  new ErrorApp('NO_ENCONTRADO', 404, mensaje);

/**
 * Reconoce un fallo de conexión de cualquiera de los 3 drivers y dice de qué base viene,
 * para responder 503 BASE_NO_DISPONIBLE en lugar de 500 (guía §9, prueba de errores).
 */
export function baseNoDisponible(error: unknown): NombreBase | null {
  if (!(error instanceof Error)) return null;
  const { name, message } = error;
  const codigo = (error as { code?: unknown }).code;

  if (name.startsWith('MongoServerSelection') || name === 'MongoNetworkError') return 'documental';
  if (codigo === 'ServiceUnavailable' || codigo === 'SessionExpired') return 'grafo';
  if (
    codigo === 'ECONNREFUSED' ||
    codigo === 'ETIMEDOUT' ||
    codigo === '57P01' || // PostgreSQL: admin_shutdown
    /Connection terminated|timeout exceeded when trying to connect/i.test(message)
  ) {
    return 'relacional';
  }
  return null;
}
