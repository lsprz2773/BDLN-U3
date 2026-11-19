/**
 * PLANTILLA DE REPOSITORIO (Neo4j, dueño A). Cypher siempre con parámetros ($idUsuario),
 * nunca concatenando valores en el texto de la consulta.
 */
import type { Driver } from 'neo4j-driver';
import type { ComprobadorBase } from '../../services/health.service.js';

export function crearHealthRepositoryGrafo(driver: Driver): ComprobadorBase {
  return {
    base: 'grafo',
    async ping() {
      await driver.executeQuery('RETURN 1 AS ok');
    },
  };
}
