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
