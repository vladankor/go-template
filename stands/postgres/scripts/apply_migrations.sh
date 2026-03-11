#!/usr/bin/env bash
set -e

CONFIG_FILE=$1
MIGRATIONS_DIR="migrations"

USER=$(yq '.POSTGRES.USER' "$CONFIG_FILE")
PASSWORD=$(yq '.POSTGRES.PASSWORD' "$CONFIG_FILE")
DATABASE=$(yq '.POSTGRES.DATABASE' "$CONFIG_FILE")
PORT=$(yq '.POSTGRES.PORT' "$CONFIG_FILE")

export PGPASSWORD="$PASSWORD"
PSQL="psql -U $USER -d $DATABASE -h localhost -p $PORT -v ON_ERROR_STOP=1"

echo "🚀 Подключение к $DATABASE от пользователя $USER..."

# Таблица версий миграций
$PSQL -c "CREATE TABLE IF NOT EXISTS schema_migrations (version TEXT PRIMARY KEY);"

# Применяем up-файлы
for file in $(ls "$MIGRATIONS_DIR"/*.up.sql 2>/dev/null | sort); do
  version=$(basename "$file" | cut -d'.' -f1)

  applied=$($PSQL -t -c "SELECT 1 FROM schema_migrations WHERE version = '$version';" | xargs)

  if [ "$applied" != "1" ]; then
    echo "🧩 Применяем миграцию $file..."
    $PSQL <<EOF
BEGIN;
\i $file
INSERT INTO schema_migrations (version) VALUES ('$version');
COMMIT;
EOF
    echo "✅ $file применена"
  else
    echo "⏭ $file уже применена"
  fi
done
