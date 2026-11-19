/**
 * PLANTILLA DE SERVICIO. Un servicio aplica reglas y coordina repositorios; no conoce SQL,
 * MQL ni Cypher. Depende de interfaces (aquí ComprobadorBase), no de los drivers, para que
 * las pruebas puedan pasarle repositorios falsos con la misma firma.
 */
import type { EstadoBase, NombreBase, Salud } from '@qatok/shared';
import type { Logger } from '../lib/logger.js';

/** Lo que el servicio necesita de cada repositorio de salud. */
export interface ComprobadorBase {
  base: NombreBase;
  ping(): Promise<void>;
}

export interface HealthService {
  comprobar(): Promise<Salud>;
}

class TiempoAgotado extends Error {}

function conLimite<T>(promesa: Promise<T>, ms: number): Promise<T> {
  let temporizador: NodeJS.Timeout | undefined;
  const limite = new Promise<never>((_, rechazar) => {
    temporizador = setTimeout(() => rechazar(new TiempoAgotado()), ms);
  });
  return Promise.race([promesa, limite]).finally(() => clearTimeout(temporizador));
}

export function crearHealthService(
  comprobadores: ComprobadorBase[],
  opciones: { timeoutMs: number; version: string; logger: Logger },
): HealthService {
  async function medir(c: ComprobadorBase): Promise<EstadoBase> {
    const inicio = performance.now();
    const latencia = () => Math.round(performance.now() - inicio);
    try {
      await conLimite(c.ping(), opciones.timeoutMs);
      return { ok: true, latencia_ms: latencia() };
    } catch (error) {
      const agotado = error instanceof TiempoAgotado;
      opciones.logger.warn({ base: c.base, err: error }, 'base no disponible');
      return {
        ok: false,
        latencia_ms: latencia(),
        error: agotado ? 'TIEMPO_AGOTADO' : 'SIN_CONEXION',
      };
    }
  }

  return {
    async comprobar() {
      const resultados = await Promise.all(
        comprobadores.map(async (c) => [c.base, await medir(c)] as const),
      );
      const bases = Object.fromEntries(resultados) as Salud['bases'];
      const todasOk = resultados.every(([, r]) => r.ok);
      return { estado: todasOk ? 'OK' : 'DEGRADADO', version: opciones.version, bases };
    },
  };
}
