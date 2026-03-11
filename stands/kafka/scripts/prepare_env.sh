#!/bin/bash

YAML_FILE=$1
# Проверка существует ли файл на один уровень выше
if [[ ! -f "$YAML_FILE" ]]; then
  echo "❌ Файл конфигурации $YAML_FILE не найден!"
  exit 1
fi

# Загрузка значений из env-local.yml
export KAFKA_CONFLUENT_SUPPORT_METRICS_ENABLE=$(yq eval '.KAFKA.CONFLUENT_SUPPORT_METRICS_ENABLE' $YAML_FILE)
export KAFKA_LOG_SEGMENT_BYTES=$(yq eval '.KAFKA.LOG_SEGMENT_BYTES' $YAML_FILE)
export KAFKA_LOG_RETENTION_BYTES=$(yq eval '.KAFKA.LOG_RETENTION_BYTES' $YAML_FILE)
export KAFKA_LOG_RETENTION_HOURS=$(yq eval '.KAFKA.LOG_RETENTION_HOURS' $YAML_FILE)
export KAFKA_PARTITIONS=$(yq eval '.KAFKA.PARTITIONS' $YAML_FILE)
