#!/bin/bash

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
