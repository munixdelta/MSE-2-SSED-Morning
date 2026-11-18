#!/usr/bin/env bash
set -euo pipefail
mkdir -p evaluation-output
docker compose exec -T postgres sh -c 'psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB"' <<'SQL'
WITH owner AS (
  INSERT INTO users (name,email,password_hash)
  VALUES ('Persistence check','persistence-check@example.com','test-only')
  ON CONFLICT (email) DO UPDATE SET name=EXCLUDED.name RETURNING id
)
INSERT INTO tasks (user_id,title,description) SELECT id,'CI persistence marker','Must survive container restart' FROM owner;
SQL
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

