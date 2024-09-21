#!/bin/bash

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
