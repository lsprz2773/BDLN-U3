/**
 * Clientes oficiales de las 3 bases (guía §7.6). Se crean sin conectar: cada driver abre la
 * conexión en la primera consulta. Así la API arranca aunque una base esté caída y lo reporta
 * en /api/health (estado DEGRADADO) en lugar de morir.
 *
 * Solo los repositorios usan estos clientes (convenciones §6.1).
 */
import { MongoClient, type Db } from 'mongodb';
import neo4j, { type Driver } from 'neo4j-driver';
import pg from 'pg';
import type { Entorno } from '../config/entorno.js';

// NUMERIC (puntuaciones, niveles, pesos) llega de pg como texto; la API los devuelve como número.
pg.types.setTypeParser(pg.types.builtins.NUMERIC, (valor) => Number.parseFloat(valor));

export interface Conexiones {
  postgres: pg.Pool;
  mongo: { cliente: MongoClient; db: Db };
  neo4j: Driver;
}

export function crearConexiones(e: Entorno): Conexiones {
  const postgres = new pg.Pool({
    host: e.POSTGRES_HOST,
    port: e.POSTGRES_PORT,
    database: e.POSTGRES_DB,
    user: e.POSTGRES_USER,
    password: e.POSTGRES_PASSWORD,
    max: 10,
    connectionTimeoutMillis: e.DB_TIMEOUT_MS,
  });
  // Un error de un cliente inactivo (p. ej. la base se reinició) no debe tumbar el proceso.
  postgres.on('error', () => undefined);

  const usuario = encodeURIComponent(e.MONGO_USER);
  const clave = encodeURIComponent(e.MONGO_PASSWORD);
  const cliente = new MongoClient(
    `mongodb://${usuario}:${clave}@${e.MONGO_HOST}:${e.MONGO_PORT}/?authSource=admin`,
    { serverSelectionTimeoutMS: e.DB_TIMEOUT_MS, connectTimeoutMS: e.DB_TIMEOUT_MS },
  );

  const driver = neo4j.driver(
    `bolt://${e.NEO4J_HOST}:${e.NEO4J_BOLT_PORT}`,
    neo4j.auth.basic(e.NEO4J_USER, e.NEO4J_PASSWORD),
    {
      connectionTimeout: e.DB_TIMEOUT_MS,
      connectionAcquisitionTimeout: e.DB_TIMEOUT_MS,
      // Enteros de Neo4j como number de JS (convenciones §3), no como objetos Integer.
      disableLosslessIntegers: true,
    },
  );

  return { postgres, mongo: { cliente, db: cliente.db(e.MONGO_DB) }, neo4j: driver };
}

export async function cerrarConexiones(c: Conexiones): Promise<void> {
  await Promise.allSettled([c.postgres.end(), c.mongo.cliente.close(), c.neo4j.close()]);
}
