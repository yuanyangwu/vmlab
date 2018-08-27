#!/bin/bash

# Change Ubuntu repo to fast mirror
sed -i.bak1 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list
sed -i.bak2 's/security.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list

apt-get update
apt-get install -y openjdk-8-jdk maven scala

sudo cat << EOF >> /etc/profile
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
EOF

# Download kafka
mkdir -p /home/vagrant/kafka
cd /home/vagrant/kafka && wget -q https://mirrors.aliyun.com/apache/kafka/2.0.0/kafka_2.11-2.0.0.tgz
/vagrant/resources/install_kafka.sh /home/vagrant/kafka/kafka_2.11-2.0.0.tgz | tee /home/vagrant/usage.txt
