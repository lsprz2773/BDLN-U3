/**
 * PLANTILLA DE REPOSITORIO (MongoDB, dueño C). Filtros siempre como objetos, nunca como
 * texto armado con datos del usuario.
 */
import type { Db } from 'mongodb';
import type { ComprobadorBase } from '../../services/health.service.js';

export function crearHealthRepositoryDocumental(db: Db): ComprobadorBase {
  return {
    base: 'documental',
    async ping() {
      await db.command({ ping: 1 });
    },
  };
}
