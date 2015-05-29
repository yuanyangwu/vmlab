#!/bin/sh

HADOOP_MASTER_HOSTNAME=hadoop1
HADOOP_MASTER_IP=192.168.33.10
NODE_CPUS=3
NODE_MEMORY=2
SPARK_WORKER_CORES=`expr ${NODE_CPUS} - 1`
SPARK_WORKER_INSTANCES=${SPARK_WORKER_CORES}
SPARK_WORKER_MEMORY=`expr ${NODE_MEMORY} - 1`
JDK_INSTALLER=/installer/jdk-8u45-linux-x64.tar.gz
JDK_INSTALL_DIR=/app/jdk1.8.0_45
SCALA_INSTALLER=/installer/scala-2.10.5.tgz
SCALA_INSTALL_DIR=/app/scala-2.10.5
HADOOP_INSTALLER=/installer/hadoop-2.6.0.tar.gz
HADOOP_INSTALL_DIR=/app/hadoop-2.6.0
SPARK_INSTALLER=/installer/spark-1.3.1-bin-hadoop2.6.tgz
SPARK_INSTALL_DIR=/app/spark-1.3.1


sudo apt-get install -y python-pip python-dev vim

if [ ! -e /etc/hosts.orig ]; then
  echo "Assign ${HADOOP_MASTER_HOSTNAME} IP in /etc/hosts"
  sudo cp -a /etc/hosts /etc/hosts.orig
  sudo cp -a /etc/hosts /etc/hosts.tmp
  sudo sed "s;^.*${HADOOP_MASTER_HOSTNAME}.*$;${HADOOP_MASTER_IP} ${HADOOP_MASTER_HOSTNAME};" /etc/hosts > /etc/hosts.tmp
  sudo mv /etc/hosts.tmp /etc/hosts
fi

exist=`grep spark /etc/passwd`
if [ "$?" != "0" ]; then
  echo 'Adding user "spark"'
  sudo groupadd -g 2000 spark
  sudo useradd -m -s /bin/bash -u 2000 -g spark spark
  echo "spark:spark" | sudo chpasswd
  echo 'spark ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

if [ ! -e /etc/security/limits.conf.orig ]; then
  echo "Increasing open file handle limit"
  sudo cp -a /etc/security/limits.conf /etc/security/limits.conf.orig
  sudo cat << EOF >> /etc/security/limits.conf
*               soft    nofile            32768
*               hard    nofile            65536
EOF
fi

if [ ! -e /home/spark/.ssh/id_rsa ]; then
  echo 'Adding SSH key to "spark" user'

  sudo mkdir /home/spark/.ssh

  sudo cat << EOF > /home/spark/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEArMAq9o0hS7mKC7BNB2VQ323USYrebq6QZle+TsKlieQJb44O
Ff0/nXeQ2vapNv1UZXf/cYFHX0cXRAZk9nPVjrTdsRp+yBFwF1p8k3dResYDyT1r
8jGdP7OuZvLzs9h0tY67L0153A609XYfi0WJ/Qebporp40Wu9XNhCTu284ZHNM2i
DawByaL2dKIxX8PeF//8flmAFQOfJV3q0KqQv89IcussibdooPpInAUE9OktQb8Y
EjNTqraG95LtgRk4/qvnumQ6vq6LuB7hqSL+drXIOWeLOGNIeZA8CifI4dtCpbgR
fQZhFl5VHtpPHIZqpWDaxI5BWq1yW0LV1RCtUQIDAQABAoIBAQCYrZbLJVyiEq+h
OQY7XR4m+mi/Ps7sP7g725zE+19XCYYVZBWq9ZJ916jc/Vf809T9gRrw9HNiD/DO
HGCrOSEr6UpuNp6KsG7DFSQ5KSGIQu4hs/ltqs/x9xpSvrMI5mvv8uAZJH5pMU5a
CzZB3wnf6hN1FB020uWY5YqDoJVHkJclZHE5Pn+NOmg9JJRdgNuZ/C5Bfyw4d/LG
qww2Xvml4V6MNwabFuxLfSz/cc2YkWvQiVNRo+TzMKX+r45SQHePLCvPUbxhdq9N
HzbiwAtK4qBafs3xANBNQ9L2xPufVQwSSxAZj3+njkPLPujn0ZVulDtOhQ/okl7b
TrtqA+LhAoGBAOKmgmanO2pOz/6Y2tB8ulxLTvHDxB6xtK9gEty3nWruy+nt+MNa
ZhD0EPQo06hyyQ5ca98Q0dPs1hkscMrGM3tEdw8M+0idYTO9WEJ5ZNeoFLswxooU
q6ZR0SPv2AzYSwuEfbm7kvYJz0hGG28BQU6sYIsKsgJcww0SbfA11CldAoGBAMMe
38bTmYYX/7vQX03/HV+PgXU8sbrYUNKfzAKgdUAH0n5ugWB8fQnpquB5LHEn2i5b
McZV4YA0lXA6L4XkYu00rbRFFGOEfnYUL+Qd6xUbPb4ndLU6GrfY07u6R5d1TgKk
17gTn9cJR5qE4eWQ69M21/o37WJH2QUPNXuSUPCFAoGAWwG2/JcLsW0B8V3ZBrv+
bI7EnSkZN6XtQjoWeM+1grlt4XlvWKmUsBwALrmx+0JT3tNXcRMk3a6MbUE97P3W
sBlWoRF6WLbwz8CojtCFoF5aLKuyHMGeBsN1cbOdkdLLl01U2l4p7WcU9xVHcLQV
UAzBGzNpNK+glkAfKsPCc/UCgYEAvR2PhwZQJsfb9g1gUhiSP6y3rQnGuXIv4/U9
ps4e1pC+VAyHGR2Pk6wHEspfaM1XitaYx8M1bS2KKdw7c2qI95+3PKI3wL0KVSf7
wv28fBiLH2Lem0hV3RsrHSjPet0XXzimXKOoqKM1424oBHkSGQVvD/Zk/nzkuyKi
k8Kc8IECgYBtF5g1fJoY+HqxTi8ZqVEZOMKoTAi+HsWjBOONt3U2DjOuUllOow3d
KKeG/jwLiECrJ7cMzBzI2RDU2BUvY1WGbKIAH+ELbUxSd41PBDnAhEzb7eWqBRoR
O0FVi1u6/TcztuhVsIbbSIz9VU+/2EETj1NLF8j0GzyrQRFuUfljjg==
-----END RSA PRIVATE KEY-----
EOF
  sudo chmod 0600 /home/spark/.ssh/id_rsa

  sudo cat << EOF > /home/spark/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCswCr2jSFLuYoLsE0HZVDfbdRJit5urpBmV75OwqWJ5Alvjg4V/T+dd5Da9qk2/VRld/9xgUdfRxdEBmT2c9WOtN2xGn7IEXAXWnyTd1F6xgPJPWvyMZ0/s65m8vOz2HS1jrsvTXncDrT1dh+LRYn9B5umiunjRa71c2EJO7bzhkc0zaINrAHJovZ0ojFfw94X//x+WYAVA58lXerQqpC/z0hy6yyJt2ig+kicBQT06S1BvxgSM1Oqtob3ku2BGTj+q+e6ZDq+rou4HuGpIv52tcg5Z4s4Y0h5kDwKJ8jh20KluBF9BmEWXlUe2k8chmqlYNrEjkFarXJbQtXVEK1R spark@${HADOOP_MASTER_HOSTNAME}
EOF
  sudo chmod 0644 /home/spark/.ssh/id_rsa.pub

  sudo cp /home/spark/.ssh/id_rsa.pub /home/spark/.ssh/authorized_keys
  sudo chmod 0600 /home/spark/.ssh/authorized_keys

  sudo chmod 0700 /home/spark/.ssh
  sudo chown spark:spark -R /home/spark/.ssh/
fi

sudo mkdir -p /app

if [ ! -d ${JDK_INSTALL_DIR} ]; then
  echo "Installing JDK"
  sudo tar xzf ${JDK_INSTALLER} -C /app
  sudo chown root:root -R ${JDK_INSTALL_DIR}
  sudo cat << EOF >> /etc/profile

export JAVA_HOME=${JDK_INSTALL_DIR}
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
export PATH=\${JAVA_HOME}/bin:\${PATH}
EOF
fi

if [ ! -d ${SCALA_INSTALL_DIR} ]; then
  echo "Installing Scala"
  sudo tar xzf ${SCALA_INSTALLER} -C /app
  sudo chown root:root -R ${SCALA_INSTALL_DIR}
  sudo cat << EOF >> /etc/profile

export SCALA_HOME=${SCALA_INSTALL_DIR}
export PATH=\${SCALA_HOME}/bin:\${PATH}
EOF
fi

if [ ! -d ${HADOOP_INSTALL_DIR} ]; then
  echo "Installing Hadoop"
  sudo tar xzf ${HADOOP_INSTALLER} -C /app
  sudo cat << EOF >> /etc/profile

export HADOOP_PREFIX=${HADOOP_INSTALL_DIR}
export HADOOP_COMMON_HOME=\${HADOOP_PREFIX}
export HADOOP_HDFS_HOME=\${HADOOP_PREFIX}
export HADOOP_MAPRED_HOME=\${HADOOP_PREFIX}
export YARN_HOME=\${HADOOP_PREFIX}
export PATH=\${HADOOP_PREFIX}/bin:\${HADOOP_PREFIX}/sbin:\${PATH}
EOF

  sudo mkdir -p /data/hdfs/data
  sudo mkdir -p /data/hdfs/name
  sudo mkdir -p /data/hdfs/sysmapred
  sudo mkdir -p /data/hdfs/localmapred

  sudo cat << EOF > ${HADOOP_INSTALL_DIR}/etc/hadoop/core-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://${HADOOP_MASTER_HOSTNAME}:8000/</value>
</property>

<property>
<name>io.file.buffer.size</name>
<value>131072</value>
</property>
</configuration>
EOF

  sudo cat << EOF > ${HADOOP_INSTALL_DIR}/etc/hadoop/hdfs-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>dfs.namenode.name.dir</name>
<value>file:/data/hdfs/name</value>
</property>

<property>
<name>dfs.datanode.data.dir</name>
<value>file:/data/hdfs/data</value>
</property>

<property>
<name>dfs.blocksize</name>
<value>67108864</value>
</property>

<property>
<name>dfs.replication</name>
<value>1</value>
</property>

<property>
<name>dfs.permission</name>
<value>false</value>
</property>
</configuration>
EOF

  sudo cat << EOF > ${HADOOP_INSTALL_DIR}/etc/hadoop/yarn-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>yarn.resourcemanager.address</name>
<value>${HADOOP_MASTER_HOSTNAME}:8880</value>
</property>

<property>
<name>yarn.resourcemanager.scheduler.address</name>
<value>${HADOOP_MASTER_HOSTNAME}:8881</value>
</property>

<property>
<name>yarn.resourcemanager.resource-tracker.address</name>
<value>${HADOOP_MASTER_HOSTNAME}:8882</value>
</property>

<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
</configuration>
EOF

  sudo cat << EOF > ${HADOOP_INSTALL_DIR}/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>

<property>
<name>mapreduce.job.tracker</name>
<value>hdfs://${HADOOP_MASTER_HOSTNAME}:8001</value>
<final>true</final>
</property>

<property>
<name>mapreduce.map.memory.mb</name>
<value>1536</value>
</property>

<property>
<name>mapreduce.map.java.opts</name>
<value>-Xmx1024M</value>
</property>

<property>
<name>mapreduce.reduce.memory.mb</name>
<value>3072</value>
</property>

<property>
<name>mapreduce.reduce.java.opts</name>
<value>-Xmx2560M</value>
</property>

<property>
<name>mapreduce.task.io.sort.mb</name>
<value>512</value>
</property>

<property>
<name>mapreduce.task.io.sort.factor</name>
<value>100</value>
</property>

<property>
<name>mapreduce.reduce.shuffle.parallelcopies</name>
<value>50</value>
</property>

<property>
<name>mapred.system.dir</name>
<value>file:/data/hdfs/sysmapred</value>
<final>true</final>
</property>

<property>
<name>mapred.local.dir</name>
<value>file:/data/hdfs/localmapred</value>
<final>true</final>
</property>
</configuration>
EOF

  if [ ! -e ${HADOOP_INSTALL_DIR}/etc/hadoop/hadoop-env.sh.orig ]; then
    sudo mv ${HADOOP_INSTALL_DIR}/etc/hadoop/hadoop-env.sh ${HADOOP_INSTALL_DIR}/etc/hadoop/hadoop-env.sh.orig
    sudo sed "s;\${JAVA_HOME};${JDK_INSTALL_DIR};g" ${HADOOP_INSTALL_DIR}/etc/hadoop/hadoop-env.sh.orig > ${HADOOP_INSTALL_DIR}/etc/hadoop/hadoop-env.sh
    sudo mv ${HADOOP_INSTALL_DIR}/etc/hadoop/yarn-env.sh ${HADOOP_INSTALL_DIR}/etc/hadoop/yarn-env.sh.orig
    sudo sed "s;\${JAVA_HOME};${JDK_INSTALL_DIR};g" ${HADOOP_INSTALL_DIR}/etc/hadoop/yarn-env.sh.orig > ${HADOOP_INSTALL_DIR}/etc/hadoop/yarn-env.sh
  fi

  sudo cat << EOF > ${HADOOP_INSTALL_DIR}/etc/hadoop/slaves
${HADOOP_MASTER_HOSTNAME}
EOF


  sudo chown spark:spark -R ${HADOOP_INSTALL_DIR}
  sudo chown spark:spark -R /data/hdfs
fi

if [ ! -d ${SPARK_INSTALL_DIR} ]; then
  echo "Installing Spark"
  sudo tar xzf ${SPARK_INSTALLER} -C /app
  sudo mv ${SPARK_INSTALL_DIR}-bin-hadoop2.6 ${SPARK_INSTALL_DIR}
  sudo chown spark:spark -R ${SPARK_INSTALL_DIR}
  sudo cat << EOF >> ${SPARK_INSTALL_DIR}/conf/slaves
${HADOOP_MASTER_HOSTNAME}
EOF

  sudo cat << EOF >> ${SPARK_INSTALL_DIR}/conf/spark-env.sh
export JAVA_HOME=${JDK_INSTALL_DIR}
export SPARK_LOCAL_IP=${HADOOP_MASTER_IP}
export SPARK_MASTER_IP=${HADOOP_MASTER_HOSTNAME}
export SPARK_MASTER_PORT=7077
export SPARK_WORKER_CORES=${SPARK_WORKER_CORES}
export SPARK_WORKER_INSTANCES=${SPARK_WORKER_INSTANCES}
export SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY}g
EOF

  sudo chown spark:spark -R ${SPARK_INSTALL_DIR}
fi

if [ ! -e /home/spark/start_spark.sh ]; then
  sudo cat << EOF > /home/spark/start_spark.sh
#!/bin/sh

if [ ! -e /home/spark/.hdfs_namenode_format ]; then
  echo "Formatting HDFS name node"
  cd ${HADOOP_INSTALL_DIR}
  bin/hdfs namenode -format
  touch /home/spark/.hdfs_namenode_format
fi

echo "Starting HDFS"
cd ${HADOOP_INSTALL_DIR}
sbin/start-dfs.sh

echo "Starting Spark"
cd ${SPARK_INSTALL_DIR}
sbin/start-all.sh

echo "Succeed!"
EOF

  sudo chown spark:spark /home/spark/start_spark.sh
  sudo chmod 0744 /home/spark/start_spark.sh
fi

if [ ! -e /home/spark/stop.sh ]; then
  sudo cat << EOF > /home/spark/stop_spark.sh
#!/bin/sh

echo "Stopping Spark"
cd ${SPARK_INSTALL_DIR}
sbin/stop-all.sh

echo "Stopping HDFS"
cd ${HADOOP_INSTALL_DIR}
sbin/stop-dfs.sh

echo "Succeed!"
EOF

  sudo chown spark:spark /home/spark/stop_spark.sh
  sudo chmod 0744 /home/spark/stop_spark.sh
fi

echo
echo 'Install Hadoop/Spark completed!'
echo 'You can'
echo "  start Spark via \"ssh spark@${HADOOP_MASTER_IP}\" /home/spark/start_spark.sh"
echo "  stop Spark via \"ssh spark@${HADOOP_MASTER_IP}\" /home/spark/stop_spark.sh"

