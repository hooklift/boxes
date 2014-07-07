curl https://raw.githubusercontent.com/c4milo/dobby-boxes/master/oem/config.yml > /tmp/cloudinit
coreos-install -d /dev/sda -V current -C ${OS_VERSION} -c /tmp/cloudinit
