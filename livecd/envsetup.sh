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
function start()
{
    sudo sh squashfs/create_fs.sh $SCRIPT_TOP_PATH
    #sudo sh isolinux/create_livecd.sh $SCRIPT_TOP_PATH
}
setenv
