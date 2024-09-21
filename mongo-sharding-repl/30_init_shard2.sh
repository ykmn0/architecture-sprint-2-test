#!/bin/bash

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
