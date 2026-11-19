/**
 * Raíz de composición: aquí, y solo aquí, se crean repositorios, servicios y controladores
 * y se conectan entre sí. Cada dueño agrega las líneas de su flujo en su bloque.
 */
import type { Entorno } from './config/entorno.js';
import { crearHealthController } from './controllers/health.controller.js';
import type { Conexiones } from './db/conexiones.js';
import type { Logger } from './lib/logger.js';
import { crearHealthRepositoryDocumental } from './repositories/document/health.repository.js';
import { crearHealthRepositoryGrafo } from './repositories/graph/health.repository.js';
import { crearHealthRepositoryRelacional } from './repositories/relational/health.repository.js';
import { crearHealthService } from './services/health.service.js';
import paquete from '../package.json' with { type: 'json' };

export function crearControladores(conexiones: Conexiones, entorno: Entorno, logger: Logger) {
  // ---- Salud (A) ----
  const health = crearHealthController(
    crearHealthService(
      [
        crearHealthRepositoryRelacional(conexiones.postgres),
        crearHealthRepositoryDocumental(conexiones.mongo.db),
        crearHealthRepositoryGrafo(conexiones.neo4j),
      ],
      { timeoutMs: entorno.DB_TIMEOUT_MS, version: paquete.version, logger },
    ),
  );

  // ---- F1 Cuenta, habilidades, catálogo (B) ----
  // ---- F2 Jugar (C) ----
  // ---- F3a Perfil y evidencias (A) ----
  // ---- F3b Compartir (B) ----

  return { health };
}

export type Controladores = ReturnType<typeof crearControladores>;
