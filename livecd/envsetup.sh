function setenv()
{
    . config.sh
}
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
    sudo cp $T/kernel/$KERNEL_VERSION/linux-headers-${KERNEL_VERSION_FULL}*.deb $OUT/out/squashfs-root/
    sudo cp $T/kernel/$KERNEL_VERSION/linux-image-${KERNEL_VERSION_FULL}*.deb $OUT/out/squashfs-root/

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg -i -E linux-image-${KERNEL_VERSION_FULL}*.deb linux-headers-${KERNEL_VERSION_FULL}*.deb"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "ln -s /usr/src/linux-headers-${KERNEL_VERSION_FULL} /lib/modules/${KERNEL_VERSION_FULL}/build"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf /lib/modules/${KERNEL_VERSION_FULL}/kernel && rm -rf /lib/modules/${KERNEL_VERSION_FULL}/modules.dep"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg -i linux-image-${KERNEL_VERSION_FULL}*.deb linux-headers-${KERNEL_VERSION_FULL}*.deb"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge linux-generic linux-headers-generic linux-image-generic linux-headers-3.8.0-19-generic linux-headers-3.8.0-19 linux-image-extra-3.8.0-19-generic linux-image-3.8.0-19-generic"
   sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf /home/*"
   sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -u"

   sudo rm $OUT/out/squashfs-root/linux-headers-${KERNEL_VERSION_FULL}*.deb
   sudo rm $OUT/out/squashfs-root/linux-image-${KERNEL_VERSION_FULL}*.deb

   echo "replace kernel successfull !"
}
#mountdir first.!!!
#ln -s /usr/src/linux-headers-3.13.0-24-generic/ /lib/modules/3.13.0-24-generic/buil

function mountdir()
{
    if [ -e ${ROOTFS_PATH}/proc/mounts ] ; then
        sudo umount ${ROOTFS_PATH}/sys
        sudo umount ${ROOTFS_PATH}/dev/pts
        sudo umount ${ROOTFS_PATH}/dev
        sudo umount ${ROOTFS_PATH}/proc
    fi
    sudo mount -t devtmpf -o bind /dev ${ROOTFS_PATH}/dev || return 1
    sudo mount -t proc proc ${ROOTFS_PATH}/proc || return 1
    sudo mount none -t devpts ${ROOTFS_PATH}/dev/pts || return 1
    sudo mount none -t sysfs ${ROOTFS_PATH}/sys || return 1
}
function unmountdir()
{
    if [ -e ${ROOTFS_PATH}/proc/mounts ] ; then
        sudo umount ${ROOTFS_PATH}/sys
        sudo umount ${ROOTFS_PATH}/dev/pts
        sudo umount ${ROOTFS_PATH}/dev
        sudo umount ${ROOTFS_PATH}/proc
    fi
}
function createfs()
{
    checktools || return 1
    if [ -d $ROOTFS_PATH ]; then
        echo dir $ROOTFS_PATH has exist. May be debootstrap has executed.
    else
    	mroot || return 1
    fi
    #mrootbuild
    #mountdir
    #intkernel
    #cpkernel
    sudo sh isolinux/create_livecd.sh $SCRIPT_TOP_PATH
}
function cpkernel()
{
    if [ ! -d $LIVECD_PATH/casper ] ; then
        mkdir -p $LIVECD_PATH/casper
    fi
    KERNEL_VERSION_FULL=3.13.0-24-generic
    sudo cp $ROOTFS_PATH/boot/vmlinuz-${KERNEL_VERSION_FULL} $LIVECD_PATH/casper/vmlinuz || return 1
    sudo cp $ROOTFS_PATH/boot/initrd.img-${KERNEL_VERSION_FULL} $LIVECD_PATH/casper/initrd.lz || return 1
}
setenv
