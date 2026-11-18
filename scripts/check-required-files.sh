#!/usr/bin/env bash
set -euo pipefail
for file in frontend/Dockerfile backend/Dockerfile docker-compose.yml docker-compose.deploy.yml submission.json; do
  test -s "$file" || { echo "Missing required file: $file"; exit 1; }
done
echo "Required files verified; workflow validates Compose after creating its environment"

