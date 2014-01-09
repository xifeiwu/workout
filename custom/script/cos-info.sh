#!/bin/sh
set -e

if [ $# -lt 2 ] ; then
    echo You should execute this script with three param at least as follow:
    echo sh $0 MATERIALDIR WORKDIR
    exit -1
fi
MATERIALDIR=$1
WORKDIR=$2

echo -e "\033[31m - custom cos desktop info. \033[0m"
cp -r ${MATERIALDIR}/mymint/. ${WORKDIR}/mymint/
