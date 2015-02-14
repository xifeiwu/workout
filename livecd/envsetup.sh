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
    echo sudo debootstrap --arch=${OSARCH} --no-check-gpg ${BASE_RELEASE} $ROOTFS ${BASE_REPO_ONLINE} || return 1
    sudo debootstrap --arch=${OSARCH} --no-check-gpg ${BASE_RELEASE} $ROOTFS || return 1
    echo End debootstraping...
}
function mountdir()
{
    if [ -e ${ROOTFS}/proc/mounts ] ; then
        sudo umount ${ROOTFS}/sys
        sudo umount ${ROOTFS}/dev/pts
        sudo umount ${ROOTFS}/dev
        sudo umount ${ROOTFS}/proc
    fi
    sudo mount -t devtmpf -o bind /dev ${ROOTFS}/dev || return 1
    sudo mount -t proc proc ${ROOTFS}/proc || return 1
    sudo mount none -t devpts ${ROOTFS}/dev/pts || return 1
    sudo mount none -t sysfs ${ROOTFS}/sys || return 1
}
function createfs()
{
    checktools || return 1
    if [ -d $ROOTFS ]; then
        echo dir $ROOTFS has exist. May be debootstrap has executed.
    else
    	mroot || return 1
    fi
    . isolinux/create_livecd.sh
}
setenv
