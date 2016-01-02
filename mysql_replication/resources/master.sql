CREATE USER 'repl'@'%' IDENTIFIED BY 'repl_password';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

FLUSH TABLES WITH READ LOCK;
SHOW MASTER STATUS \G;
#  *************************** 1. row ***************************
#               File: mysql-bin.000001
#           Position: 411 
#       Binlog_Do_DB: 
#   Binlog_Ignore_DB: 
#  Executed_Gtid_Set: 
#  1 row in set (0.00 sec)
#  
#  ERROR: 
#  No query specified
#  
UNLOCK TABLES;

