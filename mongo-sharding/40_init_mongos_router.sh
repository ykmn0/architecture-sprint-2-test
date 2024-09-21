#!/bin/bash

# Initialize the mongos router, add shards, and insert test data
echo "Initializing mongos router, adding shards, and inserting test data..."

docker compose exec -T mongos_router mongosh --port 27020 <<EOF
sh.addShard("shard1/shard1:27018");
sh.addShard("shard2/shard2:27019");

sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" });

use somedb;

for (var i = 0; i < 1000; i++) {
  db.helloDoc.insert({ age: i, name: "ly" + i });
}

var count = db.helloDoc.countDocuments();
print("Total documents in 'helloDoc' collection: " + count);
EOF

echo "Shards added and test data inserted."
