/**
 * PLANTILLA DE REPOSITORIO (PostgreSQL, dueño B). Un repositorio solo habla con su base y
 * solo usa consultas parametrizadas ($1, $2…). Devuelve objetos del dominio, nunca filas crudas.
 */
import type { Pool } from 'pg';
import type { ComprobadorBase } from '../../services/health.service.js';

export function crearHealthRepositoryRelacional(pool: Pool): ComprobadorBase {
  return {
    base: 'relacional',
    async ping() {
      await pool.query('SELECT 1');
    },
  };
}
