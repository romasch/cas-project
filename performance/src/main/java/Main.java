import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.GraphDatabase;
import org.neo4j.driver.Result;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.time.Duration;
import java.time.Instant;

import static org.neo4j.driver.Values.parameters;

public class Main {

    public static void main(String... args) throws Exception {
        System.out.println(cypherQuery("""
                MATCH (o:Officer)
                  WHERE o.name CONTAINS 'Fishman'
                RETURN o;
                """));

        System.out.println(postgresQuery("""
                select *
                from node
                where name like '%Fishman%';
                """));
    }

    private static Duration cypherQuery(String query) {
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
            return Duration.between(start, Instant.now());
        }
    }

    private static Duration postgresQuery(String query) throws Exception {
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
            return Duration.between(start, Instant.now());
        }
    }

    private static Driver neo4jDriver() {
        return GraphDatabase.driver("bolt://localhost:7687", AuthTokens.none());
    }
    
    private static Connection postgresConnection() throws SQLException {
        return DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "password");
    }
}
