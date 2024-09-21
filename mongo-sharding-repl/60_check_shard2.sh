#!/bin/bash

# Check the number of documents in the second shard
echo "Checking document count in shard2..."

docker compose exec -T shard2 mongosh --port 27019 <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Total documents in shard2: " + count);
EOF
