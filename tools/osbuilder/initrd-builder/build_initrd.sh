script -fec 'sudo -E AGENT_INIT=yes USE_DOCKER=true sh -x ./initrd_builder.sh "${ROOTFS_DIR}"'
commit="$(git log --format=%h -1 HEAD)"
date="$(date +%Y-%m-%d-%T.%N%z)"
image="kata-containers-initrd-${date}-${commit}"
