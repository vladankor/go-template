# Работа с локальным контейнером Postgres (16.0)

CONFIG = env-local.yml
DOCKER_COMPOSE_PG = docker-compose -f stands/postgres/docker-compose.yml
DOCKER_COMPOSE_KAFKA = docker-compose -f stands/kafka/docker-compose.yml
DOCKER_COMPOSE_CLICKHOUSE = docker-compose -f stands/clickhouse/docker-compose.yml
KAFKA_PREPARE_ENV_SCRIPT = stands/kafka/scripts/prepare_env.sh
CONTAINER_NAME = pg-multi

.PHONY: local_postgres_container_up local_db local_postgres_create_db local_postgres_down migrate_up last_migration_rollback

local_postgres_container_up:
	$(DOCKER_COMPOSE_PG) up -d

local_postgres_create_db:
	@echo "🔄 Создание базы по $(CONFIG)"
	bash stands/postgres/scripts/create_db.sh $(CONFIG)

local_postgres_down:
	$(DOCKER_COMPOSE_PG) down

local_db: up create-db

# Работа с миграциями на локальном образе Postgres

migrate_up:
	@echo "📦 Применение миграций (.up.sql)"
	bash stands/postgres/scripts/apply_migrations.sh $(CONFIG)

last_migration_rollback:
	@echo "↩️  Откат последней миграции (.down.sql)"
	bash stands/postgres/scripts/rollback_last_migration.sh $(CONFIG)

# Работа с локальным контейнером Kafka
local_kafka_up:
	@echo "🔄 Поднятие контейнера Kafka и Zookeeper"
	bash $(KAFKA_PREPARE_ENV_SCRIPT) $(CONFIG)
	$(DOCKER_COMPOSE_KAFKA) up -d

local_kafka_down:
	@echo "❌ Удаление контейнера Kafka и Zookeeper"
	$(DOCKER_COMPOSE_KAFKA) down

# Работа с локальным контейнером Clickhouse
local_clickhouse_up:
	@echo "🔄 Поднятие контейнера Clickhouse"
	$(DOCKER_COMPOSE_CLICKHOUSE) up -d

local_clickhouse_down:
	@echo "❌ Удаление контейнера Clickhouse"
	$(DOCKER_COMPOSE_CLICKHOUSE) down
