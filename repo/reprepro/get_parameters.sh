#!/bin/sh
#find keyring and basedir in configure file in conf
COMPONENTS="main"
ARCHITECTURE="i386|source"
IGNORE="--ignore=surprisingarch --ignore=unusedarch --ignore=wrongdistribution"
function notice()
{
    echo -e "\033[2;32m-$@\033[0m"
}
function warning()
{
    echo -e "\033[2;33m-$@\033[0m"
}
function error()
{
    echo -e "\033[2;31m-$@\033[0m"
    exit 1
}
CODENAME=
KEYRING=
BASEDIR=

tmp=`cat ./conf/distributions | sed -n 3p | awk '{print $1}'`
if [ ${tmp} == "Codename:" ] ; then
    CODENAME=`cat ./conf/distributions | sed -n 3p | awk '{print $2}'`
else
    error "properity codename not find in ./conf/distributions"
fi
tmp=`cat ./conf/distributions | sed -n 7p | awk '{print $1}'`
if [ ${tmp} == "SignWith:" ] ; then
    KEYRING=`cat ./conf/distributions | sed -n 7p | awk '{print $2}'`
else
    error "properity SignWith not find in ./conf/distributions"
fi

tmp=`cat ./conf/options | sed -n 3p | awk '{print $1}'`
if [ ${tmp} == "basedir" ] ; then
    BASEDIR=`cat ./conf/options | sed -n 3p | awk '{print $2}'`
else
    error "properity basedir not find in ./conf/options"
fi
if [ ! -d ${BASEDIR} ] ; then
    mkdir -p ${BASEDIR}
fi

