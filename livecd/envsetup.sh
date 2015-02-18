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
#ln -s /usr/src/linux-headers-3.13.0-24-generic/ /lib/modules/3.13.0-24-generic/build

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
function mountsquashfs()
{
    sudo mount --bind /dev $ROOTFS_PATH/dev
    sudo chroot $ROOTFS_PATH /bin/bash -c "mount none -t proc /proc"
    sudo chroot $ROOTFS_PATH /bin/bash -c "mount none -t sysfs /sys"
    sudo chroot $ROOTFS_PATH /bin/bash -c "mount none -t devpts /dev/pts"
}
function unmountsquashfs()
{
    sudo umount -l $ROOTFS_PATH/dev
    sudo chroot $ROOTFS_PATH /bin/bash -c "umount -lf /proc"
    sudo chroot $ROOTFS_PATH /bin/bash -c "umount -lf /sys"
    sudo chroot $ROOTFS_PATH /bin/bash -c "umount -lf /dev/pts"
}
function start()
{
    while true
    do
        warning sudo sh squashfs/create_fs.sh $SCRIPT_TOP_PATH
        read -p "Go On[Y/n]?" yn
        if [ -z ${yn} ]; then
            continue
        fi
        if [ "${yn}" == "y" ]; then
            sudo sh squashfs/create_fs.sh $SCRIPT_TOP_PATH
            if [ ! $?  -eq 0 ]; then
                error stop at squashfs/create_fs.sh
                return 1
            fi
            break
        elif [ "${yn}" == "n" ]; then
            notice ignore squashfs/create_fs.sh
            break
        fi
    done

    while true
    do
        warning sudo sh isolinux/create_livecd.sh $SCRIPT_TOP_PATH
        read -p "Go On[Y/n]?" yn
        if [ -z ${yn} ]; then
            continue
        fi
        if [ "${yn}" == "y" ]; then
            sudo sh isolinux/create_livecd.sh $SCRIPT_TOP_PATH
            if [ ! $?  -eq 0 ]; then
                error stop at isolinux/create_livecd.sh
            return 1
            fi
            break
        elif [ "${yn}" == "n" ]; then
            notice ignore isolinux/create_livecd.sh
            break
        fi
    done

    while true
    do
        warning sudo sh mkiso.sh $SCRIPT_TOP_PATH
        read -p "Go On[Y/n]?" yn
        if [ -z ${yn} ]; then
            continue
        fi
        if [ "${yn}" == "y" ]; then
            sudo sh mkiso.sh $SCRIPT_TOP_PATH
            if [ ! $?  -eq 0 ]; then
                error stop at mkiso.sh
                return 1
            fi
            break
        elif [ "${yn}" == "n" ]; then
            notice ignore mkiso.sh.
            break
        fi
    done
}
setenv
