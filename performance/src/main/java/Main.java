import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Result;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.stream.Stream;

import static org.neo4j.driver.Values.parameters;

public class Main {

    public static void main(String... args) {
        print("neo4j | point", names().map(n -> cypherQuery(CypherQueries.point(n))));
        print("postgres | point", names().map(n -> postgresQuery(PostgresQueries.point(n))));
        print("neo4j | 1-hop", names().map(n -> cypherQuery(CypherQueries.oneHop(n))));
        print("postgres | 1-hop", names().map(n -> postgresQuery(PostgresQueries.oneHop(n))));
        print("neo4j | 2-hop", names().map(n -> cypherQuery(CypherQueries.twoHop(n))));
        print("postgres | 2-hop", names().map(n -> postgresQuery(PostgresQueries.twoHop(n))));
        print("neo4j | shortest-path", names().limit(10).map(n -> cypherQuery(CypherQueries.shortestPath("Glencore Group", "Marc Rich Real Estate GmbH"))));
        print("postgres | shortest-path", names().limit(10).map(n -> postgresQuery(PostgresQueries.shortestPath("Glencore Group", "Marc Rich Real Estate GmbH"))));
        print("neo4j | subgraph", names().limit(10).map(n -> cypherQuery(CypherQueries.familyRelations())));
        print("postgres | subgraph", names().limit(10).map(n -> postgresQuery(PostgresQueries.familyRelations())));

//        var manualMeasurements = Stream.of(
//                28.137,
//                28.060,
//                27.715,
//                28.348,
//                28.282,
//                28.280,
//                28.138,
//                28.152,
//                28.291,
//                28.335
//        ).map(i -> i * 1_000_000_000);
//        print("postgres | subgraph (manual)", manualMeasurements);
    }

    private static Stream<String> names() {
        return NodeNames.NAMES.stream();
    }

    private static void print(String name, Stream<Double> measurements) {
        var nanoSeconds = measurements.toList();
        System.out.printf(
                "%s: %ss +- %ss (%d measurements)\n",
                name,
                formatNanoSeconds(mean(nanoSeconds)),
                formatNanoSeconds(stddev(nanoSeconds)),
                nanoSeconds.size()
        );
    }

    private static double mean(List<Double> durations) {
        return durations.stream().mapToDouble(i -> i).sum() / (double) durations.size();
    }

    private static double stddev(List<Double> durations) {
        var mean = mean(durations);
        var variance = durations.stream().mapToDouble(i -> Math.pow((i - mean), 2)).sum() / durations.size();
        return Math.sqrt(variance);
    }

    private static String formatNanoSeconds(double nanos) {
        return "%.6f".formatted(nanos / 1_000_000_000);
    }

    private static double cypherQuery(String query) {
        try (var driver = neo4jDriver();
             var session = driver.session()
        ) {
            var start = Instant.now();
            session.readTransaction(tx -> {
                Result result = tx.run(query, parameters());
                // fetch the whole result
                while (result.hasNext()) {
                    result.next();
                }
                return null;
            });
            return Duration.between(start, Instant.now()).toNanos();
        }
    }

    private static double postgresQuery(String query) {
        try (var connection = postgresConnection()) {
            var start = Instant.now();
            try (var statement = connection.createStatement();
                 var resultSet = statement.executeQuery(query)
            ) {
                // fetch the whole result
                while (resultSet.next()) {
                    resultSet.getRow();
                }
            }
            return Duration.between(start, Instant.now()).toNanos();
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        }
    }

    private static Driver neo4jDriver() {
        return GraphDatabase.driver("bolt://localhost:7687", AuthTokens.none());
    }

    private static Connection postgresConnection() throws SQLException {
        return DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "password");
    }
}
