配置环境（仅在ubuntu 12.04 13.04下测试，其他ubuntu版本自行测试）

安装JDK 6.0
$ sudo add-apt-repository "deb http://archive.canonical.com/ lucid partner"
$ sudo apt-get update
$ sudo apt-get install sun-java6-jdk
$ sudo updates-alternative --config /usr/bin/java java path/to/jdk/bin/java 300
$ sudo update-alternative --install java

注：Android编译过程中如果出现java相关错误，如，“某些输入文件使用或覆盖了已过时的API”。可能是因为jdk版本太高，经测试Android4.3使用jdk1.6.0_45会出问题，但是使用jdk1.6.0_37没有问题。

安装必要的组件包（系统版本要求：Ubuntu 12.04或者更新）
$ sudo apt-get install git gnupg flex bison gperf build-essential \
  zip curl libc6-dev libncurses5-dev:i386 x11proto-core-dev \
  libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
  libgl1-mesa-dev g++-multilib mingw32 tofrodos \
  python-markdown libxml2-utils xsltproc zlib1g-dev:i386 \
  libswitch-perl
$ sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so

安装repo 工具
$ mkdir ~/bin
$ PATH=~/bin:$PATH

$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo

源码下载
mkdir WORKING_DIRECTORY
cd WORKING_DIRECTORY
repo init -u https://android.googlesource.com/platform/manifest -b android-4.3.1_r1
repo sync -j8

下载vendor
https://developers.google.com/android/nexus/drivers#makojwr66y

或者在 /vendor 目录中，解压执行脚本

