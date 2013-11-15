#!/bin/bash

# Set up sudo
echo %dobby ALL=NOPASSWD:ALL > /etc/sudoers.d/dobby
chmod 0440 /etc/sudoers.d/dobby

# Setup sudo to allow no-password sudo for "sudo"
usermod -a -G sudo dobby

# Installing dobby keys
#mkdir /home/dobby/.ssh
#chmod 700 /home/dobby/.ssh
#cd /home/dobby/.ssh
#wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
#chmod 600 /home/vagrant/.ssh/authorized_keys
#chown -R vagrant /home/vagrant/.ssh

# Install NFS for Dobby
#apt-get update
#apt-get install -y nfs-common
