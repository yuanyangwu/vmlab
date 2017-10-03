#!/bin/bash

JDK_INSTALLER=/vagrant/installer/jdk-8u45-linux-x64.tar.gz
JDK_INSTALL_DIR=/app/jdk1.8.0_45
MVN_INSTALLER=/vagrant/installer/apache-maven-3.5.0-bin.tar.gz
MVN_INSTALL_DIR=/app/apache-maven-3.5.0
ZK_INSTALLER=/vagrant/installer/zookeeper-3.4.10.tar.gz
ZK_INSTALL_DIR=/app/zookeeper-3.4.10
BK_INSTALLER=/vagrant/installer/bookkeeper-server-4.4.0-bin.tar.gz
BK_INSTALL_DIR=/app/bookkeeper-server-4.4.0

sudo mkdir -p /app

echo "Installing JDK"
sudo tar xzf ${JDK_INSTALLER} -C /app
sudo chown root:root -R ${JDK_INSTALL_DIR}
sudo tar xzf ${MVN_INSTALLER} -C /app
sudo chown root:root -R ${MVN_INSTALL_DIR}
mkdir -p /home/vagrant/.m2
chown vagrant:vagrant -R /home/vagrant/.m2
install -g vagrant -o vagrant -m 0644 /vagrant/resources/maven_settings.xml /home/vagrant/.m2/settings.xml
sudo cat << EOF >> /etc/profile

export JAVA_HOME=${JDK_INSTALL_DIR}
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
export M2_HOME=${MVN_INSTALL_DIR}
export PATH=\${JAVA_HOME}/bin:\${M2_HOME}/bin:\${PATH}
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
chown root:root -R /var/zookeeper

install -g root -o root -m 0700 /vagrant/resources/start_zk.sh /home/vagrant
install -g root -o root -m 0700 /vagrant/resources/stop_zk.sh /home/vagrant
echo "Launch ZooKeeper via \"./start_zk.sh\""


echo "Installing BookKeeper"
tar xzf ${BK_INSTALLER} -C /app
chown root:root -R ${BK_INSTALL_DIR}
cat << EOF >> /etc/profile

export PATH=${BK_INSTALL_DIR}/bin:\${PATH}
EOF

exit 0 
