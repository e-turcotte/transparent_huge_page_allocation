#!/bin/bash

set -e

HOST_SRC_DIR="/home/amansoor/spec_run"
HOST_VIRTIO_SOCK_PATH="/tmp/vhostqemu-spec-build.sock"
QEMU_IMG_PATH="./image/bookworm.img"

###################
# Mount host fs in the vm using virtiofsd
##################
# turbo kill virtio
# sudo rm ${HOST_VIRTIO_SOCK_PATH} || true

# dumb ass command fucks up the cli.
# seriously fuck all software.
# sudo /usr/lib/qemu/virtiofsd --socket-path=${HOST_VIRTIO_SOCK_PATH} -o source=${HOST_SRC_DIR} > /dev/null&

# virtiofsd takes some time to start... 
sleep 2

###################
# Launch QEMU
##################

# sudo required to access the virtio-fs.
# would really like to remove it, but its too much headache.
# everyone says a different thing to fix and none of them work.

# cpu host requires sudo? Maybe there is some KVM group I can use...
# -chardev socket,id=char0,path=${HOST_VIRTIO_SOCK_PATH} \
# -device vhost-user-fs-pci,chardev=char0,tag=spec_run_virt \

sudo qemu-system-x86_64 \
        -cpu host \
	-m 2G \
	-smp 2 \
	-kernel ./arch/x86/boot/bzImage \
	-append "console=ttyS0 root=/dev/sda earlyprintk=serial net.ifnames=0" \
	-drive file=${QEMU_IMG_PATH},format=raw \
	-net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
	-net nic,model=e1000 \
	-enable-kvm \
	-nographic \
	-pidfile vm.pid \
	2>&1 | tee vm.log
