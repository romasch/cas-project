// family relations
MATCH(a:Officer)-[:OFFICER_OF]->(e:Entity) <-[:OFFICER_OF]-(b:Officer)
  WHERE apoc.text.levenshteinDistance(a.name, b.name) < size(a.name) * 0.75
RETURN a, e, b
  LIMIT 20

MATCH(a:Officer)-[:OFFICER_OF]->(e:Entity) <-[:OFFICER_OF]-(b:Officer),
     (a)--(b)
  WHERE a.name <> b.name
RETURN a, e, b
  LIMIT 20

MATCH(a:Officer)-[:officer_of]->(entity:Entity) <-[:officer_of]-(b:Officer),
     (a)-->(address:Address) <--(b)
RETURN a, b, entity, address
  LIMIT 20

// shortest path
MATCH
  (a {name: 'Glencore Group'}),
  (b {name: 'Renaissance Group'}),
  p = shortestPath((a)-[*..15]-(b))
RETURN p
  LIMIT 1

MATCH
  (a {name: 'Glencore Group'}),
  (b),
  p = shortestPath((a)-[*..10]-(b))
  WHERE b.name CONTAINS 'Marc Rich'
RETURN p
  LIMIT 5

MATCH
  (a {name: 'Glencore Group'}),
  (b {name: 'Marc Rich Real Estate GmbH'}),
  p = shortestPath((a)-[*..10]-(b))
RETURN p

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


