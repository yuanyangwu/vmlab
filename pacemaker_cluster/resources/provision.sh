#!/bin/bash

cp /etc/hosts{,.orig} 
cat /vagrant/resources/hosts >> /etc/hosts

# pacemaker 1.1.10, corosync 2.3.3, crmsh 1.2.5
apt-get install -qqy pacemaker sysv-rc-conf

echo "START=yes" > /etc/default/corosync
cp /etc/corosync/corosync.conf{,.orig}
cp /vagrant/resources/corosync.conf.$(uname -n) /etc/corosync/corosync.conf

# "authkey" is created by "corosync-keygen -l"
install -g root -o root -m 0400 /vagrant/resources/authkey /etc/corosync/

sysv-rc-conf corosync off
service corosync start
service pacemaker start

# configure resource at last node
if [ $(uname -n) = "server02" ]; then

echo "configure pacemaker resources..."

crm configure property \$id="cib-bootstrap-options" \
  no-quorum-policy="ignore" \
  stonith-enabled="false" \
  stonith-action="reboot" \
  default-resource-stickiness="100"
#  expected-quorum-votes="1"

crm configure primitive vip ocf:heartbeat:IPaddr2 \
  params ip="192.168.11.50" cidr_netmask="24" \
  nic="eth1" iflabel="vip" \
  op monitor interval="30s"

fi

# status
#crm status
#crm configure verify
#corosync-cfgtool -s
#corosync-quorumtool -l

# help
#crm ra list ocf
#crm ra meta ocf:heartbeat:IPaddr2

exit 0 
