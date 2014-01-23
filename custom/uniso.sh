#!/bin/sh
set -e

if [ -f ./assist.sh ]; then
    source ./assist.sh
else
    echo -e "\033[2;31m-Bash file assist.sh not found.033[0m"
    exit 1
fi
if [ "$USER" != "root" ] ; then
    error "You are not run as root user, you should excute sudo."
fi

if [ ! -d ${BASEDIR}/distro ]; then
    error "Directory ${BASEDIR}/distro is not found."
fi
cd ${BASEDIR}/distro
DISTROS=(`ls | grep iso |sed -n 's:\(.*\)\.iso$:\1:p'`)
DSIZE=${#DISTROS[@]}
for ((i=0;i<${DSIZE};i++)); do
    echo $i:${DISTROS[i]}
done
notice_read "Select the distro you want to custom:" num
distro=${DISTROS[num]}
if [ -z ${distro} ]; then
    error "Correct your input."
fi
warning_read "Your selection: ${distro} [Y/n]?" yn
while [ "${yn}" != "y" -a  "${yn}" != "Y" -a "${yn}" != "n" -a "${yn}" != "N" ]
do
    warning_read "Your selection: ${distro} [Y/n]" yn
done
if [ "${yn}" == "N" -o "${yn}" == "n" ] ; then
    error "exit as you expected."
fi

cd ${BASEDIR}
if [ ! -d dcustom ]; then
    mkdir dcustom
fi
cd dcustom
if [ ! -d ${distro} ]; then
    mkdir ${distro}
fi
cd ${distro}
if [ -d myiso ]; then
    warning "Directory ${BASEDIR}/dcustom/${distro}/myiso has exist, and rsync is ignored."
else
    set +e
    umount /mnt
    set -e
    mount ${BASEDIR}/distro/${distro}.iso /mnt
    notice "Rsync from /mnt to ${BASEDIR}/dcustom/${distro}/myiso"
    rsync -av --delete --delete-after --progress --exclude=casper/filesystem.squashfs /mnt/ myiso/
    if [ $? -eq 0 ]; then
        notice "Rsync success."
    else
        error "Error during Rsync from /mnt"
    fi
    umount /mnt
fi
notice "Rsync from ${BASEDIR}/distro/filesystem.squashfs/${distro}/ to ${BASEDIR}/dcustom/${distro}/squashfs-root"
cd ${BASEDIR}
rsync -av --delete --delete-after --progress distro/filesystem.squashfs/${distro}/ dcustom/${distro}/squashfs-root/
if [ $? -eq 0 ]; then
    notice "Rsync success."
else
    error "Error during Rsync from ${BASEDIR}/distro/filesystem.squashfs/${distro}/"
fi
notice "Uniso has finished."

