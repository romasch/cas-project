// point query
MATCH (o:Officer)
  WHERE o.name = 'Fishman - Marcos Shulim'
RETURN o;

// one-hop
MATCH (o:Officer)-->(a)
  WHERE o.name = 'Fishman - Marcos Shulim'
RETURN o, a;

// two-hop
MATCH (o:Officer)-->(a) -->(b)
  WHERE o.name = 'Fishman - Marcos Shulim'
RETURN o, a, b;

// shortest path
MATCH
  (a {name: 'Glencore Group'}),
  (b {name: 'Marc Rich Real Estate GmbH'}),
  p = shortestPath((a)-[*..10]-(b))
RETURN p

// family relations
MATCH(a:Officer)-[:officer_of]->(entity:Entity) <-[:officer_of]-(b:Officer),
     (a)-->(address:Address) <--(b)
RETURN a, b, entity, address
  LIMIT 20

// transitive match
MATCH(a)-[*1..5]->(b:Entity)
  WHERE a.name ENDS WITH 'Marcos Manotoc'
RETURN a, b

MATCH p = (a)-[*]->(b:Entity)
  WHERE a.name = 'King Salman bin Abdulaziz bin Abdulrahman Al Saud'
RETURN *, relationships(p)

MATCH p = (a)-[*1..5]->(b) // crashes without limit...
  WHERE a.name = 'Portcullis TrustNet (BVI) Limited'
RETURN *, relationships(p)
