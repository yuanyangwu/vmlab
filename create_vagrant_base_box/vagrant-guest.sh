#!/bin/sh

echo 'apply insecure public certificate'
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
mv vagrant.pub ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys


echo 'set root password to "vagrant"'
echo "root:vagrant" | sudo chpasswd

cat << EOF > vagrant-privillege.sh
#!/bin/sh

if [ ! -e /etc/sudoers.vagrant ] ; then
  echo 'configure vagrant NOPASSWD'
  cp -a /etc/sudoers /etc/sudoers.vagrant
  echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
fi

if [ ! -e /etc/ssh/sshd_config.vagrant ] ; then
  echo 'turn off UseDNS'
  cp -a /etc/ssh/sshd_config /etc/ssh/sshd_config.vagrant
  echo 'UseDNS no' >> /etc/ssh/sshd_config
fi

if [ ! -e /etc/apt/sources.list.vagrant ] ; then
  echo 'configure ubuntu source'
  cp -a /etc/apt/sources.list /etc/apt/sources.list.vagrant
  sed 's;http.*com;http://mirrors.aliyun.com;' /etc/apt/sources.list.vagrant > /etc/apt/sources.list

  apt-get -y update
  apt-get -y upgrade
fi

if [ ! -e /media/VBoxGuestAdditions ] ; then
  echo 'install VirtualBox addon'
  apt-get -y install linux-headers-generic build-essential dkms
  mkdir -p /media/VBoxGuestAdditions
  mount /dev/cdrom /media/VBoxGuestAdditions && \
  sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
  if [ "$?" != "0" ]; then
    umount /media/VBoxGuestAdditions
    rm -fr /media/VBoxGuestAdditions
    echo 'Please check VirtualBox Guest Addon CD is added to VM CDROM'
    echo 'Download http://download.virtualbox.org/virtualbox/\${VIRTUALBOX_VERSION}/VBoxGuestAdditions_\${VIRTUALBOX_VERSION}.iso'
    exit 2
  fi
  umount /media/VBoxGuestAdditions
fi

echo "clean"
apt-get clean
rm -fr /tmp/*

EOF

sudo sh ./vagrant-privillege.sh
sudo shutdown -h now

