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

echo "↩️  Откат последней миграции (.down.sql)..."

# Получаем последнюю применённую миграцию
version=$($PSQL -t -c "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1;" | xargs)

if [ -z "$version" ]; then
  echo "❌ Нет миграций для отката."
  exit 0
fi

file="$MIGRATIONS_DIR/${version}.down.sql"

if [ ! -f "$file" ]; then
  echo "❌ Файл миграции $file не найден."
  exit 1
fi

echo "🧨 Откатываем $file..."
$PSQL <<EOF
BEGIN;
\i $file
DELETE FROM schema_migrations WHERE version = '$version';
COMMIT;
EOF

echo "✅ Откат выполнен: $file"
