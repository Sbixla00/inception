#!/bin/sh
set -eu

echo "Starting Redis..."
exec redis-server /etc/redis.conf --user redis
