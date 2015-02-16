#!/bin/sh
#$1: path of script top dir.

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

notice CUR_SCRIPT: $CUR_SCRIPT
echo CUR_PATH: $CUR_PATH
echo ROOTFS_PATH: $ROOTFS_PATH
echo OSARCH: $OSARCH
echo BASE_RELEASE: $BASE_RELEASE
echo LIVECD_PATH: $LIVECD_PATH

function checktools()
{
    command -v unsquashfs > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: squashfs-tools has not been installed.
        return 1
    fi
    command -v debootstrap > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: debootstrap has not been installed.
        return 1
    fi
    return 0
}

function mroot()
{
    echo Begin to debootstrap...
    echo sudo debootstrap --arch=${OSARCH} --no-check-gpg ${BASE_RELEASE} $ROOTFS_PATH ${BASE_REPO_ONLINE} || return 1
    sudo debootstrap --arch=${OSARCH} --no-check-gpg ${BASE_RELEASE} $ROOTFS_PATH || return 1
    #apt-get install linux-generic capser
    echo End debootstraping...
}

function mrootbuilder()
{
    if [ ! -d $ROOTFS_PATH ] ; then
        echo ERROR: dir $ROOTFS_PATH has not exist.
        return 1
    fi
    if [ ! -d $CUR_PATH/apt/sources.list.d -o ! -d $CUR_PATH/apt/preferences.d ]; then
        echo dir $CUR_PATH/apt/sources.list.d or $CUR_PATH/apt/preferences.d does not exist.
        return 2
    fi


    sudo cp -r $CUR_PATH/apt/sources.list.d $ROOTFS_PATH/etc/apt/
    sudo cp -r $CUR_PATH/apt/preferences.d $ROOTFS_PATH/etc/apt/
    #sudo cp /etc/hosts $ROOTFS_PATH/etc/hosts
    #sudo cp /etc/resolv.conf $ROOTFS_PATH/etc/resolv.conf
    #sudo cp $T/build/core/srcbuild/official-package-repositories.list $ROOTFS_PATH/etc/apt/sources.list
    #sudo cp $T/build/core/srcbuild/preferences $ROOTFS_PATH/etc/apt/preferences
    #sudo cp $T/build/core/srcbuild/99myown $ROOTFS_PATH/etc/apt/apt.conf.d/99myown

    sudo mount --bind /dev $ROOTFS_PATH/dev
    #backup /sbin/initctl in squashfs-root
    sudo chroot $ROOTFS_PATH /bin/bash -c "sudo cp /sbin/initctl /sbin/initctl.bak"
    sudo chroot $ROOTFS_PATH /bin/bash -c "mount none -t proc /proc"
    sudo chroot $ROOTFS_PATH /bin/bash -c "mount none -t sysfs /sys"
    sudo chroot $ROOTFS_PATH /bin/bash -c "mount none -t devpts /dev/pts"
    sudo chroot $ROOTFS_PATH /bin/bash -c "export HOME=/root"
    sudo chroot $ROOTFS_PATH /bin/bash -c "export LC_ALL=C"
    sudo chroot $ROOTFS_PATH /bin/bash -c "apt-get -y --force-yes update" || return 1
    #sudo chroot $ROOTFS_PATH /bin/bash -c "apt-get -y -f install" || return 1
    sudo chroot $ROOTFS_PATH /bin/bash -c "apt-get -y install dbus" || return 1 # ???
    sudo chroot $ROOTFS_PATH /bin/bash -c "dbus-uuidgen > /var/lib/dbus/machine-id"
    sudo chroot $ROOTFS_PATH /bin/bash -c "dpkg-divert --local --rename --add /sbin/initctl"
    sudo chroot $ROOTFS_PATH /bin/bash -c "ln -s /bin/true /sbin/initctl"
    sudo rm -f $CUR_PATH/fail_stage1
    sudo rm -f $CUR_PATH/fail_stage2
    sudo rm -f $CUR_PATH/fail_stage3
    #sudo chroot $ROOTFS_PATH /bin/bash -c "apt-get -y -f install" || return 1

    # stage0 install close source pkgs (Third party packages not in official)
    #echo "------------------------------stage0------------------------------------------"
    #sudo mkdir $ROOTFS_PATH/3rdpart || return
    #sudo cp  $CUR_PATH/3rdpart/*.deb $ROOTFS_PATH/3rdpart || return
    #sudo chroot $ROOTFS_PATH /bin/bash -c "cd 3rdpart && dpkg -i *.deb" || return
    #sudo chroot $ROOTFS_PATH /bin/bash -c "rm -rf 3rdpart" || return

    # stage1
    echo "------------------------------stage1------------------------------------------"
    while read list
    do
        pkgsname=`echo $list | awk '{print $1}'`
        if [ ${pkgsname:0:1} == "#" ]; then
            notice package $pkgsname is ignored.
            continue
        fi
        notice DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated ${pkgsname}
        sudo chroot $ROOTFS_PATH /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $CUR_PATH/fail_stage1
        fi
    done < $CUR_PATH/filesystem.manifest
#return 4
    # stage 2
    echo "------------------------------stage2------------------------------------------"
    while read pkgsname
    do
        sudo chroot $ROOTFS_PATH /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $CUR_PATH/fail_stage2
        fi
    done <  $CUR_PATH/fail_stage1

    # stage3 force install
    echo "------------------------------stage3------------------------------------------"
    while read pkgsname
    do
        sudo chroot $ROOTFS_PATH /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --force-yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $CUR_PATH/fail_stage3
        fi
    done <  $CUR_PATH/fail_stage2

    # clean unnecessary packages
    echo "-----------apt-get autoremove, clean unnecessary dependency packages---------"
    # autoremove is used to remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed.
    #sudo chroot $ROOTFS_PATH /bin/bash -c "apt-get -y --force-yes autoremove" || return 1
    #sudo chroot $ROOTFS_PATH /bin/bash -c "apt-get -y --force-yes clean" || return 1

    #clean squashfs
#    sudo chroot $ROOTFS_PATH /bin/bash -c "rm /etc/apt/sources.list"
    #sudo chroot $ROOTFS_PATH /bin/bash -c "rm /etc/apt/preferences"
    #sudo chroot $ROOTFS_PATH /bin/bash -c "rm /etc/apt/apt.conf.d/99myown"

    sudo chroot $ROOTFS_PATH /bin/bash -c "rm /var/lib/dbus/machine-id"
    sudo chroot $ROOTFS_PATH /bin/bash -c "rm /sbin/initctl"
    sudo chroot $ROOTFS_PATH /bin/bash -c "dpkg-divert --rename --remove /sbin/initctl"
    #sudo chroot $ROOTFS_PATH /bin/bash -c "apt-get -y --force-yes clean"
    sudo chroot $ROOTFS_PATH /bin/bash -c "rm -rf /tmp/*"
    echo "nameserver 8.8.8.8">/tmp/resolv.conf
    sudo cp /tmp/resolv.conf $ROOTFS_PATH/etc/resolv.conf
    #sudo chroot $ROOTFS_PATH /bin/bash -c "rm /etc/resolv.conf"
    sudo chroot $ROOTFS_PATH /bin/bash -c "umount -lf /proc"
    sudo chroot $ROOTFS_PATH /bin/bash -c "umount -lf /sys"
    sudo chroot $ROOTFS_PATH /bin/bash -c "umount -lf /dev/pts"
    sudo chroot $ROOTFS_PATH /bin/bash -c "exit"
    sudo umount -l $ROOTFS_PATH/dev
}

function intkernel()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ ! "$KERNEL_VERSION" ] ; then
        echo "ERROR: No KERNEL_VERSION set."
        return 1
    fi
    sudo cp $T/kernel/$KERNEL_VERSION/linux-headers-${KERNEL_VERSION_FULL}*.deb $ROOTFS_PATH/
    sudo cp $T/kernel/$KERNEL_VERSION/linux-image-${KERNEL_VERSION_FULL}*.deb $ROOTFS_PATH/

    sudo chroot $ROOTFS_PATH /bin/bash -c "dpkg -i -E linux-image-${KERNEL_VERSION_FULL}*.deb linux-headers-${KERNEL_VERSION_FULL}*.deb"
    sudo chroot $ROOTFS_PATH /bin/bash -c "ln -s /usr/src/linux-headers-${KERNEL_VERSION_FULL} /lib/modules/${KERNEL_VERSION_FULL}/build"
    sudo chroot $ROOTFS_PATH /bin/bash -c "rm -rf /lib/modules/${KERNEL_VERSION_FULL}/kernel && rm -rf /lib/modules/${KERNEL_VERSION_FULL}/modules.dep"
    sudo chroot $ROOTFS_PATH /bin/bash -c "dpkg -i linux-image-${KERNEL_VERSION_FULL}*.deb linux-headers-${KERNEL_VERSION_FULL}*.deb"
    sudo chroot $ROOTFS_PATH /bin/bash -c "dpkg --purge linux-generic linux-headers-generic linux-image-generic linux-headers-3.8.0-19-generic linux-headers-3.8.0-19 linux-image-extra-3.8.0-19-generic linux-image-3.8.0-19-generic"
    sudo chroot $ROOTFS_PATH /bin/bash -c "rm -rf /home/*"
    sudo chroot $ROOTFS_PATH /bin/bash -c "update-initramfs -u"

    sudo rm $ROOTFS_PATH/linux-headers-${KERNEL_VERSION_FULL}*.deb
    sudo rm $ROOTFS_PATH/linux-image-${KERNEL_VERSION_FULL}*.deb

    echo "replace kernel successfull !"
}

function createfs()
{
    step=0

    warning $CUR_SCRIPT. step $step. checktools
    checktools || return 1

    ((step++))
    while true
    do
        warning $CUR_SCRIPT. step $step. mroot
        read -p "Go On[Y/n]?" yn
        if [ -z ${yn} ]; then
            continue
        fi
        if [ "${yn}" == "y" ]; then
            if [ -d $ROOTFS_PATH ]; then
                warning dir $ROOTFS_PATH has exist. May be debootstrap has executed.
            else
    	          mroot || return 2
            fi
            break
        elif [ "${yn}" == "n" ]; then
            notice ignore mroot.
            break
        fi
    done

    ((step++))
    while true
    do
        warning $CUR_SCRIPT. step $step. mrootbuilder
        read -p "Go On[Y/n]?" yn
        if [ -z ${yn} ]; then
            continue
        fi
        if [ "${yn}" == "y" ]; then
            mrootbuilder
            break
        elif [ "${yn}" == "n" ]; then
            notice ignore mrootbuilder.
            break
        fi
    done
    #mountdir
    #intkernel

    ((step++))
    while true
    do
        warning $CUR_SCRIPT. step $step. cpkernel
        read -p "Go On[Y/n]?" yn
        if [ -z ${yn} ]; then
            continue
        fi
        if [ "${yn}" == "y" ]; then
            cpkernel
            break
        elif [ "${yn}" == "n" ]; then
            notice ignore cpkernel.
            break
        fi
    done
    #
}
function cpkernel()
{
    if [ ! -d $LIVECD_PATH/casper ] ; then
        mkdir -p $LIVECD_PATH/casper
    fi
    sudo chroot $ROOTFS_PATH /bin/bash -c "update-initramfs -u"
    KERNEL_VERSION_FULL=3.13.0-37-generic
    sudo cp $ROOTFS_PATH/boot/vmlinuz-${KERNEL_VERSION_FULL} $LIVECD_PATH/casper/vmlinuz || return 1
    sudo cp $ROOTFS_PATH/boot/initrd.img-${KERNEL_VERSION_FULL} $LIVECD_PATH/casper/initrd.lz || return 1
}
createfs
