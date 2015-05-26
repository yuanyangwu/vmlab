#!/bin/sh

sudo apt-get install -y python-pip python-dev vim

grep spark /etc/passwd
if [ "$?" != "0" ]; then
  echo 'Adding user "spark"'
  sudo groupadd -g 2000 spark
  sudo useradd -u 2000 -g spark spark
  echo "spark:spark" | sudo chpasswd
  echo 'spark ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

sudo mkdir -p /app

if [ ! -d /app/jdk1.8.0_45 ]; then
  echo "Installing JDK"
  sudo tar xzf /installer/jdk-8u45-linux-x64.tar.gz -C /app
  sudo chown root:root -R /app/jdk1.8.0_45
  sudo cat << EOF >> /etc/profile

export JAVA_HOME=/app/jdk1.8.0_45
export CLASSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/lib/tools.jar
export PATH=\${JAVA_HOME}/bin:\${PATH}
EOF
fi

if [ ! -d /app/scala-2.10.5 ]; then
  echo "Installing Scala"
  sudo tar xzf /installer/scala-2.10.5.tgz -C /app
  sudo chown root:root -R /app/scala-2.10.5
  sudo cat << EOF >> /etc/profile

export SCALA_HOME=/app/scala-2.10.5
export PATH=\${SCALA_HOME}/bin:\${PATH}
EOF
fi

if [ ! -d /app/hadoop-2.6.0 ]; then
  echo "Installing Hadoop"
  sudo tar xzf /installer/hadoop-2.6.0.tar.gz -C /app
  sudo cat << EOF >> /etc/profile

export HADOOP_FREFIX=/app/hadoop-2.6.0
export HADOOP_COMMON_HOME=\${HADOOP_FREFIX}
export HADOOP_HDFS_HOME=\${HADOOP_FREFIX}
export HADOOP_MAPRED_HOME=\${HADOOP_FREFIX}
export YARN_HOME=\${HADOOP_FREFIX}
export PATH=\${HADOOP_FREFIX}/bin:\${HADOOP_FREFIX}/sbin:\${PATH}
EOF

  sudo mkdir -p /data/hdfs/data
  sudo mkdir -p /data/hdfs/name
  sudo mkdir -p /data/hdfs/sysmapred
  sudo mkdir -p /data/hdfs/localmapred

  sudo cat << EOF > /app/hadoop-2.6.0/etc/hadoop/core-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://hadoop1:8000/</value>
</property>

<property>
<name>io.file.buffer.size</name>
<value>131072</value>
</property>
</configuration>
EOF

  sudo cat << EOF > /app/hadoop-2.6.0/etc/hadoop/hdfs-site.xml
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

  sudo cat << EOF > /app/hadoop-2.6.0/etc/hadoop/yarn-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>yarn.resourcemanager.address</name>
<value>hadoop1:8880</value>
</property>

<property>
<name>yarn.resourcemanager.scheduler.address</name>
<value>hadoop1:8881</value>
</property>

<property>
<name>yarn.resourcemanager.resource-tracker.address</name>
<value>hadoop1:8882</value>
</property>

<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
</configuration>
EOF

  sudo cat << EOF > /app/hadoop-2.6.0/etc/hadoop/mapred-site.xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>

<property>
<name>mapreduce.job.tracker</name>
<value>hdfs://hadoop1:8001</value>
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
  sudo chown spark:spark -R /app/hadoop-2.6.0
  sudo chown spark:spark -R /data/hdfs
fi

if [ ! -d /app/spark-1.3.1 ]; then
  echo "Installing Spark"
  sudo tar xzf /installer/spark-1.3.1-bin-hadoop2.6.tgz -C /app
  sudo mv /app/spark-1.3.1-bin-hadoop2.6 /app/spark-1.3.1
  sudo chown spark:spark -R /app/spark-1.3.1
  sudo cat << EOF >> /etc/profile

EOF
fi


