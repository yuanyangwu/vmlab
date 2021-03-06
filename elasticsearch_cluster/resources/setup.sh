#!/bin/bash

RESOURCE_DIR=/vagrant/resources
INSTALLER_DIR=/vagrant/resources/installer
APP_DIR=/home/vagrant/app
JDK_INSTALLER=${INSTALLER_DIR}/jdk-8u45-linux-x64.tar.gz
JDK_INSTALL_DIR=${APP_DIR}/jdk1.8.0_45
ES_INSTALLER=${INSTALLER_DIR}/elasticsearch-2.3.2.tar.gz
ES_INSTALL_DIR=${APP_DIR}/elasticsearch-2.3.2

#apt-get update

install -b -g root -o root -m 0644 /vagrant/resources/limits.conf -t /etc/security

mkdir -p ${APP_DIR}
chown vagrant:vagrant -R ${APP_DIR}

# install JDK
tar xzf ${JDK_INSTALLER} -C ${APP_DIR}
chown vagrant:vagrant -R ${JDK_INSTALL_DIR}
cat << EOF >> /etc/profile

export JAVA_HOME=${JDK_INSTALL_DIR}
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
export PATH=\${JAVA_HOME}/bin:\${PATH}
EOF


# install ES
tar xzf ${ES_INSTALLER} -C ${APP_DIR}
cp -f ${ES_INSTALL_DIR}/config/elasticsearch.yml ${ES_INSTALL_DIR}/config/elasticsearch.yml.bak
cp -f ${RESOURCE_DIR}/elasticsearch.yml.$(uname -n) ${ES_INSTALL_DIR}/config/elasticsearch.yml
chown vagrant:vagrant -R ${ES_INSTALL_DIR}

echo "Launch elasticsearch via \'cd ${ES_INSTALL_DIR} && bin/elasticsearch\'"
exit 0 
