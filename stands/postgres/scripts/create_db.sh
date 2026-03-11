#!/bin/bash
set -e

CONFIG_FILE="$1"
CONTAINER_NAME="pg-multi"

# Проверка наличия yq
if ! command -v yq &> /dev/null; then
  echo "❌ Требуется yq (https://github.com/mikefarah/yq); установка (brew install yq)"
  exit 1
fi

# Проверка конфигурационного файла
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Конфигурационный файл '$CONFIG_FILE' не найден"
  exit 1
fi

# Чтение из YAML
DB_USER=$(yq '.POSTGRES.USER' "$CONFIG_FILE")
DB_PASSWORD=$(yq '.POSTGRES.PASSWORD' "$CONFIG_FILE")
DB_NAME=$(yq '.POSTGRES.DATABASE' "$CONFIG_FILE")

# Проверка, что контейнер запущен
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" == "" ]; then
  echo "❌ Контейнер $CONTAINER_NAME не запущен"
  exit 1
fi

echo "✅ Создание базы '$DB_NAME' и пользователя '$DB_USER' в контейнере '$CONTAINER_NAME'..."

# Выполнение SQL внутри контейнера
docker exec -u postgres $CONTAINER_NAME psql <<EOF
DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME') THEN
      CREATE DATABASE "$DB_NAME";
   END IF;
END
\$\$;

DO \$\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = '$DB_USER') THEN
      CREATE USER "$DB_USER" WITH PASSWORD '$DB_PASSWORD';
   END IF;
END
\$\$;

GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" TO "$DB_USER";
EOF
