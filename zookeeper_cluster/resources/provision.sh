#!/bin/bash

JDK_INSTALLER=/vagrant/installer/jdk-8u45-linux-x64.tar.gz
JDK_INSTALL_DIR=/app/jdk1.8.0_45
ZK_INSTALLER=/vagrant/installer/zookeeper-3.4.7.tar.gz
ZK_INSTALL_DIR=/app/zookeeper-3.4.7

# hosts
install -g root -o root -m 0644 /vagrant/resources/hosts /etc/hosts

mkdir -p /app
chown root:root /app

echo "Installing JDK"
tar xzf ${JDK_INSTALLER} -C /app
chown root:root -R ${JDK_INSTALL_DIR}
cat << EOF >> /etc/profile

export JAVA_HOME=${JDK_INSTALL_DIR}
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
export PATH=\${JAVA_HOME}/bin:\${PATH}
EOF

echo "Installing ZooKeeper"
tar xzf ${ZK_INSTALLER} -C /app
chown root:root -R ${ZK_INSTALL_DIR}
install -g root -o root -m 0644 /vagrant/resources/zoo.cfg ${ZK_INSTALL_DIR}/conf
cat << EOF >> /etc/profile

export ZOOKEEPER_HOME=${ZK_INSTALL_DIR}
export PATH=\${ZOOKEEPER_HOME}/bin:\${PATH}
EOF
mkdir -p /var/zookeeper/data
mkdir -p /var/zookeeper/datalogs
mkdir -p /var/zookeeper/logs
install -g root -o root -m 0400 /vagrant/resources/myid.$(uname -n) /var/zookeeper/data/myid
chown vagrant:vagrant -R /var/zookeeper

install -g vagrant -o vagrant -m 0700 /vagrant/resources/start_zk.sh /home/vagrant
install -g vagrant -o vagrant -m 0700 /vagrant/resources/stop_zk.sh /home/vagrant
echo "Launch ZooKeeper via \"./start_zk.sh\""
exit 0 
