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

docker compose exec -T shard1-node1 mongosh --port 27018 <<EOF
rs.initiate(
  {
    _id: "shard1",
    members: [
      { _id: 0, host: "shard1-node1:27018" },
      { _id: 1, host: "shard1-node2:27019" },
      { _id: 2, host: "shard1-node3:27020" }
    ]
  }
);
EOF

echo "Shard1 replica set initialized."

# Initialize the second shard replica set
echo "Initializing shard2 replica set..."

docker compose exec -T shard2-node1 mongosh --port 27021 <<EOF
rs.initiate(
  {
    _id: "shard2",
    members: [
      { _id: 0, host: "shard2-node1:27021" },
      { _id: 1, host: "shard2-node2:27022" },
      { _id: 2, host: "shard2-node3:27023" }
    ]
  }
);
EOF

echo "Shard2 replica set initialized."

# Initialize the mongos router, add shards, and insert test data
echo "Initializing mongos router, adding shards, and inserting test data..."

docker compose exec -T mongos_router mongosh --port 27024 <<EOF
sh.addShard("shard1/shard1-node1:27018");
sh.addShard("shard2/shard2-node1:27021");

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

# Check the number of documents in shard1
echo "Checking document count in shard1..."

docker compose exec -T shard1-node1 mongosh --port 27018 <<EOF
use somedb;

var count = db.helloDoc.countDocuments();
print("Total documents in shard1: " + count);
EOF

echo "Document count check in shard1 completed."

# Check the number of documents in shard2
echo "Checking document count in shard2..."

docker compose exec -T shard2-node1 mongosh --port 27021 <<EOF
use somedb;

var count = db.helloDoc.countDocuments();
print("Total documents in shard2: " + count);
EOF

echo "Document count check in shard2 completed."

#!/bin/bash

echo "Creating Redis cluster..."
docker compose exec -T redis_1 \
  bash -c 'echo "yes" | redis-cli --cluster create \
  173.17.0.2:6379 \
  173.17.0.3:6379 \
  173.17.0.4:6379 \
  173.17.0.5:6379 \
  173.17.0.6:6379 \
  173.17.0.7:6379 \
  --cluster-replicas 1'

# Check cluster status
echo "Checking cluster status..."
docker compose exec -T redis_1 redis-cli cluster info
