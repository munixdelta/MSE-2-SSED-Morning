#!/usr/bin/env bash
set -euo pipefail
mkdir -p evaluation-output
snapshot() {
  docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -At -c "SELECT id,user_id,title,description,status FROM tasks ORDER BY id"'
}
snapshot > evaluation-output/tasks-before.txt
test -s evaluation-output/tasks-before.txt
docker compose down
docker compose up -d --wait --wait-timeout 120
snapshot > evaluation-output/tasks-after.txt
diff -u evaluation-output/tasks-before.txt evaluation-output/tasks-after.txt
echo "PASS: PostgreSQL task data persisted across Compose down/up"

