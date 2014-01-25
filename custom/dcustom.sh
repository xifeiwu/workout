#!/bin/sh
set -e

if [ -f ./assist.sh ]; then
    source ./assist.sh
else
    echo -e "\033[2;31m-Bash file assist.sh not found.033[0m"
    exit 1
fi
if [ "$USER" != "root" ] ; then
    warning "You are not run as root user, you should excute sudo."
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

notice "${BASEDIR}/dcustom/${distro}"
exit 0
if [ ! -d ${BASEDIR}/dcustom/${distro} ]; then
    error "Directory ${BASEDIR}/dcustom/${distro} does not exist."
fi
cd ${BASEDIR}/dcustom/${distro}

if [ ! -d squashfs-root ]; then
    error "Directory ${BASEDIR}/dcustom/${distro}/squashfs-root does not exist."
fi
