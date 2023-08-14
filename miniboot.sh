#!/bin/bash
# Assumuptions: SLE15sp4 ISO is mounted at /mnt 
# MiniISO instructions have been followed - see wiki
# All setup and ran from the KVM/Libvirt host
# Cmd: miniboot.sh -H <hostname> -I <IPaddress> -G <Gateway> -O <output ISO name>
#
while getopts H:I:G:O: flag
do
	case "${flag}" in
		H) customHost=${OPTARG};;
		I) customIp=${OPTARG};;
		G) customGw=${OPTARG};;
		O) customisO=${OPTARG};;
	esac
done

sed -e "s/customHost/$customHost/g" -e "s/customIp/$customIp/g" -e "s/customGw/$customGw/g" /tmp/minicd/boot/x86_64/loader/isolinux.template > /tmp/minicd/boot/x86_64/loader/isolinux.cfg
mkisofs -o /data/$customisO.iso -b boot/x86_64/loader/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table /tmp/minicd

virt-install -n $customHost --os-type=Linux --os-variant=sle15sp4 --ram=2048 --vcpu=2 --disk path=/data/$customHost.img,bus=virtio,size=16 --cdrom /data/$customisO.iso --network bridge:br0
