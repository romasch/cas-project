--  point query
-- MATCH (o:Officer)
--   WHERE o.name CONTAINS 'Fishman'
-- RETURN o;

select *
from node
where name = 'Fishman - Marcos Shulim'
  and labels = ':Officer';

-- one-hop
-- MATCH (o:Officer)-->(a)
--   WHERE o.name = 'Fishman - Marcos Shulim'
-- RETURN o, a;

select *
from node a
         join edge ab on a.id = ab.node_start
         join node b on ab.node_end = b.id
where a.name = 'Fishman - Marcos Shulim'
  and a.labels = ':Officer';

-- two-hop
-- MATCH (o:Officer)-->(a) -->(b)
--   WHERE o.name = 'Fishman - Marcos Shulim'
-- RETURN o, a, b;

select *
from node a
         join edge ab on a.id = ab.node_start
         join node b on ab.node_end = b.id
         join edge bc on b.id = bc.node_start
         join node c on bc.node_end = c.id
where a.name = 'Fishman - Marcos Shulim'
  and a.labels = ':Officer';

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

with recursive
    edge_both(node_start, node_end) as ( -- takes almost 3.5s of query time
        select distinct *
        from (select node_start, node_end
              from edge
              union
              select node_end, node_start
              from edge) combined),

    path(p_start, p_end, distance, nodes) as (
        select e.node_start, node_end, 1, array [node_start, node_end]
        from edge_both e
        where e.node_start = (select id from node where name = 'Glencore Group') -- Problem: where clause not lifted in CTE expression.
        union all
        select distinct on (path.p_start,e.node_end) path.p_start, -- Problem: Too much search space if distinct is not present.
                                                     e.node_end,
                                                     path.distance + 1,
                                                     path.nodes || e.node_end
        from path
                 join edge_both e on path.p_end = e.node_start
        where e.node_end != any (path.nodes)
          and path.distance < 10 -- Problem: increases computation even if result has been found (no early exit).
    )
select *
from node source
         join path p on (source.id = p.p_start)
         join node target on (p.p_end = target.id)
where target.name = 'Marc Rich Real Estate GmbH'
order by distance
limit 1;

-- MATCH p = (a)-[*]->(b:Entity)
--   WHERE a.name = 'King Salman bin Abdulaziz bin Abdulrahman Al Saud'
-- RETURN *, relationships(p)

with recursive path(p_start, p_end, distance, nodes) as (
    select e.node_start, node_end, 1, array [node_start, node_end]
    from edge e
    where e.node_start = (select id from node where name = 'King Salman bin Abdulaziz bin Abdulrahman Al Saud')
    union all
    select path.p_start,
           e.node_end,
           path.distance + 1,
           path.nodes || e.node_end
    from path
             join edge e on path.p_end = e.node_start
    where e.node_end != any (path.nodes)
      and path.distance < 5
)
select *
from node source
         join path p on (source.id = p.p_start)
         join node target on (p.p_end = target.id);


-- Select "interesting" names
select n.name
from node n
         tablesample system (0.25)
         join edge e on n.id = e.node_start
where n.labels = ':Officer'
group by n.name
having count(e.node_end) > 5
limit 100
