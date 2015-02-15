#!/bin/bash
export OSNAME=mylinux
export WORKSPACE=/home/cos/distro
export ROOTFS_PATH=$WORKSPACE/squashfs-root
export LIVECD_PATH=$WORKSPACE/$OSNAME

export BASE_RELEASE=trusty
export BASE_REPO_ONLINE=http://192.168.160.169/cos3/ubuntu/

export OSARCH=i386
export OSVERSION=1.0
export OSVERSIONNAME=my_version_name
export OSVERSIONFULLNAME=my_version_fullname

export SCRIPT_TOP_PATH=$(cd "$(dirname $0)"; pwd)


