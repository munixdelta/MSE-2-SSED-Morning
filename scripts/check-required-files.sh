#!/usr/bin/env bash
set -euo pipefail
for file in frontend/Dockerfile backend/Dockerfile docker-compose.yml docker-compose.deploy.yml submission.json; do
  test -s "$file" || { echo "Missing required file: $file"; exit 1; }
done
docker compose config --quiet
docker compose -f docker-compose.deploy.yml config --quiet
echo "Required files and Compose configurations verified"

