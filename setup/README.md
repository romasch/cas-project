# Setup instructions

## Data Import

* Download dump file with `./neo4j-init/download-data.sh`
* `$ docker-compose up neo4j -d`
* Extract CSV file:
    * Open http://localhost:7474/browser/ and log in without authentication
    * Execute `CALL apoc.export.csv.all("panama.csv", {})`
    * `$ docker exec -it setup-neo4j-1 cp /var/lib/neo4j/import/panama.csv /neo4j-init/panama.csv`
* Start Postgres: `$ docker-compose up postgres -d`

## Intellij Setup

* neo4j
    * Install the Graph Database plugin
    * Add a "Neo4j - Bolt" data source
    * Connection is localhost:7687 and empty user field
* Postgres
    * Copy text below and
    * Select Datasources -> + Button -> Import from Clipboard
    * Password is just `password`

```
#DataSourceSettings#
#LocalDataSource: CAS Data
#BEGIN#
<data-source source="LOCAL" name="CAS Data" uuid="b3a26047-22ef-459b-b0fe-36117e375dfb"><database-info product="PostgreSQL" version="14.3 (Debian 14.3-1.pgdg110+1)" jdbc-version="4.2" driver-name="PostgreSQL JDBC Driver" driver-version="42.3.3" dbms="POSTGRES" exact-version="14.3" exact-driver-version="42.3"><identifier-quote-string>&quot;</identifier-quote-string></database-info><case-sensitivity plain-identifiers="lower" quoted-identifiers="exact"/><driver-ref>postgresql</driver-ref><synchronize>true</synchronize><jdbc-driver>org.postgresql.Driver</jdbc-driver><jdbc-url>jdbc:postgresql://localhost:5432/postgres</jdbc-url><secret-storage>master_key</secret-storage><user-name>postgres</user-name><schema-mapping><introspection-scope><node kind="database" qname="@"><node kind="schema" qname="@"/></node></introspection-scope></schema-mapping><working-dir>$ProjectFileDir$</working-dir></data-source>
#END#
```
