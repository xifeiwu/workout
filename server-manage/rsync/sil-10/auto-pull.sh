#!/bin/sh
LOGFILE="/home/cos/backup/auto-pull.log"
echo "Log of auto-pull:" > ${LOGFILE}
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
BASEDIR=~/git
if [ ! -d ${BASEDIR} ]; then
    error can not find dir ${BASEDIR}
fi
cd ${BASEDIR}
REPOS=(`ls`)
GITSERVER="git@192.168.160.14:"
for repo in ${REPOS[@]}; do
    if [ ! -d ${BASEDIR}/${repo} ]; then
        notice ${BASEDIR}/${repo} is not a directory.
        continue
    fi
    cd ${BASEDIR}/${repo}
    notice "git pull from ${GITSERVER}${repo}.git"
    ssh-agent bash -c 'ssh-add /home/cos/backup/sil-10/id_rsa; git pull origin master'
    if [ $? -eq 0 ]; then
        notice "Git pull success."
    else
        warning "Git pull fail."
    fi
done
