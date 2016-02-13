#!/bin/bash

apt-get update
apt-get install -qqy postgresql

# set password for user "postgres"
echo "ALTER USER postgres WITH PASSWORD 'postgres';" | sudo -u postgres psql

echo "Access PostgreSQL via \'psql -h localhost -U postgres\' with password \'postgres\'"
exit 0 
