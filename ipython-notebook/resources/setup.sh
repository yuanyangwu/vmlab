#!/bin/bash

apt-get update
apt-get install -qqy ipython-notebook

echo "ipython notebook --pylab inline --ip 0.0.0.0" > /home/vagrant/start-ipython-notebook.sh
echo "launch ipython notebook via ./start-ipython-notebook.sh"
echo "open http://192.168.11.51:8888 in browser"
exit 0 
