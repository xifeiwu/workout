#!/bin/sh
LOGFILE="`pwd`/auto-clone.log"
echo "Log of auto-clone:" > ${LOGFILE}
function log()
{
    $@ >> ${LOGFILE}
}
function notice()
{
    echo -e "\033[2;32m-$@\033[0m" | tee -a ${LOGFILE}
}
function warning()
{
    echo -e "\033[2;33m-$@\033[0m" | tee -a ${LOGFILE}
}
function error()
{
    echo -e "\033[2;31m-$@\033[0m" | tee -a ${LOGFILE}
    exit 1
}
if [ ! -d ~/git ]; then
    error can not find dir ~/git
fi
cd ~/git
GITSERVER="git@192.168.160.14:"
REPOS=(cbooks cbackup cstudy)
for repo in ${REPOS[@]}; do
    notice "git clone from ${GITSERVER}${repo}.git"
    ssh-agent bash -c 'ssh-add /home/cos/backup/id_rsa; git clone ${GITSERVER}${repo}.git'
    if [ $? -eq 0 ]; then
        notice "Git clone success."
    else
        warning "Git clone fail."
    fi
done
