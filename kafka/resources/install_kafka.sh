#!/bin/bash

# for example, /home/vagrant/kafka/kafka_2.11-2.0.0.tgz
KAFKA_INSTALLER=$1
if [ -z ${KAFKA_INSTALLER} ]; then
    echo "Usage: install_kafka.sh <kafka_installer_tgz>"
    exit 1
fi

ROOT_DIR=$(dirname ${KAFKA_INSTALLER})
KAFKA_INSTALLER_FILENAME=$(basename ${KAFKA_INSTALLER})
KAFKA_BASE_NAME=$(echo ${KAFKA_INSTALLER_FILENAME} | sed 's/.tgz//')

function deploy_kafka_server() {
    SERVER_DIR=$1
    BROKER_ID=$2
    LISTENER_PORT=$3

    mkdir -p ${SERVER_DIR}
    tar -xzf ${KAFKA_INSTALLER} --directory ${SERVER_DIR}

    ZK_DATA_LOG=${SERVER_DIR}/logs-zookeeper

    KAFKA_ROOT_DIR=${SERVER_DIR}/${KAFKA_BASE_NAME}
    KAFKA_CONFIG_DIR=${KAFKA_ROOT_DIR}/config
    KAFKA_DATA_LOG_DIR=${SERVER_DIR}/logs-kafka
    KAFKA_JAVA_LOG_DIR=${KAFKA_ROOT_DIR}/logs
    
    mkdir -p ${ZK_DATA_LOG}
    mkdir -p ${KAFKA_DATA_LOG_DIR}
    mkdir -p ${KAFKA_JAVA_LOG_DIR}

    mv ${KAFKA_CONFIG_DIR}/server.properties ${KAFKA_CONFIG_DIR}/server.properties.orig
    python3 /vagrant/resources/gen_by_template.py \
        /vagrant/resources/template/server.properties \
        broker_id=${BROKER_ID} \
        log_dirs=${KAFKA_DATA_LOG_DIR} \
        listener_port=${LISTENER_PORT} \
        > ${KAFKA_CONFIG_DIR}/server.properties

    mv ${KAFKA_CONFIG_DIR}/zookeeper.properties ${KAFKA_CONFIG_DIR}/zookeeper.properties.orig
    python3 /vagrant/resources/gen_by_template.py \
        /vagrant/resources/template/zookeeper.properties \
        data_dir=${ZK_DATA_LOG} \
        > ${KAFKA_CONFIG_DIR}/zookeeper.properties

    echo "cd ${KAFKA_ROOT_DIR}"
    echo "bin/zookeeper-server-start.sh config/zookeeper.properties # run on only 1 server"
    echo "bin/kafka-server-start.sh config/server.properties"
}

function deploy_kafka_single() {
    echo "# Kafka single mode"
    deploy_kafka_server "${ROOT_DIR}/single/server0" 0 9092
}

function deploy_kafka_cluster() {
    echo "# Kafka cluster mode"
    deploy_kafka_server "${ROOT_DIR}/cluster/server0" 0 9092
    deploy_kafka_server "${ROOT_DIR}/cluster/server1" 1 9093
    deploy_kafka_server "${ROOT_DIR}/cluster/server2" 2 9094
}

echo "Start instructions"
echo ""
deploy_kafka_single
deploy_kafka_cluster

echo ""
echo "Topic instructions

# Create a topic
sudo bin/kafka-topics.sh --create --topic my_topic --zookeeper 192.168.11.60:2181 --replication-factor 2 --partitions 3

# Show a topic
sudo bin/kafka-topics.sh --describe --topic my_topic --zookeeper 192.168.11.60:2181

# Write a topic
sudo bin/kafka-console-producer.sh --broker-list 192.168.11.60:9092 --topic my_topic
msg 1
msg 2

# Read a topic
sudo bin/kafka-console-consumer.sh --bootstrap-server 192.168.11.60:9092 --topic my_topic --from-beginning
"
