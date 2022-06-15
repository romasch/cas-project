public class PostgresQueries {


    static String point(String name) {
        return """
                    select *
                    from node
                    where name = '%s'
                      and labels = ':Officer';
                """.formatted(name);
    }

    static String oneHop(String name) {
        return """
                select *
                from node a
                         join edge ab on a.id = ab.node_start
                         join node b on ab.node_end = b.id
                where a.name = '%s'
                  and a.labels = ':Officer';
                """.formatted(name);
    }

    static String twoHop(String name) {
        return """
                select *
                from node a
                         join edge ab on a.id = ab.node_start
                         join node b on ab.node_end = b.id
                         join edge bc on b.id = bc.node_start
                         join node c on bc.node_end = c.id
                where a.name = '%s'
                  and a.labels = ':Officer';
                """.formatted(name);
    }

    static String shortestPath(String from, String to) {
        return """
                with recursive
                    edge_both(node_start, node_end) as (
                        select distinct *
                        from (select node_start, node_end
                              from edge
                              union
                              select node_end, node_start
                              from edge) combined),
                                
                    path(p_start, p_end, distance, nodes) as (
                        select e.node_start, node_end, 1, array [node_start, node_end]
                        from edge_both e
                        where e.node_start = (select id from node where name = '%s')
                        union all
                        select distinct on (path.p_start,e.node_end) path.p_start,
                                                                     e.node_end,
                                                                     path.distance + 1,
                                                                     path.nodes || e.node_end
                        from path
                                 join edge_both e on path.p_end = e.node_start
                        where e.node_end != any (path.nodes)
                          and path.distance < 10
                    )
                select *
                from node source
                         join path p on (source.id = p.p_start)
                         join node target on (p.p_end = target.id)
                where target.name = '%s'
                order by distance
                limit 1;
                """.formatted(from, to);
    }

    static String familyRelations() {
        return """
                select a.*,
                       b.*,
                       entity.*,
                       address.*
                from node a
                         join edge e1 on a.id = e1.node_start
                         join node entity on e1.node_end = entity.id
                         join edge e2 on e2.node_end = entity.id
                         join node b on e2.node_start = b.id
                         join edge address_a on (address_a.node_start = a.id)
                         join node address on address_a.node_end = address.id
                         join edge address_b on (address_b.node_start = b.id and address_b.node_end = address.id)
                where a.labels = ':Officer'
                  and b.labels = ':Officer'
                  and entity.labels = ':Entity'
                  and e1.type = 'officer_of'
                  and e2.type = 'officer_of'
                  and address.labels = ':Address'
                limit 5;
                """;
    }
}
