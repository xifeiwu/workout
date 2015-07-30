#!/bin/bash
if [ $# -lt 1 ]; then
    echo The directory of Android Project is Needed.
    return
fi
if [ -d $1 ]; then
    export ANDROID=$(cd $1; pwd)
else
    echo $1 Is Not a Directory.
    return
fi

PATCH15=$(cd ${ANDROID}/../Patches-1.5; pwd)
PATCH20=$(cd ${ANDROID}/../Patches-2.0; pwd)
KERNEL=$(cd ${ANDROID}/../android-msm-mako-3.4-jb-mr2; pwd)
echo android dir: $ANDROID
echo Patches-1.5: $PATCH15
echo Patches-2.0: $PATCH20
echo KERNEL_PATH: $KERNEL

function run_patch(){
    #set +e
    patch --dry-run -N $*
    ERROR=$?
    #set -e
    if [ $ERROR -eq 0 ] ; then
        patch -N $*
    else
        patch -R -N $*
        patch -N $*
    fi
}

function patch_android15()
{

    run_patch -p0 -d ${ANDROID}/packages -i ${PATCH15}/PATCH/0001-apps.patch
    # account an error when use p0 and ${ANDROID}
    run_patch -p1 -d ${ANDROID}/dalvik -i ${PATCH15}/PATCH/0002-dalvik.patch
    run_patch -p0 ${ANDROID}/build/target/productcore.mk -i ${PATCH15}/PATCH/0003-product-core.patch
    run_patch -p0 -d ${ANDROID}/frameworks -i ${PATCH15}/PATCH/0004-framework_base.patch
    #pushd frameworks/base
    #git am ${PATCH15}/BatteryStatsImpl.java.patch
    #popd
}

function patch_android20_kernel()
{
    if [ ! -d ${PATCH20}/patch_for_Jan ]; then
        echo ${PATCH20}/patch_for_Jan does not exist.
        return 0
    fi
    if [ ! -d ${PATCH20}/patch_for_Jan-0day ]; then
        echo ${PATCH20}/patch_for_Jan-0day does not exist.
        return 1
    fi
    if [ ! -d ${PATCH20}/patch_for_Feb ]; then
        echo ${PATCH20}/patch_for_Feb does not exist.
        return 2
    fi
    for file in `find ${PATCH20}/patch_for_Jan -type f`
    do
        run_patch -p1 -d ${KERNEL} -i $file
    done
    for file in `find ${PATCH20}/patch_for_Jan-0day -type f`
    do
        run_patch -p1 -d ${KERNEL} -i $file
    done
    for file in `find ${PATCH20}/patch_for_Feb -type f`
    do
        run_patch -p1 -d ${KERNEL} -i $file
    done
}

function patch_android20_android()
{
    if [ ! -f ${PATCH20}/华夏创新/0005-android.patch ]; then
        echo ${PATCH20}/华夏创新/0005-android.patc does not exist.
        return 0
    fi
    run_patch -p1 -d ${ANDROID} -i ${PATCH20}/华夏创新/0005-android.patch
}

function build_android()
{
    if [ ! -d ${ANDROID}/device/lge/mako-kernel ]; then
        echo ${ANDROID}/device/lge/mako-kernel does not exist.
        return 0
    fi

    if [ ! -f ${KERNEL}/arch/arm/boot/zImage ]; then
        echo ${KERNEL}/arch/arm/boot/zImage does not exist.
        return 1
    else
        cp ${KERNEL}/arch/arm/boot/zImage ${ANDROID}/device/lge/mako-kernel/kernel
    fi

    if [ ! -d ${ANDROID}/out/target/product/mako ]; then
        echo ${ANDROID}/out/target/product/mako does not exist.
    else
        rm ${ANDROID}/out/target/product/mako/boot.img
    fi

    source build/envsetup.sh && lunch full_mako-userdebug
    make otapackage -j8 | tee make_otapackage.log
}

function build_kernel()
{
    if [ ! -d $KERNEL ]; then
        echo $KERNEL is not a directory.
    fi
    pushd $KERNEL
    export ARCH=arm
    export SUBARCH=arm
    export PATH=$PATH:${ANDROID}/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7/bin/
    export CROSS_COMPILE=arm-eabi-
    make mako_defconfig
    make -j8 | tee make.log
    #arch/arm/boot/zImage
    popd
}

function makebootimg()
{
    #export PATH=$PATH:${ANDROID}/out/host/linux-x86/bin/
    #mkbootimg --cmdline 'no_console_suspend=1 console=null' --kernel zImage --ramdisk ramdisk.img -o boot.img --base 02e00000
    #mkbootimg --cmdline 'androidboot.hardware=blade console=null g_android.product_id=0x1354 g_android.serial_number=Blade-CM7'  --kernel boot.img-kernel --ramdisk boot.img-ramdisk.gz -o new.img
    #mkbootimg --kernel zImage --cmdline 'console=ttyHSL0,115200,n8 androidboot.hardware=mako lpj=67677 --base 0x80200000 --pagesize 2048 --ramdisk_offset 0x01600000' --ramdisk ramdisk.img --output boot.img

    if [ ! -d ${ANDROID}/device/lge/mako-kernel ]; then
        echo ${ANDROID}/device/lge/mako-kernel does not exist.
        return 0
    fi

    if [ ! -f ${KERNEL}/arch/arm/boot/zImage ]; then
        echo ${KERNEL}/arch/arm/boot/zImage does not exist.
        return 1
    else
        cp ${KERNEL}/arch/arm/boot/zImage ${ANDROID}/device/lge/mako-kernel/kernel
    fi

    if [ ! -d ${ANDROID}/out/target/product/mako ]; then
        echo ${ANDROID}/out/target/product/mako does not exist.
    else
        rm ${ANDROID}/out/target/product/makoboot.img
    fi

    make bootimage
}
function abootimg_()
{
    command -v abootimg > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: abootimg has not been installed.
        echo sudo apt-get install abootimg
        sudo apt-get install abootimg
    fi
    abootimg -x boot.img
    sed -i '/bootsize =/d' bootimg.cfg
    abootimg --create newboot.img -f bootimg.cfg -k zImage -r initrd.img
}
function fastboot_img()
{
    adb reboot bootloader
    sleep 10
    fastboot -w
    fastboot flash boot boot.img
    fastboot flash system system.img
    fastboot flash userdata userdata.img
    fastboot reboot
}
