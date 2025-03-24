#!/bin/bash
set -e

# Run shards install if shard.yml exists
if [ -f "shard.yml" ]; then
  echo "Installing Crystal dependencies..."
  shards install
fi

# Execute the command passed to the script
exec "$@"
