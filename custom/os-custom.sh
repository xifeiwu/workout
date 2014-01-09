#!/bin/sh
BASEPATH="/home/xifei/Public"
PROJECTDIR="${BASEPATH}/project/build"
ORIGINISO="${BASEPATH}/OS-ISO/linuxmint-15-cinnamon-dvd-32bit.iso"
MATERIALDIR="${BASEPATH}/cosmaterials"
WORKDIR="${BASEPATH}/OS-Custom"
GENISODIR="${BASEPATH}/OS-ISO"

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute sudo."
    exit
fi

if [ ! -e ${ORIGINISO} ] ; then
    echo "can not find file ${ORIGINISO}"
    exit -1
fi
if [ ! -e ${MATERIALDIR} ] ; then
    echo "can not find directory ${MATERIALDIR}"
    exit -1
fi
if [ ! -e ${WORKDIR} ] ; then
    echo "can not find directory ${WORKDIR}"
    exit -1
else
    echo -e "\033[31m - removing directory ${WORKDIR}. \033[0m"
    rm -rf ${WORKDIR}/*
fi
if [ ! -e ${GENISODIR} ] ; then
    echo "can not find directory ${GENISODIR}"
    exit -1
fi

echo ORIGINISO=${ORIGINISO}
echo MATERIALDIR=${MATERIALDIR}
echo WORKDIR=${WORKDIR}
echo GENISODIR=${GENISODIR}

sh ./uniso.sh $ORIGINISO $WORKDIR
#sh ./script/initrd.sh $MATERIALDIR $WORKDIR
sh ./script/packages.sh $MATERIALDIR $WORKDIR
sh ./script/cos-info.sh $MATERIALDIR $WORKDIR
sh ./script/ubiquity.sh $MATERIALDIR $WORKDIR
#sh ./script/file-substitute.sh $MATERIALDIR $WORKDIR
#sh ./script/firefox.sh $MATERIALDIR $WORKDIR
sh ./mkiso-my.sh $WORKDIR $GENISODIR
