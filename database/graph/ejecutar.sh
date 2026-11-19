#!/usr/bin/env bash
# Ejecuta todo el ciclo sobre una base Neo4j Community embebida y temporal:
# restricciones → índices → nodos → relaciones → pruebas de humo → limpieza.
# Requiere Java 21 y Maven. Sale con código 1 si alguna prueba falla.
set -euo pipefail
cd "$(dirname "$0")/../.."
export MAVEN_OPTS="${MAVEN_OPTS:-} -Dstdout.encoding=UTF-8 -Dfile.encoding=UTF-8"
mvn -q -f database/graph/runner/pom.xml compile exec:java -Dexec.args="\
database/graph/01-restricciones.cypher \
database/graph/02-indices.cypher \
database/graph/03-nodos-ejemplo.cypher \
database/graph/04-relaciones-ejemplo.cypher \
database/graph/05-pruebas-humo.cypher \
database/graph/06-limpieza.cypher"
