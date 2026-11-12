#!/usr/bin/env bash
# Ejecuta todo el ciclo sobre una base Neo4j Community embebida y temporal:
# restricciones → índices → nodos → relaciones → pruebas de humo → limpieza.
# Requiere Java 21 y Maven. Sale con código 1 si alguna prueba falla.
set -euo pipefail
cd "$(dirname "$0")/.."
export MAVEN_OPTS="${MAVEN_OPTS:-} -Dstdout.encoding=UTF-8 -Dfile.encoding=UTF-8"
mvn -q -f neo4j/runner/pom.xml compile exec:java -Dexec.args="\
neo4j/01-restricciones.cypher \
neo4j/02-indices.cypher \
neo4j/03-nodos-ejemplo.cypher \
neo4j/04-relaciones-ejemplo.cypher \
neo4j/05-pruebas-humo.cypher \
neo4j/06-limpieza.cypher"
