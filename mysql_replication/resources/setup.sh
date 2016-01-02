#!/bin/bash

apt-get update
echo mysql-server mysql-server/root_password password mysql | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password mysql | sudo debconf-set-selections
apt-get install -qqy mysql-server-5.6

#wget http://dev.mysql.com/get/mysql-apt-config_0.5.3-1_all.deb
#dpkg -i mysql-apt-config*.deb

install -g root -o root -m 0644 /vagrant/resources/hosts /etc/hosts

cp /etc/mysql/my.cnf /etc/mysql/my.cnf.orig
cp /vagrant/resources/my.cnf.$(uname -n) /etc/mysql/my.cnf
service mysql restart

mkdir -p /vagrant/tmp
if [ $(uname -n) = "master" ]; then
  mysql -uroot -pmysql < /vagrant/resources/$(uname -n).sql > /vagrant/tmp/mysql.output.$(uname -n)
else
  sh /vagrant/resources/slave.sql.sh | mysql -uroot -pmysql
fi

echo "Access MySQL via \'mysql -uroot -pmysql\'"
exit 0
