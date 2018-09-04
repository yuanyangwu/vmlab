#!/bin/bash

sed -i.bak1 's/archive.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list
sed -i.bak2 's/security.ubuntu.com/mirrors.aliyun.com/' /etc/apt/sources.list

apt-get update

apt-get install -y ipython3-notebook python3-pip python3-dev python3-numpy python3-pandas

mkdir -p /home/vagrant/.pip
cat << EOF > /home/vagrant/.pip/pip.conf
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF

pip3 install notebook

echo "jupyter notebook --ip 0.0.0.0" > /home/vagrant/start-ipython-notebook.sh

chown -R /home/vagrant

echo "launch ipython notebook via ./start-ipython-notebook.sh"
echo "open http://192.168.11.51:8888 in browser"
exit 0 
