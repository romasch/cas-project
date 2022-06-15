public class CypherQueries {

    static String point(String name) {
        return """
                    MATCH (o:Officer)
                    WHERE o.name = '%s'
                    RETURN o;
                """.formatted(name);
    }

    static String oneHop(String name) {
        return """
                    MATCH (o:Officer)-->(a)
                    WHERE o.name = '%s'
                    RETURN o, a;
                """.formatted(name);
    }

    static String twoHop(String name) {
        return """
                    MATCH(o:Officer)-->(a)-->(b)
                    WHERE o.name ='%s'
                    RETURN o, a, b;
                """.formatted(name);
    }

    static String shortestPath(String from, String to) {
        return """
                MATCH
                  (a {name: '%s'}),
                  (b {name: '%s'}),
                  p = shortestPath((a)-[*..10]-(b))
                RETURN p
                """.formatted(from, to);
    }

    static String familyRelations() {
        return """
                MATCH(a:Officer)-[:officer_of]->(entity:Entity) <-[:officer_of]-(b:Officer),
                     (a)-->(address:Address) <--(b)
                RETURN a, b, entity, address
                  LIMIT 20
                """;
    }
}
