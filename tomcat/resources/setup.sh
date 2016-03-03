#!/bin/bash

JDK_INSTALLER=/vagrant/installer/jdk-8u45-linux-x64.tar.gz
JDK_INSTALL_DIR=/app/jdk1.8.0_45
TOMCAT_INSTALLER=/vagrant/installer/apache-tomcat-8.0.32.tar.gz
TOMCAT_INSTALL_DIR=/app/apache-tomcat-8.0.32


sudo mkdir -p /app

echo "Installing JDK"
sudo tar xzf ${JDK_INSTALLER} -C /app
sudo chown root:root -R ${JDK_INSTALL_DIR}
sudo cat << EOF >> /etc/profile

export JAVA_HOME=${JDK_INSTALL_DIR}
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
export PATH=\${JAVA_HOME}/bin:\${PATH}
EOF


echo "Installing tomcat"
sudo tar xzf ${TOMCAT_INSTALLER} -C /app
sudo chown root:root -R ${TOMCAT_INSTALL_DIR}


exit 0 
