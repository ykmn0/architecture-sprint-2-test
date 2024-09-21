#!/bin/bash

# Check the number of documents in shard2
echo "Checking document count in shard2..."

docker compose exec -T shard2-node1 mongosh --port 27021 <<EOF
use somedb;

var count = db.helloDoc.countDocuments();
print("Total documents in shard2: " + count);
EOF

echo "Document count check in shard2 completed."
