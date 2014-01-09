#!/bin/bash
BASEPATH="/home/xifei/Public"
PROJECTDIR="${BASEPATH}/project/build"
ORIGINISO="${BASEPATH}/OS-ISO/linuxmint-15-cinnamon-dvd-32bit.iso"
MATERIALDIR="${BASEPATH}/OS-Release/app"
WORKDIR="${BASEPATH}/OS-Release"
GENISODIR="${BASEPATH}/OS-ISO"

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute sudo."
    exit
fi

if [ ! -e ${ORIGINISO} ] ; then
    echo "can not find file ${ORIGINISO}"
    exit -1
fi
if [ ! -e ${WORKDIR} ] ; then
    echo "can not find directory ${WORKDIR}"
    exit -1
fi
if [ ! -e ${MATERIALDIR} ] ; then
    echo "can not find directory ${MATERIALDIR}"
    exit -1
fi
if [ ! -e ${GENISODIR} ] ; then
    echo "can not find directory ${GENISODIR}"
    exit -1
fi

if [ -e ${WORKDIR}/initrd_lz ] ; then
    rm -rf ${WORKDIR}/initrd_lz
fi
if [ -e ${WORKDIR}/mymint ] ; then
    rm -rf ${WORKDIR}/mymint
fi
if [ -e ${WORKDIR}/squashfs-root ] ; then
    rm -rf ${WORKDIR}/squashfs-root
fi

sh ${PROJECTDIR}/release.sh ${ORIGINISO} ${MATERIALDIR} ${WORKDIR} ${GENISODIR}


#echo ISOPATH <===> ORIGINISO
#echo APPPATH <===> MATERIALDIR
#echo OUTPATH <===> WORKDIR
