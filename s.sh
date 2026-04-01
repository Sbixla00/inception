#!/bin/bash

# Find all Dockerfiles in subdirectories
find . -type f -name "Dockerfile" | while read -r file; do
    echo "Updating $file..."
    # macOS version: empty string '' after -i for no backup
    sed -i '' 's|alpine:latest|alpine:3.23|g' "$file"
done

echo "All Dockerfiles updated."