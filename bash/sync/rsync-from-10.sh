#!/bin/sh
REMOTE="cos@192.168.160.10"
LOGFILE=

function relog()
{
    LOGFILE=`pwd`/$1
    echo "Content of $1:" > ${LOGFILE}
}
function log()
{
    $@ >> ${LOGFILE}
}
function echo_tee()
{
    echo -e "$@" | tee -a ${LOGFILE}
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
function notice_read()
{
    echo -ne "-${1}" | tee -a ${LOGFILE}
    read ${2}
}

REMOTEDIR="cos@192.168.160.10:/home/cos/"
LOCALDIR="/home/cos/"

DIRLIST=(website/ ftp/ git/)
length=${#DIRLIST[@]}
cnt=0
for dir in ${DIRLIST[@]}; do
    echo ${cnt}. ${dir}
    ((cnt++))
done
notice_read "Choose the directory you want to sync:" pos
pos=(${pos})
for loc in ${pos[@]}; do
    if [ ${loc} -ge 0 -a ${loc} -lt ${length} ]; then
        DIR=(${DIR[@]} ${DIRLIST[${loc}]})
    else
       warning  "wrong position: ${loc}"
    fi
done
notice_read "Your selection: ${DIR[*]}, go on[Y/n]?" yn
while [ "${yn}" != "y" -a  "${yn}" != "Y" -a "${yn}" != "n" -a "${yn}" != "N" ]
do
    notice_read "Your selection: ${DIR[*]}, go on[Y/n]?" yn
done
if [ "${yn}" == "N" -o "${yn}" == "n" ] ; then
    error "exit as you expected."
fi

for dir in ${DIR[@]}; do
    FROM="${REMOTEDIR}${dir}"
    TO="${LOCALDIR}${dir}"
    if [ ! -d ${TO} ]; then
        notice "make dir ${TO}."
        mkdir -p ${TO}
    fi
    notice "rsync from ${FROM} to ${TO} ..."
    relog rsync-of-${dir%/}.log
    case ${dir} in
    "website/") 
        ssh ${REMOTE} 'cd /home/cos/website/wiki; mysqldump -u root --password=mysql172 my_wiki > my_wiki.sql'
        if [ $? -ne 0 ]; then
            error "error: backup of my_wiki database fail."
        fi
        log rsync -av --delete --delete-after --progress $FROM $TO
        if [ $? -eq 0 ]; then
            notice "Rsync of ${dir} success."
        else
            error "Rsync of ${dir} fail."
        fi
        if [ -f "/home/cos/website/wiki/my_wiki.sql" ]; then
            mysql -u root --password=mysql172 my_wiki < /home/cos/website/wiki/my_wiki.sql
        else
            error "file /home/cos/website/wiki/my_wiki.sql not found."
        fi
        ;;
    *)
        log rsync -av --delete --delete-after --progress $FROM $TO
        if [ $? -eq 0 ]; then
           notice "Rsync of ${dir} success."
        else
           warning "Rsync of ${dir} fail."
        fi
        ;;
    esac
done
