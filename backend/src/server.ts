/**
 * Punto de entrada: carga la configuración, crea las conexiones, arranca el servidor y
 * deja un registro del estado de las 3 bases (evidencia de la prueba de conectividad).
 */
import { crearApp } from './app.js';
import { cargarEntorno } from './config/entorno.js';
import { crearControladores } from './contenedor.js';
import { cerrarConexiones, crearConexiones } from './db/conexiones.js';
import { crearLogger } from './lib/logger.js';
import { crearRutas } from './routes/index.js';

const entorno = cargarEntorno();
const logger = crearLogger(entorno);
const conexiones = crearConexiones(entorno);
const controladores = crearControladores(conexiones, entorno, logger);
const app = crearApp({ rutas: crearRutas(controladores), logger, corsOrigen: entorno.CORS_ORIGEN });

const servidor = app.listen(entorno.API_PORT, async () => {
  logger.info(`API escuchando en http://localhost:${entorno.API_PORT}/api`);
  const respuesta = await fetch(`http://localhost:${entorno.API_PORT}/api/health`);
  logger.info({ salud: await respuesta.json() }, 'estado de las bases al arrancar');
});

async function apagar(senal: string) {
  logger.info(`${senal} recibido: cerrando servidor y conexiones`);
  servidor.close();
  await cerrarConexiones(conexiones);
  process.exit(0);
}
process.on('SIGINT', () => void apagar('SIGINT'));
process.on('SIGTERM', () => void apagar('SIGTERM'));
