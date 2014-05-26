curl https://raw.githubusercontent.com/c4milo/dobby-boxes/master/coreos/oem/config.yml > /tmp/cloudinit
coreos-install -d /dev/sda -V ${OS_VERSION} -c /tmp/cloudinit
