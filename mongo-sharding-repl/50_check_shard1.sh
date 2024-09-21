#!/bin/bash

# Check the number of documents in shard1
echo "Checking document count in shard1..."

docker compose exec -T shard1-node1 mongosh --port 27018 <<EOF
use somedb;

var count = db.helloDoc.countDocuments();
print("Total documents in shard1: " + count);
EOF

echo "Document count check in shard1 completed."
