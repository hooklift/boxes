#!/bin/bash
# This script is heavily based on https://raw.githubusercontent.com/coreos/init/master/bin/coreos-install
# The reason we are writing a custom script is due to 
# CoreOS being young and alpha releases not being pushed up 
# as often as we would like to

CLOUDINIT=$(cat  <<EOF
#cloud-config
coreos:
  update:
    reboot-strategy: best-effort
  etcd: 
    discovery: https://discovery.etcd.io/fcd5226a0a8ac99a12eae21ca7bb1e51
  units:
    - name: docker-tcp.socket
      command: start
    - name: docker.service
      command: start

ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2BLp1n2SBoTGRvUxDx9xK1s6ZDawFrmgVmpK04rRna3xzVfpx+JmvXwmKjxehOzZZdYdVS3LUad3QvHlBIWQZg0jclR0lQxvUMOuh7PVNo0s4k4a5KjU4dC65AJeKLUJxxfkGZkHcD73Pz1cIEadYOAPrkm0gpyXjQ/q1ztT3vDEQX247UOUDSO22E/bgdML6gqgt7WXeigak2qi5XhkgMsPz9AaD8DI0wV5/VylAQKkLv0Km+KAixxbNXGrgIHW+6rkXo6uILA1tE5Gpm1ndQoLgqdkzShKbTsOOkJlFzKtnvHVXRI/lsdrsGNoMo1ca5squsYRsmdxyxjcOT2Db
EOF
)

DEVICE="/dev/sda"


echo "Installing CoreOS..."

VERSION_ID="324.1.0"
set -e -o pipefail

# Everything we do should be user-access only!
umask 077

# Image signing key: buildbot@coreos.com
GPG_LONG_ID="50E0885593D2DCB4"
GPG_KEY="-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2.0.20 (GNU/Linux)

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
BeiJ6tEeDHDzdA==
=4Qn0
-----END PGP PUBLIC KEY BLOCK-----
"

if ! [[ $(lsblk -n -d -o TYPE "${DEVICE}") =~ ^(disk|loop|lvm)$ ]]; then
    echo "$0: Target block device (${DEVICE}) is not a full disk." >&2
    exit 1
fi

if [[ ! -w "${DEVICE}" ]]; then
    echo "$0: Target block device (${DEVICE}) is not writable (are you root?)" >&2
    exit 1
fi

IMAGE_NAME="coreos_production_image.bin.bz2"
BASE_URL="http://storage.core-os.net/coreos/amd64-usr/${VERSION_ID}"
IMAGE_URL="${BASE_URL}/${IMAGE_NAME}"
SIG_NAME="${IMAGE_NAME}.sig"
SIG_URL="${BASE_URL}/${SIG_NAME}"

if ! wget --spider --quiet "${IMAGE_URL}"; then
    echo "$0: Image URL unavailable: $IMAGE_URL" >&2
    exit 1
fi

if ! wget --spider --quiet "${SIG_URL}"; then
    echo "$0: Image signature unavailable: $SIG_URL" >&2
    exit 1
fi

# Pre-flight checks pass, lets get this party started!
WORKDIR=$(mktemp --tmpdir -d coreos-install.XXXXXXXXXX)
trap "rm -rf '${WORKDIR}'" EXIT

# Setup GnuPG for verifying the image signature
export GNUPGHOME="${WORKDIR}/gnupg"
mkdir "${GNUPGHOME}"
gpg --batch --quiet --import <<<"$GPG_KEY"

echo "Downloading and verifying ${IMAGE_NAME}..."
wget -O "${WORKDIR}/${IMAGE_NAME}" "${IMAGE_URL}"
wget --no-verbose -O "${WORKDIR}/${SIG_NAME}" "${SIG_URL}"
if ! gpg --batch --trusted-key "${GPG_LONG_ID}" \
    --verify "${WORKDIR}/${SIG_NAME}"
then
    echo "$0: GPG signature verification failed for ${IMAGE_NAME}" >&2
    exit 1
fi

echo "Writing ${IMAGE_NAME} to ${DEVICE}..."
bunzip2 -v --stdout "${WORKDIR}/${IMAGE_NAME}" >"${DEVICE}"

# inform the OS of partition table changes
blockdev --rereadpt "${DEVICE}"

# The ROOT partition should be #9 but make no assumptions here!
# Also don't mount by label directly in case other devices conflict.
ROOT_DEV=$(blkid -t "LABEL=ROOT" -o device "${DEVICE}"*)

if [[ -z "${ROOT_DEV}" ]]; then
    echo "Unable to find new ROOT partition on ${DEVICE}" >&2
    exit 1
fi

echo "Provisioning..."
mkdir -p "${WORKDIR}/rootfs"
mount -t btrfs -o subvol=root "${ROOT_DEV}" "${WORKDIR}/rootfs"
trap "umount '${WORKDIR}/rootfs' && rm -rf '${WORKDIR}'" EXIT


mkdir -p "${WORKDIR}/rootfs/var/lib/coreos-install"
echo "${CLOUDINIT}" > "${WORKDIR}/rootfs/var/lib/coreos-install/user_data"

## Installing on ${WORKDIR}/rootfs/
# 1. Install Consul
echo "Installing Consul..."

umount "${WORKDIR}/rootfs"

rm -rf "${WORKDIR}"
trap - EXIT

echo "Success! CoreOS ${VERSION_ID} is installed on ${DEVICE}"