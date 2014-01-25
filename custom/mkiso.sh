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

if [ ! -d ${BASEDIR}/dcustom/${distro} ]; then
    error "Directory ${BASEDIR}/dcustom/${distro} does not exist."
fi
cd ${BASEDIR}/dcustom/${distro}/
if [ ! -d ./myiso ]; then
    error "Directory ./myiso dost not exist."
fi
if [ ! -d ./squashfs-root ]; then
    error "Directory ./squashfs-root dost not exist."
fi

STARTTIME=`date +%m-%d-%H.%M`
ISONAME="myiso-${STARTTIME}.iso"
KVMIMGNAME="myiso-${STARTTIME}.img"
STARTKVM=true
USERNAME=xifei
OUTPUT=${BASEDIR}/dout/${distro}
if [ ! -d ${OUTPUT} ]; then
    mkdir -p ${OUTPUT}
fi
chown ${USERNAME}.${USERNAME} ${OUTPUT}

notice "Generate ${BASEDIR}/dcustom/${distro}/myiso/capser/filesystem.manifest(-desktop)"
chroot squashfs-root dpkg-query -W --showformat='${Package} ${Version}\n' > myiso/casper/filesystem.manifest
cp myiso/casper/filesystem.manifest myiso/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' myiso/casper/filesystem.manifest-desktop
sed -i '/casper/d' myiso/casper/filesystem.manifest-desktop
sed -i '/gparted/d' myiso/casper/filesystem.manifest-desktop
sed -i '/libdebian-installer/d' myiso/casper/filesystem.manifest-desktop
sed -i '/user-setup/d' myiso/casper/filesystem.manifest-desktop

notice "make squashfs for directory ${BASEDIR}/dcustom/${distro}/squashfs-root"
if [ -f myiso/casper/filesystem.squashfs ]; then
    rm myiso/casper/filesystem.squashfs
fi
mksquashfs squashfs-root myiso/casper/filesystem.squashfs

notice "Generate ${BASEDIR}/dcustom/${distro}/myiso/md5sum.txt"
cd myiso
find . -type f -print0 | xargs -0 md5sum > md5sum.txt

notice "Making ISO file in ${BASEDIR}/dcustom/${distro}/myiso"
mkisofs -r -V "${distro}" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "${OUTPUT}/${ISONAME}" .
notice "Output: ${BASEDIR}/dout/${distro}/$ISONAME"

cd ${OUTPUT}
chown ${USERNAME}.${USERNAME} $ISONAME
if ${STARTKVM}; then
    touch myiso-${STARTTIME}.sh
    echo """#!/bin/sh
if [ -z \"\$1\" ] ; then
    echo \"you should put a parameter.\"
    exit
fi
SHNAME=\$0
case \$1 in
    \"start\")
        kvm -m 512 -hda $KVMIMGNAME -cdrom $ISONAME
    ;;
    \"delete\")
        name=\${SHNAME%.sh}
        if [ ! -z \$name ] ; then
            rm \$name.*
        fi
    ;;
    \"reinstall\")
        qemu-img create -f raw $KVMIMGNAME 12G
        kvm -m 512 -hda $KVMIMGNAME -cdrom $ISONAME
    ;;
esac""" > myiso-${STARTTIME}.sh
    chown ${USERNAME}.${USERNAME} myiso-${STARTTIME}.sh
fi

#if [ "$MKINITRD" == "true" ] ; then
#    cd initrd_lz
#    find . | cpio -o -H newc | gzip -c > ./initrd.gz
#    mv initrd.gz ../mymint/casper/initrd.lz
#    cd ..
#else
#    echo "==make initrd is ignored.=="
#fi
