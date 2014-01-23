#!/bin/bash
BASEDIR="/home/xifei/Public"

function notice()
{
    echo -e "\033[2;32m$@\033[0m"
}
function warning()
{
    echo -e "\033[2;33m$@\033[0m"
}
function error()
{
    echo -e "\033[2;31m$@\033[0m"
    exit 1
}
function echo_read()
{
    echo -ne "${1} "
    read ${2}
}
function notice_read()
{
    echo -ne "\033[2;32m${1} \033[0m"
    read ${2}
}
function warning_read()
{
    echo -ne "\033[2;33m${1} \033[0m"
    read ${2}
}
