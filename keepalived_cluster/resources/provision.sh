#!/bin/bash

apt-get install -qqy keepalived

cp /vagrant/resources/keepalived.conf.$(uname -n) /etc/keepalived/keepalived.conf

service keepalived start

cp /etc/hosts{,.orig} 
cat /vagrant/resources/hosts >> /etc/hosts

exit 0 
