include .env

.SILENT:
.DEFAULT_GOAL := show_all

show_all:
	echo "enter:"
	echo ""
	echo "\tmake clickhouse\t\t-> \trun ClickHouse:$(CLICKHOUSE_VERSION) on port $(CLICKHOUSE_PORT)"
	echo "\tmake clickhouse_down\t-> \tdown ClickHouse"
	echo ""
	echo "\tmake redis_cluster\t-> \trun Redis Cluster on ports 7000-7050"
	echo "\tmake redis_cluster_down\t-> \tdown Redis Cluster"
	echo ""
	echo "\tmake redis\t\t-> \trun basic Redis:$(REDIS_BASIC_VERSION) on port $(REDIS_BASIC_PORT)"
	echo "\tmake redis_down\t\t-> \tdown basic Redis"
	echo ""
	echo "\tmake rabbitmq\t\t-> \trun RabbitMQ:$(RABBITMQ_VERSION) on port $(RABBITMQ_PORT), $(RABBITMQ_PORT_WEB)(web)"
	echo "\tmake rabbitmq_down\t-> \tdown RabbitMQ"
	echo ""
	echo "\tmake mongodb\t\t-> \trun MongoDB:$(MONGODB_VERSION) on port $(MONGODB_PORT)"
	echo "\tmake mongodb_down\t-> \tdown MongoDB"
	echo ""
	echo "\tmake mysql\t\t-> \trun MySQL:$(MYSQL_VERSION) on port $(MYSQL_PORT)"
	echo "\tmake mysql_down\t\t-> \tdown MySQL"
	echo "\tmake mysql_query_log\t-> \tshow log query in live"
	echo ""
	echo "\tmake minio\t\t-> \trun Minio(S3):$(MINIO_VERSION) on port $(MINIO_PORT)"
	echo "\tmake minio_down\t\t-> \tdown Minio(S3)"
	echo ""
	echo "\tmake postgres\t\t-> \trun PostgreSQL:$(POSTGRES_VERSION) on port $(POSTGRES_PORT)"
	echo "\tmake postgres_down\t-> \tdown PostgreSQL"
	echo ""
	echo "\tmake nats\t\t-> \trun NATS:$(NATS_VERSION) on port $(NATS_PORT)"
	echo "\tmake nats_down\t\t-> \tdown NATS"
	echo ""
	echo "\tmake nats_cluster\t-> \trun NATS Cluster:$(NATS_VERSION) on port $(NATS_PORT)"
	echo "\tmake nats_cluster_down\t-> \tdown NATS Cluster"
	echo ""
	echo "\tmake kafka\t\t-> \trun Kafka:$(KAFKA_VERSION) on port $(KAFKA_PORT)"
	echo "\tmake kafka_down\t\t-> \tdown Kafka"
	echo ""
	echo "\tmake logs c=mysql_dev\t-> \tshow log in live"
	echo "\tmake enter c=mysql_dev\t-> \tenter inside container"

logs:
	docker container logs -f $(c)

enter:
	docker exec -it $(c) su


# -----------------------------
# ClickHouse
_CH_DIR = _clickhouse
_CH_DC_FILE = $(_CH_DIR)/docker-compose.yml
_CH_DOCKERCOMPOSE_CMD = docker-compose -f $(_CH_DC_FILE)

clickhouse:
	sed "s/<password><\/password>/<password>$(CLICKHOUSE_PASSWORD)<\/password>/" $(_CH_DIR)/users_template.xml > $(_CH_DIR)/users.xml
	$(_CH_DOCKERCOMPOSE_CMD) up -d
	echo
	echo "-----------------------------"
	echo "clickhouse:$(CLICKHOUSE_VERSION)"
	echo "container_name: $(CLICKHOUSE_CONTAINER_NAME)"
	echo "url: http://localhost:$(CLICKHOUSE_PORT)"
	echo "username: $(CLICKHOUSE_USER)"
	echo "password: $(CLICKHOUSE_PASSWORD)"
	echo "database: $(CLICKHOUSE_DB)"
	echo "-----------------------------"

clickhouse_down:
	$(_CH_DOCKERCOMPOSE_CMD) down


# -----------------------------
# MongoDB
_MONGODB_DIR = _mongodb
_MONGODB_DC_FILE = $(_MONGODB_DIR)/docker-compose.yml
_MONGODB_CMD = docker-compose -f $(_MONGODB_DC_FILE)

mongodb:
	$(_MONGODB_CMD) up -d
	echo
	echo "-----------------------------"
	echo "MongoDB:$(MONGODB_VERSION)"
	echo "container_name: $(MONGODB_CONTAINER_NAME)"
	echo "host: localhost:$(MONGODB_PORT)"
	echo "username: $(MONGODB_USER)"
	echo "password: $(MONGODB_PASSWORD)"
	echo "-----------------------------"

mongodb_down:
	$(_MONGODB_CMD) down


# -----------------------------
# MySQL
_MYSQL_DIR = _mysql
_MYSQL_DC_FILE = $(_MYSQL_DIR)/docker-compose.yml
_MYSQL_CMD = docker-compose -f $(_MYSQL_DC_FILE)

mysql:
	$(_MYSQL_CMD) up -d
	echo
	echo "-----------------------------"
	echo "MySQL:$(MYSQL_VERSION):"
	echo "host: localhost:$(MYSQL_PORT)"
	echo "container_name: $(MYSQL_CONTAINER_NAME)"
	echo "username: $(MYSQL_USER)"
	echo "password: $(MYSQL_PASSWORD)"
	echo "database: $(MYSQL_DATABASE)"
	echo "-----------------------------"

mysql_down:
	$(_MYSQL_CMD) down


mysql_query_log:
	docker exec -it $(MYSQL_CONTAINER_NAME) tail -f /var/log/mysql/mysql.log


# -----------------------------
# PostgreSQL
_POSTGRES_DIR = _postgres
_POSTGRES_DC_FILE = $(_POSTGRES_DIR)/docker-compose.yml
_POSTGRES_CMD = docker-compose -f $(_POSTGRES_DC_FILE)

postgres:
	$(_POSTGRES_CMD) up -d
	echo
	echo "-----------------------------"
	echo "PostgreSQL:$(POSTGRES_VERSION)"
	echo "container_name: $(POSTGRES_CONTAINER_NAME)"
	echo "host: localhost:$(POSTGRES_PORT)"
	echo "username: $(POSTGRES_USER)"
	echo "password: $(POSTGRES_PASSWORD)"
	echo "databasse: $(POSTGRES_DB)"
	echo "-----------------------------"

postgres_down:
	$(_POSTGRES_CMD) down


# -----------------------------
# Redis Cluster
_REDIS_CLUSTER_DIR = _redis-cluster
_REDIS_CLUSTER_DC_FILE = $(_REDIS_CLUSTER_DIR)/docker-compose.yml
_REDIS_CLUSTER_CMD = export REDIS_CLUSTER_IP=0.0.0.0 && \
	docker-compose -f $(_REDIS_CLUSTER_DC_FILE)

redis_cluster:
	$(_REDIS_CLUSTER_CMD) up -d
	sleep 5
	export REDIS_CLUSTER_PASSWORD=$(REDIS_CLUSTER_PASSWORD) && \
	sh $(_REDIS_CLUSTER_DIR)/set_password.sh
	echo
	echo "-----------------------------"
	echo "Redis Cluster:"
	echo "container_name: $(REDIS_CLUSTER_CONTAINER_NAME)"
	echo "host: localhost:7000-7050"
	echo "password: $(REDIS_CLUSTER_PASSWORD)"
	echo "-----------------------------"

redis_cluster_down:
	$(_REDIS_CLUSTER_CMD) down


# -----------------------------
# Redis Basic
_REDIS_BASIC_DIR = _redis-basic
_REDIS_BASIC_DC_FILE = $(_REDIS_BASIC_DIR)/docker-compose.yml
_REDIS_BASIC_CMD = docker-compose -f $(_REDIS_BASIC_DC_FILE)

redis:
	$(_REDIS_BASIC_CMD) up -d
	echo
	echo "-----------------------------"
	echo "Redis:$(REDIS_BASIC_VERSION)"
	echo "container_name: $(REDIS_BASIC_CONTAINER_NAME)"
	echo "host: localhost:$(REDIS_BASIC_PORT)"
	echo "password: $(REDIS_BASIC_PASSWORD)"
	echo "-----------------------------"

redis_down:
	$(_REDIS_BASIC_CMD) down


# -----------------------------
# RabbitMQ
_RABBITMQ_DIR = _rabbitmq
_RABBITMQ_DC_FILE = $(_RABBITMQ_DIR)/docker-compose.yml
_RABBITMQ_CMD = docker-compose -f $(_RABBITMQ_DC_FILE)

rabbitmq:
	$(_RABBITMQ_CMD) up -d
	echo
	echo "-----------------------------"
	echo "RabbitMQ: $(RABBITMQ_VERSION)"
	echo "container_name: $(RABBITMQ_CONTAINER_NAME)"
	echo "host: localhost:$(RABBITMQ_PORT)"
	echo "web: localhost:$(RABBITMQ_PORT_WEB)"
	echo "username: $(RABBITMQ_USER)"
	echo "password: $(RABBITMQ_PASSWORD)"
	echo "-----------------------------"

rabbitmq_down:
	$(_RABBITMQ_CMD) down


# -----------------------------
# FTP
_FTP_DIR = _ftp
_FTP_DC_FILE = $(_FTP_DIR)/docker-compose.yml
_FTP_CMD = docker-compose -f $(_FTP_DC_FILE)

ftp:
	$(_FTP_CMD) up -d
	echo
	echo "-----------------------------"
	echo "FTP:$(FTP_VERSION)"
	echo "host: localhost:20"
	echo "container_name: $(FTP_CONTAINER_NAME)"
	echo "username: $(FTP_USER)"
	echo "password: $(FTP_PASSWORD)"
	echo "ftp dir: $(FTP_DIR)"
	echo "-----------------------------"

ftp_down:
	$(_FTP_CMD) down


# -----------------------------
# Minio(S3)
_MINIO_DIR = _minio
_MINIO_DC_FILE = $(_MINIO_DIR)/docker-compose.yml
_MINIO_CMD = docker-compose -f $(_MINIO_DC_FILE)

minio:
	$(_MINIO_CMD) up -d
	echo
	echo "-----------------------------"
	echo "Minio(S3):$(MINIO_VERSION)"
	echo "container_name: $(MINIO_CONTAINER_NAME)"
	echo "host: localhost:$(MINIO_PORT)"
	echo "access_key: $(MINIO_ACCESS_KEY)"
	echo "secret_key: $(MINIO_SECRET_KEY)"
	echo "-----------------------------"

minio_down:
	$(_MINIO_CMD) down


# -----------------------------
# NATS
_NATS_DIR = _nats
_NATS_DC_FILE = $(_NATS_DIR)/docker-compose.yml
_NATS_CMD = docker-compose -f $(_NATS_DC_FILE)

nats:
	$(_NATS_CMD) up -d
	echo
	echo "-----------------------------"
	echo "NATS:$(NATS_VERSION)"
	echo "container_name: $(NATS_CONTAINER_NAME)"
	echo "host: localhost:$(NATS_PORT)"
	echo "management: localhost:$(NATS_MANAGEMENT_PORT)"
	echo "-----------------------------"

nats_down:
	$(_NATS_CMD) down


# -----------------------------
# NATS-CLUSTER
_NATS_CLUSTER_DIR = _nats_cluster
_NATS_CLUSTER_DC_FILE = $(_NATS_CLUSTER_DIR)/docker-compose.yml
_NATS_CLUSTER_CMD = docker-compose -f $(_NATS_CLUSTER_DC_FILE)

nats_cluster:
	$(_NATS_CLUSTER_CMD) up -d
	echo
	echo "-----------------------------"
	echo "NATS:$(NATS_VERSION)"
	echo "container_name: $(NATS_CONTAINER_NAME)_master"
	echo "host: localhost:$(NATS_PORT)"
	echo "management: localhost:$(NATS_MANAGEMENT_PORT)"
	echo "-----------------------------"

nats_cluster_down:
	$(_NATS_CLUSTER_CMD) down


# -----------------------------
# KAFKA
_KAFKA_DIR = _kafka
_KAFKA_DC_FILE = $(_KAFKA_DIR)/docker-compose.yml
_KAFKA_CMD = docker-compose -f $(_KAFKA_DC_FILE)

kafka:
	$(_KAFKA_CMD) up -d
	echo
	echo "-----------------------------"
	echo "KAFKA:$(KAFKA_VERSION)"
	echo "container_name: $(KAFKA_CONTAINER_NAME)"
	echo "host: localhost:$(KAFKA_PORT)"
	echo "ZOOKEEPER:$(ZOOKEEPER_VERSION)"
	echo "container_name: $(ZOOKEEPER_CONTAINER_NAME)"
	echo "host: localhost:$(ZOOKEEPER_PORT)"
	echo "-----------------------------"

kafka_down:
	$(_KAFKA_CMD) down
