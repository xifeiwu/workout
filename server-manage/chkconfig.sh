#!/bin/sh
SERVICES2CLOSE=(cups vncserver rpcbind)
SERVICES2OPEN=(httpd vsftpd)
for service in ${SERVICES2CLOSE[@]}; do
    chkconfig ${service} off
    if [ $? -eq 0]; then
        echo "service ${service} off"
    fi
do
for service in ${SERVICES2OPEN[@]}; do
    chkconfig ${service} on
    if [ $? -eq 0]; then
        echo "service ${service} on"
    fi
do
