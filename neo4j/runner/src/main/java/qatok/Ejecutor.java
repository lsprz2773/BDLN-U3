package qatok;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import org.neo4j.dbms.api.DatabaseManagementService;
import org.neo4j.dbms.api.DatabaseManagementServiceBuilder;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.QueryStatistics;
import org.neo4j.graphdb.Result;
import org.neo4j.graphdb.Transaction;

/**
 * Ejecuta scripts Cypher, en orden, sobre una instancia temporal de Neo4j Community embebida.
 *
 * Convenciones de los scripts:
 *  - Cada sentencia termina con ';' al final de una línea y se ejecuta en su propia transacción.
 *  - Una línea "// ESPERA_ERROR: <texto>" indica que la siguiente sentencia DEBE fallar
 *    (y que el mensaje de error debe contener <texto>). Cuenta como prueba.
 *  - Una sentencia que devuelve las columnas "prueba", "ok" y "detalle" es una prueba de humo:
 *    cada fila con ok = false cuenta como fallo.
 *
 * Uso: mvn -q -f neo4j/runner/pom.xml compile exec:java -Dexec.args="neo4j/01-restricciones.cypher ..."
 * Sale con código 1 si alguna prueba o sentencia falla.
 */
public final class Ejecutor {

    private record Sentencia(String cypher, String esperaError, int linea, String titulo) {}

    private static int pruebas = 0;
    private static int fallos = 0;

    public static void main(String[] args) throws IOException {
        if (args.length == 0) {
            System.err.println("Indica los scripts .cypher a ejecutar, en orden.");
            System.exit(2);
        }
        Path dir = Files.createTempDirectory("qatok-neo4j");
        DatabaseManagementService dbms = new DatabaseManagementServiceBuilder(dir).build();
        try {
            GraphDatabaseService db = dbms.database("neo4j");
            System.out.println("Neo4j embebido listo (Community). Base temporal: " + dir);
            for (String archivo : args) {
                ejecutarArchivo(db, Path.of(archivo));
            }
        } finally {
            dbms.shutdown();
            borrar(dir);
        }
        System.out.printf("%n=== RESUMEN: %d pruebas, %d fallos ===%n", pruebas, fallos);
        System.exit(fallos > 0 ? 1 : 0);
    }

    private static void ejecutarArchivo(GraphDatabaseService db, Path archivo) throws IOException {
        System.out.printf("%n--- %s ---%n", archivo.getFileName());
        for (Sentencia s : leer(Files.readString(archivo, StandardCharsets.UTF_8))) {
            ejecutar(db, s);
        }
    }

    private static List<Sentencia> leer(String texto) {
        List<Sentencia> res = new ArrayList<>();
        StringBuilder actual = new StringBuilder();
        String espera = null;
        String comentario = null;
        int inicio = 0;
        String[] lineas = texto.split("\n", -1);
        for (int i = 0; i < lineas.length; i++) {
            String t = lineas[i].strip();
            if (t.startsWith("// ESPERA_ERROR")) {
                int dos = t.indexOf(':');
                espera = dos >= 0 ? t.substring(dos + 1).strip() : "";
                continue;
            }
            if (t.startsWith("//") && actual.isEmpty()) {
                comentario = t.substring(2).strip();
                continue;
            }
            if (t.startsWith("//") || (t.isEmpty() && actual.isEmpty())) {
                continue;
            }
            if (actual.isEmpty()) {
                inicio = i + 1;
            }
            actual.append(lineas[i]).append('\n');
            if (t.endsWith(";")) {
                String cypher = actual.toString().strip();
                res.add(new Sentencia(cypher.substring(0, cypher.length() - 1), espera, inicio, comentario));
                actual.setLength(0);
                espera = null;
                comentario = null;
            }
        }
        if (!actual.toString().isBlank()) {
            res.add(new Sentencia(actual.toString().strip(), espera, inicio, comentario));
        }
        return res;
    }

    private static void ejecutar(GraphDatabaseService db, Sentencia s) {
        String resumen = s.titulo() != null && !s.titulo().startsWith("=")
                ? s.titulo() : s.cypher().lines().findFirst().orElse("").strip();
        if (resumen.length() > 90) {
            resumen = resumen.substring(0, 87) + "...";
        }
        List<Map<String, Object>> filas = new ArrayList<>();
        QueryStatistics est;
        try (Transaction tx = db.beginTx()) {
            Result r = tx.execute(s.cypher());
            while (r.hasNext()) {
                filas.add(r.next());
            }
            est = r.getQueryStatistics();
            tx.commit();
        } catch (RuntimeException ex) {
            String msg = mensaje(ex);
            if (s.esperaError() != null) {
                pruebas++;
                boolean ok = msg.toLowerCase().contains(s.esperaError().toLowerCase());
                if (!ok) {
                    fallos++;
                }
                System.out.printf("  [%s] línea %d: falla como se esperaba (%s)%n", ok ? "OK" : "FALLO", s.linea(),
                        ok ? "\"" + s.esperaError() + "\"" : "mensaje inesperado: " + msg);
            } else {
                fallos++;
                System.out.printf("  [ERROR] línea %d: %s%n          %s%n", s.linea(), resumen, msg);
            }
            return;
        }
        if (s.esperaError() != null) {
            pruebas++;
            fallos++;
            System.out.printf("  [FALLO] línea %d: se esperaba un error y la sentencia se ejecutó: %s%n", s.linea(), resumen);
            return;
        }
        if (filas.isEmpty() && s.cypher().contains("AS prueba")) {
            pruebas++;
            fallos++;
            System.out.printf("  [FALLO] línea %d: la prueba no devolvió ninguna fila: %s%n", s.linea(), resumen);
            return;
        }
        if (!filas.isEmpty() && filas.get(0).containsKey("prueba") && filas.get(0).containsKey("ok")) {
            for (Map<String, Object> f : filas) {
                pruebas++;
                boolean ok = Boolean.TRUE.equals(f.get("ok"));
                if (!ok) {
                    fallos++;
                }
                System.out.printf("  [%s] %s — %s%n", ok ? "OK" : "FALLO", f.get("prueba"), f.getOrDefault("detalle", ""));
            }
            return;
        }
        StringBuilder cambios = new StringBuilder();
        anotar(cambios, "nodos creados", est.getNodesCreated());
        anotar(cambios, "relaciones creadas", est.getRelationshipsCreated());
        anotar(cambios, "propiedades", est.getPropertiesSet());
        anotar(cambios, "etiquetas", est.getLabelsAdded());
        anotar(cambios, "restricciones creadas", est.getConstraintsAdded());
        anotar(cambios, "índices creados", est.getIndexesAdded());
        anotar(cambios, "nodos borrados", est.getNodesDeleted());
        anotar(cambios, "relaciones borradas", est.getRelationshipsDeleted());
        if (cambios.isEmpty() && !filas.isEmpty()) {
            cambios.append(filas.size()).append(" fila(s): ").append(filas.size() <= 3 ? filas : filas.subList(0, 3) + " ...");
        }
        System.out.printf("  [ok] línea %d: %s%s%n", s.linea(), resumen, cambios.isEmpty() ? "" : "  → " + cambios);
    }

    private static void anotar(StringBuilder sb, String que, int n) {
        if (n > 0) {
            if (!sb.isEmpty()) {
                sb.append(", ");
            }
            sb.append(n).append(' ').append(que);
        }
    }

    private static String mensaje(Throwable ex) {
        Throwable t = ex;
        while (t.getCause() != null && t.getCause() != t) {
            t = t.getCause();
        }
        String m = String.valueOf(ex.getMessage());
        return (m + (t != ex ? " | " + t.getMessage() : "")).replace('\n', ' ');
    }

    private static void borrar(Path dir) throws IOException {
        try (Stream<Path> s = Files.walk(dir)) {
            s.sorted(Comparator.reverseOrder()).forEach(p -> p.toFile().delete());
        }
    }
}
