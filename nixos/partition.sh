set -x
sgdisk -n 1:2048:+512M -t 1:ef00 -n 2:0:0 -t 2:8e00 /dev/sda
vgcreate vg0 /dev/sda2
lvcreate -l +100%FREE vg0 -n lv0
mkfs.vfat /dev/sda1
mkfs.ext4 -F -m 0 -q -L root /dev/mapper/vg0-lv0
mount -o noatime,errors=remount-ro /dev/mapper/vg0-lv0 /mnt
mkdir /mnt/boot
mount -o noatime,errors=remount-ro /dev/sda1 /mnt/boot
