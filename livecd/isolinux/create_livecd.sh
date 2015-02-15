#!/bin/sh
#$1: path of script top dir.
set -e

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

CUR_PATH=$(cd "$(dirname $0)"; pwd)

echo startstart shell : $SCRIPT_TOP_PATH/$0
echo CUR_PATH: $CUR_PATH
echo LIVECD_PATH: $LIVECD_PATH


if [ ! $OSVERSION ] ; then
    echo Error: no OSVERSION env set.
    exit -1
fi
if [ ! $OSVERSIONFULLNAME ] ; then
    echo Error: no OSVERSIONFULLNAME env set.
    exit -1
fi

if [ ! -d $LIVECD_PATH/casper ] ; then
    mkdir -p $LIVECD_PATH/casper
    #echo error: there is no $isodir path
    #exit -1
fi

if [ ! -z $LIVECD_PATH/isolinux ] ; then
    rm -rf $LIVECD_PATH/isolinux
fi
mkdir $LIVECD_PATH/isolinux
if [ ! -z $LIVECD_PATH/preseed ] ; then
    rm -rf $LIVECD_PATH/preseed
fi
mkdir $LIVECD_PATH/preseed
if [ ! -z $LIVECD_PATH/.disk ] ; then
    rm -rf $LIVECD_PATH/.disk
fi
mkdir $LIVECD_PATH/.disk

cp $CUR_PATH/files/isolinux/16x16.fnt $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/boot.cat $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/en.hlp $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/en.tr $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/gfxboot.c32 $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/isolinux.bin $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/memtest86+-5.01.bin $LIVECD_PATH/isolinux/memtest
cp $CUR_PATH/files/isolinux/message $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/vesamenu.c32 $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/back.jpg $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/zh_CN.hlp $LIVECD_PATH/isolinux
cp $CUR_PATH/files/isolinux/zh_CN.tr $LIVECD_PATH/isolinux

adtxtstr=""
echo "$adtxtstr" > $LIVECD_PATH/isolinux/adtxt.cfg

dtmenustr="menu hshift 9
menu width 58

menu begin desktop
    include stdmenu.cfg
    menu hshift 13
    menu width 49
    menu label Alternative desktop environments
    menu title Desktop environment menu
    label mainmenu-kde
        menu label ^Back..
        text help
        Higher level options install the GNOME desktop environment
        endtext
        menu exit
    menu begin kde-desktop
        include stdmenu.cfg
        menu label ^KDE
        menu title KDE desktop boot menu
        text help
   Select the 'K Desktop Environment' for the Desktop task
        endtext
        label mainmenu-kde
            menu label ^Back..
            menu exit
        include kde/menu.cfg
    menu end
    menu begin lxde-desktop
        include stdmenu.cfg
        menu label ^LXDE
        menu title LXDE desktop boot menu
        text help
       Select the 'Lightweight X11 Desktop Environment' for the Desktop task
        endtext
        label mainmenu-lxde
            menu label ^Back..
            menu exit
        include lxde/menu.cfg
    menu end
    menu begin xfce-desktop
        include stdmenu.cfg
        menu label ^Xfce
        menu title Xfce desktop boot menu
        text help
   Select the 'Xfce lightweight desktop environment' for the Desktop task
        endtext
        label mainmenu-xfce
            menu label ^Back..
            menu exit
        include xfce/menu.cfg
    menu end
menu end
"
echo "$dtmenustr" > $LIVECD_PATH/isolinux/dtmenu.cfg

exithelpstr="label menu
	kernel vesamenu.c32
	config isolinux.cfg
"
echo "$exithelpstr" > $LIVECD_PATH/isolinux/exithelp.cfg

gfxbootstr="foreground=0xFFFFFF
background=0x60C1F8
screen-colour=0x001C20
label normal=Normal
append normal=
label driverupdates=Use driver update disc
append driverupdates=debian-installer/driver-update=true
applies driverupdates=live live-install
label oem=OEM install (for manufacturers)
append oem=oem-config/enable=true
applies oem=live live-install install
"
echo "$gfxbootstr" > $LIVECD_PATH/isolinux/gfxboot.cfg

cfgstr="# D-I config version 2.0
include menu.cfg
default vesamenu.c32
prompt 0
timeout 50
ui gfxboot message
"
echo "$cfgstr" > $LIVECD_PATH/isolinux/isolinux.cfg

langstr="zh_CN
"
echo "$langstr" > $LIVECD_PATH/isolinux/lang

langliststr="en
zh_CN
"
echo "$langliststr" > $LIVECD_PATH/isolinux/langlist

menustr="menu hshift 13
menu width 49
menu margin 8

menu title Installer boot menu
include stdmenu.cfg
include txt.cfg
menu begin advanced
	menu title Advanced options
	include stdmenu.cfg
	label mainmenu
		menu label ^Back..
		menu exit
	include adtxt.cfg
menu end
"
echo "$menustr" > $LIVECD_PATH/isolinux/menu.cfg

po4astr="[po4a_langs] zh_CN zh_TW
[po4a_paths] po/help.pot $lang:po/$lang.po
[type:docbook] help.xml
"
echo "$po4astr" > $LIVECD_PATH/isolinux/po4a.cfg

promptstr="prompt 1
display f1.txt
timeout 50
include menu.cfg
include exithelp.cfg

f1 f1.txt
f2 f2.txt
f3 f3.txt
f4 f4.txt
f5 f5.txt
f6 f6.txt
f7 f7.txt
f8 f8.txt
f9 f9.txt
"
echo "$promptstr" >  $LIVECD_PATH/isolinux/prompt.cfg

stdmenustr="menu background splash.png
menu color title	* #FFFFFFFF *
menu color border	* #00000000 #00000000
menu color sel		* #ffffffff #76a1d0ff *
menu color hotsel	1;7;37;40 #ffffffff #76a1d0ff *
menu color tabmsg	* #ffffffff #00000000 *
menu color help		37;40 #ffdddd00 #00000000 none
menu vshift 12
menu rows 10
menu helpmsgrow 15
# The command line must be at least one line from the bottom.
menu cmdlinerow 16
menu timeoutrow 16
menu tabmsgrow 18
menu tabmsg Press ENTER to boot or TAB to edit a menu entry
"
echo "$stdmenustr" > $LIVECD_PATH/isolinux/stdmenu.cfg

txtstr="default live
label live
  menu label Try and ^Install CDOS
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/cdos.seed boot=casper initrd=/casper/initrd.lz quiet splash --
label xforcevesa
  menu label ^Install CDOS in compatibility mode
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/cdos.seed boot=casper xforcevesa nomodeset b43.blacklist=yes initrd=/casper/initrd.lz ramdisk_size=1048576 root=/dev/ram rw noapic noapci nosplash irqpoll --
label check
  menu label ^Check disc for defects
  kernel /casper/vmlinuz
  append  boot=casper integrity-check initrd=/casper/initrd.lz quiet splash --
label memtest
  menu label Test ^memory
  kernel memtest
label hd
  menu label ^Boot from first hard disk
  localboot 0x80
"
echo "$txtstr" > $LIVECD_PATH/isolinux/txt.cfg

seed="# Language and country.
d-i 	debian-installer/locale string zh_CN.UTF-8

# Keyboard 
d-i 	console-setup/ask_detect boolean false
d-i 	console-setup/layoutcode string us

# Time
d-i 	clock-setup/ntp boolean false
d-i 	time/zone string Asia/Shanghai
d-i 	clock-setup/utc boolean false

# Don't install any task.
tasksel	tasksel/first	multiselect 

# Don't install any translation packages.
d-i	pkgsel/language-pack-patterns	string

# Language support is expected to be missing.
d-i	pkgsel/install-language-support	boolean false

# Don't install language packages
d-i	pkgsel/language-packs string

# Don't show summary before install
ubiquity ubiquity/summary note
#ubiquity ubiquity/reboot boolean true"
echo "$seed" > $LIVECD_PATH/preseed/$OSNAME.seed

echo full_cd/single > $LIVECD_PATH/.disk/cd_type
echo $OSFULLNAME $OSVERSION "$OSVERSIONFULLNAME" - Release i386 \(`date +%Y%m%d`\) > $LIVECD_PATH/.disk/info
echo $OSFULLNAME $OSVERSION "$OSVERSIONFULLNAME" - Release i386 \(`date +%Y%m%d`\) > $LIVECD_PATH/.disk/mint4win
touch $LIVECD_PATH/.disk/release_notes_url
echo 423b762a-38e0-4f2d-8632-459f826c6699 > $LIVECD_PATH/.disk/casper-uuid-generic
echo 423b762a-38e0-4f2d-8632-459f826c6699 > $LIVECD_PATH/.disk/live-uuid-generic

echo success: $SCRIPT_TOP_PATH/isolinux/create_livecd.sh
