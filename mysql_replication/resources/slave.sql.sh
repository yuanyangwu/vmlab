#!/bin/sh

LOG_FILE=`cat /vagrant/tmp/mysql.output.master | grep 'File: ' | sed 's/^ *File: //'`
LOG_POS=`cat /vagrant/tmp/mysql.output.master | grep 'Position: ' | sed 's/^ *Position: //'`

cat << EOF
CHANGE MASTER TO MASTER_HOST='master', MASTER_USER='repl',
  MASTER_PASSWORD='repl_password', MASTER_LOG_FILE="$LOG_FILE", MASTER_LOG_POS=$LOG_POS;

START SLAVE;
SHOW SLAVE STATUS \G;
EOF
