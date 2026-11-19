/**
 * Logs en JSON con pino (convenciones §6.6). Nunca se registran contraseñas, tokens ni
 * encabezados de autorización: se reemplazan por [OCULTO].
 */
import { pino, type Logger } from 'pino';
import type { Entorno } from '../config/entorno.js';

export function crearLogger(e: Pick<Entorno, 'NODE_ENV'>): Logger {
  return pino({
    level: e.NODE_ENV === 'test' ? 'silent' : 'info',
    redact: {
      paths: [
        'req.headers.authorization',
        'req.headers.cookie',
        '*.contrasena',
        '*.contrasena_hash',
        '*.token',
      ],
      censor: '[OCULTO]',
    },
    ...(e.NODE_ENV === 'development'
      ? { transport: { target: 'pino-pretty', options: { translateTime: 'SYS:HH:MM:ss' } } }
      : {}),
  });
}

export type { Logger };
