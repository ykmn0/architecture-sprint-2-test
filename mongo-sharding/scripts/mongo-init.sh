#!/bin/bash

# Initialize the config server replica set
echo "Initializing config server replica set..."

docker compose exec -T configSrv mongosh --port 27017 <<EOF
rs.initiate(
  {
    _id : "config_server",
    configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
EOF

# Initialize the first shard replica set
echo "Initializing shard1 replica set..."

docker compose exec -T shard1 mongosh --port 27018 <<EOF
rs.initiate(
  {
    _id : "shard1",
    members: [
      { _id : 0, host : "shard1:27018" }
    ]
  }
);
EOF

# Initialize the second shard replica set
echo "Initializing shard2 replica set..."

docker compose exec -T shard2 mongosh --port 27019 <<EOF
rs.initiate(
  {
    _id : "shard2",
    members: [
      { _id : 1, host : "shard2:27019" }
    ]
  }
);
EOF

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

# Check the number of documents in the first shard
echo "Checking document count in shard1..."

docker compose exec -T shard1 mongosh --port 27018 <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Total documents in shard1: " + count);
EOF

# Check the number of documents in the second shard
echo "Checking document count in shard2..."

docker compose exec -T shard2 mongosh --port 27019 <<EOF
use somedb;
var count = db.helloDoc.countDocuments();
print("Total documents in shard2: " + count);
EOF
