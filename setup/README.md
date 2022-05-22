# Installation instructions

* Download dump file with `./neo4j-init/download-data.sh`
* `$ docker-compose up`
* Extract CSV file:
    * Open http://localhost:7474/browser/
    * Type `CALL apoc.export.csv.all("panama.csv", {})`
    * `$ docker exec -it setup-neo4j-1 cp /var/lib/neo4j/import/panama.csv /neo4j-init/panama.csv`
