#!/bin/bash

apt-get update
echo mysql-server mysql-server/root_password password mysql | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password mysql | sudo debconf-set-selections
apt-get install -qqy mysql-server-5.6

#wget http://dev.mysql.com/get/mysql-apt-config_0.5.3-1_all.deb
#dpkg -i mysql-apt-config*.deb

echo "Access MySQL via \'mysql -uroot -pmysql\'"
exit 0 
