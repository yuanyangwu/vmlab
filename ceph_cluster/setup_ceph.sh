#!/bin/sh


NODE_ROLE=$1 # example: admin data client
NODE_HOSTNAME_PREFIX=$2 # example: ceph-osd
NODE_IP_PREFIX=$3 # example: 192.168.33.10
NODE_NUMBER=$4

echo "Set up ${NODE_ROLE} node"

if [ ${NODE_ROLE} = "admin" ]; then
  sudo apt-get install -y python-pip python-dev git vim unzip
  mkdir -p ~/.pip
  cat << EOF > ~/.pip/pip.conf
[global]
index-url = http://mirrors.aliyun.com/pypi/simple/
EOF
  sudo pip install ansible
fi

if [ ! -e /etc/hosts.orig ]; then
  echo "Assign ${NODE_HOSTNAME_PREFIX}[0..${NODE_NUMBER}) in /etc/hosts"
  sudo cp -a /etc/hosts /etc/hosts.orig
  sudo cp -a /etc/hosts /etc/hosts.tmp
  sudo grep -v "${NODE_HOSTNAME_PREFIX}" /etc/hosts > /etc/hosts.tmp
  idx=0
  while [ $idx -ne $NODE_NUMBER ]; do
    echo "${NODE_IP_PREFIX}${idx} ${NODE_HOSTNAME_PREFIX}${idx}" >> /etc/hosts.tmp
    idx=$(( $idx + 1 ))
  done
  sudo mv /etc/hosts.tmp /etc/hosts
fi

exist=`grep ceph_admin /etc/passwd`
if [ "$?" != "0" ]; then
  echo 'Adding user "ceph_admin"'
  sudo groupadd -g 1500 ceph_admin
  sudo useradd -m -s /bin/bash -u 1500 -g ceph_admin ceph_admin
  echo "ceph_admin:ceph_admin" | sudo chpasswd
  echo 'ceph_admin ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ceph_admin
  sudo chmod 0440 /etc/sudoers.d/ceph_admin
fi

if [ ! -e /home/ceph_admin/.ssh/id_rsa ]; then
  echo 'Adding SSH key to "ceph_admin" user'

  sudo mkdir /home/ceph_admin/.ssh

  sudo cat << EOF > /home/ceph_admin/.ssh/id_rsa
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEArMAq9o0hS7mKC7BNB2VQ323USYrebq6QZle+TsKlieQJb44O
Ff0/nXeQ2vapNv1UZXf/cYFHX0cXRAZk9nPVjrTdsRp+yBFwF1p8k3dResYDyT1r
8jGdP7OuZvLzs9h0tY67L0153A609XYfi0WJ/Qebporp40Wu9XNhCTu284ZHNM2i
DawByaL2dKIxX8PeF//8flmAFQOfJV3q0KqQv89IcussibdooPpInAUE9OktQb8Y
EjNTqraG95LtgRk4/qvnumQ6vq6LuB7hqSL+drXIOWeLOGNIeZA8CifI4dtCpbgR
fQZhFl5VHtpPHIZqpWDaxI5BWq1yW0LV1RCtUQIDAQABAoIBAQCYrZbLJVyiEq+h
OQY7XR4m+mi/Ps7sP7g725zE+19XCYYVZBWq9ZJ916jc/Vf809T9gRrw9HNiD/DO
HGCrOSEr6UpuNp6KsG7DFSQ5KSGIQu4hs/ltqs/x9xpSvrMI5mvv8uAZJH5pMU5a
CzZB3wnf6hN1FB020uWY5YqDoJVHkJclZHE5Pn+NOmg9JJRdgNuZ/C5Bfyw4d/LG
qww2Xvml4V6MNwabFuxLfSz/cc2YkWvQiVNRo+TzMKX+r45SQHePLCvPUbxhdq9N
HzbiwAtK4qBafs3xANBNQ9L2xPufVQwSSxAZj3+njkPLPujn0ZVulDtOhQ/okl7b
TrtqA+LhAoGBAOKmgmanO2pOz/6Y2tB8ulxLTvHDxB6xtK9gEty3nWruy+nt+MNa
ZhD0EPQo06hyyQ5ca98Q0dPs1hkscMrGM3tEdw8M+0idYTO9WEJ5ZNeoFLswxooU
q6ZR0SPv2AzYSwuEfbm7kvYJz0hGG28BQU6sYIsKsgJcww0SbfA11CldAoGBAMMe
38bTmYYX/7vQX03/HV+PgXU8sbrYUNKfzAKgdUAH0n5ugWB8fQnpquB5LHEn2i5b
McZV4YA0lXA6L4XkYu00rbRFFGOEfnYUL+Qd6xUbPb4ndLU6GrfY07u6R5d1TgKk
17gTn9cJR5qE4eWQ69M21/o37WJH2QUPNXuSUPCFAoGAWwG2/JcLsW0B8V3ZBrv+
bI7EnSkZN6XtQjoWeM+1grlt4XlvWKmUsBwALrmx+0JT3tNXcRMk3a6MbUE97P3W
sBlWoRF6WLbwz8CojtCFoF5aLKuyHMGeBsN1cbOdkdLLl01U2l4p7WcU9xVHcLQV
UAzBGzNpNK+glkAfKsPCc/UCgYEAvR2PhwZQJsfb9g1gUhiSP6y3rQnGuXIv4/U9
ps4e1pC+VAyHGR2Pk6wHEspfaM1XitaYx8M1bS2KKdw7c2qI95+3PKI3wL0KVSf7
wv28fBiLH2Lem0hV3RsrHSjPet0XXzimXKOoqKM1424oBHkSGQVvD/Zk/nzkuyKi
k8Kc8IECgYBtF5g1fJoY+HqxTi8ZqVEZOMKoTAi+HsWjBOONt3U2DjOuUllOow3d
KKeG/jwLiECrJ7cMzBzI2RDU2BUvY1WGbKIAH+ELbUxSd41PBDnAhEzb7eWqBRoR
O0FVi1u6/TcztuhVsIbbSIz9VU+/2EETj1NLF8j0GzyrQRFuUfljjg==
-----END RSA PRIVATE KEY-----
EOF
  sudo chmod 0600 /home/ceph_admin/.ssh/id_rsa

  sudo cat << EOF > /home/ceph_admin/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCswCr2jSFLuYoLsE0HZVDfbdRJit5urpBmV75OwqWJ5Alvjg4V/T+dd5Da9qk2/VRld/9xgUdfRxdEBmT2c9WOtN2xGn7IEXAXWnyTd1F6xgPJPWvyMZ0/s65m8vOz2HS1jrsvTXncDrT1dh+LRYn9B5umiunjRa71c2EJO7bzhkc0zaINrAHJovZ0ojFfw94X//x+WYAVA58lXerQqpC/z0hy6yyJt2ig+kicBQT06S1BvxgSM1Oqtob3ku2BGTj+q+e6ZDq+rou4HuGpIv52tcg5Z4s4Y0h5kDwKJ8jh20KluBF9BmEWXlUe2k8chmqlYNrEjkFarXJbQtXVEK1R ceph_admin@ceph
EOF
  sudo chmod 0644 /home/ceph_admin/.ssh/id_rsa.pub

  sudo cp /home/ceph_admin/.ssh/id_rsa.pub /home/ceph_admin/.ssh/authorized_keys
  sudo chmod 0600 /home/ceph_admin/.ssh/authorized_keys

  if [ ${NODE_ROLE} = "admin" ]; then
    idx=0
    while [ $idx -ne $NODE_NUMBER ]; do
      sudo ssh-keyscan -H -t rsa ${NODE_HOSTNAME_PREFIX}${idx} >> /home/ceph_admin/.ssh/known_hosts
      idx=$(( $idx + 1 ))
    done
    sudo chmod 0644 /home/ceph_admin/.ssh/known_hosts
  fi

  sudo chmod 0700 /home/ceph_admin/.ssh
  sudo chown ceph_admin:ceph_admin -R /home/ceph_admin/.ssh/
fi

if [ ${NODE_ROLE} = "admin" ]; then
  cd /home/ceph_admin
  if [ -e /vagrant/master.zip ]; then
    sudo unzip -q /vagrant/master.zip
  else
    wget https://github.com/ceph/ceph-ansible/archive/master.zip
    sudo unzip -q master.zip
  fi
  sudo cp -fr /vagrant/ansible/* /home/ceph_admin/ceph-ansible-master
  sudo chown ceph_admin:ceph_admin -R /home/ceph_admin/ceph-ansible-master
fi

echo
echo 'Install ceph completed!'

