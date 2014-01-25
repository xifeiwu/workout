#!/bin/sh
SERVICES2CLOSE=(cups vncserver rpcbind)
SERVICES2OPEN=(httpd vsftpd auditd)
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
yum -y install setools
yum -y install setroubleshoot*
chcon -R -u system_u -t httpd_sys_content_t /home/cos/website/
setsebool -P httpd_read_user_content 1

#chcon -R -t ftpd_sys_content_t /home/cos/ftp-15
setsebool -P ftpd_use_passive_mode 1
setsebool -P allow_ftpd_full_access 1
setsebool -P ftp_home_dir 1
