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


#OUTPATH=$PWD/mkiso_out
#echo warning:you should run as root. But be careful!#
#
#if [ "$USER" != "root" ] ; then
#    echo "error: you are not run as root user, you should excute sudo."
#    exit -1
#fi

#if [ $# -lt 2 ] ; then
#    echo You should execute this script with two param at least as follow:
#    echo sh $0 OUTPATH GENISOPATH
#    exit -1
#fi
#
#if [ ! -d $1 ] ; then
#    echo You should make sure the outpath $1 is a dir that exists
#    exit -1
#fi
#
#if [ ! -d $2 ] ; then
#    echo You should make sure the getisopath $2 is a dir that exists
#    exit -1
#fi


#OUTPATH=$(cd $1; pwd)
#GENISOPATH=$(cd $2; pwd)
#SCRIPTPATH=$(cd "$(dirname $0)"; pwd)
#. $SCRIPTPATH/set_version.sh

ISONAME="$OSNAME-i386-`date +%Y%m%d%H%M`.iso"
if [ $# -gt 1 ] ; then
    ISONAME=$2
fi
echo WORKSPACE: $WORKSPACE
echo LIVECD_PATH: $LIVECD_PATH
echo ROOTFS_PATH: $ROOTFS_PATH
echo ISONAME: $ISONAME
echo OSFULLNAME: $OSFULLNAME

cd $WORKSPACE

if [ ! -d $LIVECD_PATH ] ; then
    echo error: $LIVECD_PATH does not exist.
    exit 1
fi

if [ ! -d $LIVECD_PATH/casper ] ; then
    mkdir $LIVECD_PATH/casper
fi

if [ ! -e $LIVECD_PATH/casper/initrd.lz ] ; then
    echo error: initrd.lz does not exist.
    exit 2
fi

if [ ! -d $ROOTFS_PATH ] ; then
    echo error: squashfs-root $ROOTFS_PATH does not exist.
    exit 3
fi

echo start: $SCRIPT_TOP_PATH/$0
echo Generating $ISONAME in $WORKSPACE.

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
rm -rf $LIVECD_PATH/casper/filesystem.squashfs
mksquashfs $ROOTFS_PATH $LIVECD_PATH/casper/filesystem.squashfs 

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
