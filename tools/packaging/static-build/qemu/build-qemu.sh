#!/usr/bin/env bash
#
# Copyright (c) 2022 Intel Corporation
#
# SPDX-License-Identifier: Apache-2.0

set -o errexit
set -o nounset
set -o pipefail

kata_packaging_dir="/root/kata-containers/tools/packaging"
kata_packaging_scripts="${kata_packaging_dir}/scripts"

kata_static_build_dir="${kata_packaging_dir}/static-build"
kata_static_build_scripts="${kata_static_build_dir}/scripts"

git clone --depth=1 "${QEMU_REPO}" qemu
pushd qemu
git fetch --depth=1 origin "${QEMU_VERSION}"
git checkout FETCH_HEAD
scripts/git-submodule.sh update meson capstone
${kata_packaging_scripts}/patch_qemu.sh "${QEMU_VERSION}" "${kata_packaging_dir}/qemu/patches"
# PREFIX="${PREFIX}" ${kata_packaging_scripts}/configure-hypervisor.sh -s "${HYPERVISOR_NAME}" | xargs ./configure  --with-pkgversion="${PKGVERSION}"
./configure --disable-live-block-migration --disable-brlapi --disable-docs --disable-curses --disable-gtk --disable-opengl --disable-sdl --disable-spice --disable-vte --disable-vnc --disable-vnc-jpeg --disable-vnc-sasl --disable-auth-pam --disable-glusterfs --disable-libiscsi --disable-libnfs --disable-libssh --disable-bzip2 --disable-lzo --disable-snappy --disable-tpm --disable-slirp --disable-libusb --disable-usb-redir --disable-tcg --static --disable-debug-tcg --disable-tcg-interpreter --disable-qom-cast-debug --disable-libudev --disable-curl --disable-rdma --disable-tools -enable-virtfs --disable-bsd-user --disable-linux-user --disable-sparse --disable-vde --disable-nettle --disable-xen --disable-linux-aio --disable-capstone --disable-virglrenderer --disable-replication --disable-smartcard --disable-guest-agent --disable-guest-agent-msi --disable-vvfat --disable-vdi --disable-qed --disable-qcow1 --disable-bochs --disable-cloop --disable-dmg --disable-parallels --enable-kvm --enable-vhost-net --enable-virtfs --enable-attr --enable-cap-ng --enable-seccomp --enable-avx2 --enable-avx512f --enable-libpmem --enable-malloc-trim --target-list=x86_64-softmmu --extra-cflags=" -O2 -fno-semantic-interposition -falign-functions=32 -D_FORTIFY_SOURCE=2" --extra-ldflags=" -z noexecstack -z relro -z now" --prefix=/opt/kata --libdir=/opt/kata/lib/kata-qemu --libexecdir=/opt/kata/libexec/kata-qemu --datadir=/opt/kata/share/kata-qemu --with-pkgversion=kata-static
make -j"$(nproc +--ignore 1)"
make install DESTDIR="${QEMU_DESTDIR}"
popd
${kata_static_build_scripts}/qemu-build-post.sh
mv "${QEMU_DESTDIR}/${QEMU_TARBALL}" /share/

sleep 5000