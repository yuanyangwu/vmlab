#!/bin/bash

JDK_INSTALLER=/vagrant/installer/jdk-8u45-linux-x64.tar.gz
JDK_INSTALL_DIR=/app/jdk1.8.0_45
MVN_INSTALLER=/vagrant/installer/apache-maven-3.5.0-bin.tar.gz
MVN_INSTALL_DIR=/app/apache-maven-3.5.0


sudo mkdir -p /app

echo "Installing JDK"
sudo tar xzf ${JDK_INSTALLER} -C /app
sudo chown root:root -R ${JDK_INSTALL_DIR}
sudo tar xzf ${MVN_INSTALLER} -C /app
sudo chown root:root -R ${MVN_INSTALL_DIR}
sudo cat << EOF >> /etc/profile

export JAVA_HOME=${JDK_INSTALL_DIR}
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
export M2_HOME=${MVN_INSTALL_DIR}
export PATH=\${JAVA_HOME}/bin:\${M2_HOME}/bin:\${PATH}
EOF

exit 0 
