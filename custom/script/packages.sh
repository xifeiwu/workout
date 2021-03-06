#!/bin/sh
#set -e

if [ $# -eq 0 ] ; then
    BASEPATH="/home/xifei/Public"
    MATERIALDIR="${BASEPATH}/cosmaterials"
    WORKDIR="${BASEPATH}/OS-Custom"
elif [ $# -eq 2 ] ; then
    MATERIALDIR=$1
    WORKDIR=$2
else
    echo You should execute this script with three param at least as follow:
    echo sh $0 MATERIALDIR WORKDIR
    exit -1
fi

echo -e "\033[31m - custom packages. \033[0m"
cp -r ${MATERIALDIR}/packages/deb-replace.sh ${WORKDIR}/squashfs-root/tmp/

cd ${WORKDIR}
chroot squashfs-root /bin/bash -c "[ -e /proc/mounts ] && umount /proc/"
chroot squashfs-root /bin/bash -c "mount none /proc -t proc"
#chroot squashfs-root /bin/bash -c "dpkg -i /tmp/cos-upgrade_2013.09.30_i386.deb && cos-upgrade"
chroot squashfs-root /bin/bash -c "bash /tmp/deb-replace.sh"
chroot squashfs-root /bin/bash -c "umount /proc/"

mintwelcome_mo="squashfs-root/usr/share/linuxmint/locale/zh_CN/LC_MESSAGES/mintwelcome.mo"
cp ${MATERIALDIR}/packages/mintwelcome.mo ${WORKDIR}/${mintwelcome_mo}

rm /bin/sh
ln -s /bin/bash /bin/sh
