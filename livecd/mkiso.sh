#!/bin/sh
#$1: path of script top dir.
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit 1
fi
SCRIPT_TOP_PATH=$1
if [ -f $SCRIPT_TOP_PATH/config.sh ]; then
    source $SCRIPT_TOP_PATH/config.sh
else
    echo error: $SCRIPT_TOP_PATH/config.sh does not exist.
    exit 2
fi
CUR_SCRIPT=$SCRIPT_TOP_PATH/$0
CUR_PATH=$(cd "$(dirname $0)"; pwd)

KERNEL_VERSION_FULL=3.13.0-45-generic
ISONAME="$OSNAME-i386-`date +%Y%m%d%H%M`.iso"
#if [ $# -gt 1 ] ; then
#    ISONAME=$2
#fi
notice CUR_SCRIPT: $CUR_SCRIPT
echo CUR_PATH: $CUR_PATH
echo WORKSPACE: $WORKSPACE
echo LIVECD_PATH: $LIVECD_PATH
echo ROOTFS_PATH: $ROOTFS_PATH
echo ISONAME: $ISONAME
echo OSFULLNAME: $OSFULLNAME
echo KERNEL_VERSION_FULL: $KERNEL_VERSION_FULL

function create_casper()
{
    if [ -d $LIVECD_PATH/casper ] ; then
        echo rm -rf $LIVECD_PATH/casper
        rm -rf $LIVECD_PATH/casper
    fi
    mkdir -p $LIVECD_PATH/casper
    sudo chroot $ROOTFS_PATH /bin/bash -c "update-initramfs -u" || return 1
    if [ ! -f $ROOTFS_PATH/boot/vmlinuz-${KERNEL_VERSION_FULL} -o ! -f $ROOTFS_PATH/boot/initrd.img-${KERNEL_VERSION_FULL} ]; then
        error $ROOTFS_PATH/boot/vmlinuz-${KERNEL_VERSION_FULL} or $ROOTFS_PATH/boot/initrd.img-${KERNEL_VERSION_FULL} does not exist.
        return 1
    fi
    sudo cp $ROOTFS_PATH/boot/vmlinuz-${KERNEL_VERSION_FULL} $LIVECD_PATH/casper/vmlinuz || return 1
    sudo cp $ROOTFS_PATH/boot/initrd.img-${KERNEL_VERSION_FULL} $LIVECD_PATH/casper/initrd.lz || return 1
    echo Generating manifest...
    sudo chroot $ROOTFS_PATH dpkg-query -W --showformat='${Package} ${Version}\n' > $LIVECD_PATH/casper/filesystem.manifest
    cp $LIVECD_PATH/casper/filesystem.manifest $OSNAME/casper/filesystem.manifest-desktop
    sed -i '/ubiquity/d' $LIVECD_PATH/casper/filesystem.manifest-desktop
    sed -i '/casper/d' $LIVECD_PATH/casper/filesystem.manifest-desktop
    sed -i '/libdebian-installer/d' $LIVECD_PATH/casper/filesystem.manifest-desktop
    sed -i '/user-setup/d' $LIVECD_PATH/casper/filesystem.manifest-desktop
    printf $(sudo du -sx --block-size=1 . | cut -f1) > $LIVECD_PATH/casper/filesystem.size
    sudo chroot $ROOTFS_PATH /bin/bash -c "cd /home && rm -rf *"

#echo gzip initrd
#cd initrd_lz
#if [ -f initrd ] ; then
#    rm initrd
#fi
#find . | cpio --quiet --dereference -o -H newc>./initrd
#gzip initrd
#mv initrd.gz ../$OSNAME/casper/initrd.lz
#cd ..

    echo Making squashfs...
    #rm -rf $LIVECD_PATH/casper/filesystem.squashfs
    mksquashfs $ROOTFS_PATH $LIVECD_PATH/casper/filesystem.squashfs || return 1
    return 0
}
cd $WORKSPACE


if [ ! -d $LIVECD_PATH ] ; then
    mkdir -p $LIVECD_PATH
fi

if [ ! -d $ROOTFS_PATH ] ; then
    error squashfs-root $ROOTFS_PATH does not exist.
    exit 1
fi

echo Generating $ISONAME in $WORKSPACE.

create_casper || exit 2

echo Generating md5sum...
cd $LIVECD_PATH
find . -type f -print0 | xargs -0 md5sum > MD5SUMS
find . -type f -print0 | xargs -0 md5sum > md5sum.txt
cd ..

echo Making ISO...
cd $LIVECD_PATH
mkisofs -r -V "$OSFULLNAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$WORKSPACE/$ISONAME" .
echo mkiso has finished.
cd ..
ls -l $WORKSPACE/$ISONAME
echo you can test this iso by executing the command as follows:
echo kvm -m 512 -cdrom $WORKSPACE/$ISONAME -boot order=d
