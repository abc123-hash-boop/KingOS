# Chroot tool, make sure chroot is installed.
# Make sure you are root or you can run sudo.

sudo mount --bind /dev rootfs/dev
sudo mount --bind /dev/pts rootfs/dev/pts
sudo mount --bind /proc rootfs/proc
sudo mount --bind /sys rootfs/sys
sudo mount --bind /run rootfs/run


sudo chroot rootfs /bin/bash


sudo umount rootfs/run
sudo umount rootfs/dev/pts
sudo umount rootfs/dev
sudo umount rootfs/proc
sudo umount rootfs/sys

