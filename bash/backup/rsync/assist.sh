#!/bin/bash
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

function notice_read()
{
    echo -ne "\033[2;32m-${1}\033[0m"
    read ${2}
}
function warning_read()
{
    echo -ne "\033[2;33m-${1}\033[0m"
    read ${2}
}
function echo_read()
{
    echo -ne "-${1}"
    read ${2}
}

function dpkg_install()
{
    if [ "$#" -eq 0 ]; then
        warning "dpkg install error, no package specified."
    fi
    for pkg in $@ ; do
        pkgname=`dpkg -f ${pkg} Package`
        dpkg -s ${pkgname} > /dev/null 2>&1
        if [ "$?" -eq 0 ]; then
            notice "${pkgname} has install."
        else
            notice "installing package ${pkgname}..."
            dpkg -i -E ${pkg}
        fi
    done
}
function apt_get_install()
{
    if [ "$#" -eq 0 ]; then
        warning "apt-get install error, no package specified."
    fi
    for pkgname in $@ ; do
        dpkg -s ${pkgname} > /dev/null 2>&1
        if [ "$?" -eq 0 ]; then
            notice "${pkgname} has install."
        else
            notice "installing package ${pkgname}..."
            apt-get install --yes --force-yes ${pkgname}
        fi
    done
}
