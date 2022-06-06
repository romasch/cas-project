-- MATCH(a:Officer)-[:officer_of]->(entity:Entity) <-[:officer_of]-(b:Officer),
--      (a)-->(address:Address) <--(b)
-- RETURN a, b, entity, address
--   LIMIT 20
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
limit 20;

-- MATCH
-- (a {name: 'Glencore Group'}),
-- (b {name: 'Marc Rich Real Estate GmbH'}),
--   p = shortestPath((a)-[*..10]-(b))
-- RETURN p

WITH RECURSIVE -- too slow
    paths (path_start, path_end, distance) AS (
        SELECT edge.node_start,
               edge.node_end,
               1
        FROM edge
        WHERE edge.node_start <> edge.node_end
        UNION ALL
        SELECT paths.path_start,
               edge.node_end,
               paths.distance + 1
        FROM paths
                 JOIN edge ON paths.path_end = edge.node_start
        WHERE edge.node_start <> edge.node_end
          AND paths.path_start != edge.node_end
          and paths.distance < 5
    ),
    min_paths (path_start, path_end, distance) as (
        select path_start, path_end, min(distance) from paths group by path_start, path_end
    )
select *
from node a
         join min_paths p on a.id = p.path_start
         join node b on p.path_end = b.id
where a.name = 'Glencore Group'
  and b.name like 'Marc Rich%'
  and p.distance < 5;

with recursive path(p_start, p_end, distance, nodes) as (
    select e.node_start, node_end, 1, array [node_start, node_end]
    from edge_mirrored e
    where e.node_start = (select id from node where name = 'Glencore Group') -- Problem: where clause not lifted in CTE expression.
    union all
    SELECT distinct on (path.p_start,e.node_end) path.p_start, -- Problem: Too much search space if distinct is not present.
                                                 e.node_end,
                                                 path.distance + 1,
                                                 path.nodes || e.node_end
    FROM path
             JOIN edge_mirrored e ON path.p_end = e.node_start
    WHERE e.node_end != ANY (path.nodes)
      and path.distance < 6
)
select *
from node source
         join path p on (source.id = p.p_start)
         join node target on (p.p_end = target.id)
where target.name = 'Marc Rich Real Estate GmbH'
limit 1;


-- MATCH p = (a)-[*]->(b:Entity)
--   WHERE a.name = 'King Salman bin Abdulaziz bin Abdulrahman Al Saud'
-- RETURN *, relationships(p)

with recursive path(p_start, p_end, distance, nodes) as (
    select e.node_start, node_end, 1, array [node_start, node_end]
    from edge e
    where e.node_start = (select id from node where name = 'King Salman bin Abdulaziz bin Abdulrahman Al Saud')
    union all
    SELECT path.p_start,
           e.node_end,
           path.distance + 1,
           path.nodes || e.node_end
    FROM path
             JOIN edge e ON path.p_end = e.node_start
    WHERE e.node_end != ANY (path.nodes)
      and path.distance < 5
)
select *
from node source
         join path p on (source.id = p.p_start)
         join node target on (p.p_end = target.id);
