#!/bin/bash

apt-get update
apt-get install -qqy ipython-notebook python-pip python-dev python-numpy python-pandas

mkdir -p /home/vagrant/.pip
cat << EOF > /home/vagrant/.pip/pip.conf
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/

[install]
trusted-host=mirrors.aliyun.com
EOF

pip install notebook


echo "jupyter notebook --ip 0.0.0.0" > /home/vagrant/start-ipython-notebook.sh
echo "launch ipython notebook via ./start-ipython-notebook.sh"
echo "open http://192.168.11.51:8888 in browser"
exit 0 
