#!/bin/bash

#apt-get update
#apt-get install -qqy apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
#echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list

echo "deb http://mirrors.aliyun.com/docker-engine/apt/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list

apt-get update
#apt-get install -qqy linux-image-extra-$(uname -r)
apt-get install -qqy docker-engine

# add user "vagrant" to group "docker"
usermod -aG docker vagrant

curl -sL https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/bin/docker-compose
chmod a+x /usr/bin/docker-compose

# install registry
#docker pull daocloud.io/registry:2
##docker run -d -p 5000:5000 -v "$(pwd)"/data:/tmp/registry-dev --restart=always --name local-registry registry:2
#docker run -d -p 5000:5000 --restart=always --name local-registry registry:2

exit 0 
