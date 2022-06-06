#!/bin/bash
set -euo pipefail
# IFS=$'\n\t'

# do not run init script at each container strat but only at the first start
if [ ! -f /tmp/neo4j-import-done.flag ]; then
    /var/lib/neo4j/bin/neo4j-admin load --from /neo4j-init/neo4j.dump
    chown -R neo4j:neo4j /data/databases
    touch /tmp/neo4j-import-done.flag
else
    echo "The import has already been made."
fi 
