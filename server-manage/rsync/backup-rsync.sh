#!/bin/sh
if [ -f ./assist.sh ]; then
    source ./assist.sh
else
    echo "File assist.sh is not found in current directory."
fi

REMOTE=""
TOREMOTE=""
DIRPATH=""
while [ $# -gt 0 ]
do
    case $1 in
    "--help"|"-H")
        echo "Usage: rsync directories from one host to another"
        echo ""
        echo "Arguments:"
        echo "  --remote[-R]        set remote: user@ip"
        echo "  --path[-P]          specify the path to rsync"
        echo "  --to[-t]            rsync to remote"
        echo "  --from[-f]          rsync from remote"
        exit 0
        ;;
    "-R"|"--remote")
        shift
        REMOTE="$1"
        shift
    ;;
    "--to"|"-T")
        TOREMOTE=true
        shift
        ;;
    "--from"|"-F")
        TOREMOTE=false
        shift
        ;;
    "--path"|"-P")
        shift
        DIRPATH="$1"
        shift
        ;;
    *)
        error "Wrong parameter..."
        ;;
    esac
done

if [ -z "${REMOTE}" -o -z "${TOREMOTE}" -o -z "${DIRPATH}" ]; then
    error "remote,[-T|-F], path must be set.\n-Use -H for more info."
fi
if [ ! -d "${DIRPATH}" ]; then
    error "DIRPATH: ${DIRPATH} does not exist."
fi

warning "REMOTE\t\t:${REMOTE}"
warning "TOREMOTE\t:${TOREMOTE}"
warning "DIRPATH\t:${DIRPATH}"
if ${TOREMOTE} ; then
    warning "Script will rsync from ${DIRPATH} to ${REMOTE}:${DIRPATH}"
else
    warning "Script will rsync from ${REMOTE}:${DIRPATH} to ${DIRPATH}"
fi

notice_read "Are the following Parameters Correct[Y/n]? " yn
while [ "${yn}" != "y" -a  "${yn}" != "Y" -a "${yn}" != "n" -a "${yn}" != "N" ]
do
    notice_read "Are the following Parameters Correct[Y/n]? " yn
done
if [ "${yn}" == "N" -o "${yn}" == "n" ] ; then
    error "Exit as you expected."
fi

declare -a DIRS
dircnts=0

function select_dir()
{
    local dirs
    local tmp input
    dirs=(`echo "$1" | sed "s:^\./\..*::g" | sed "s:\.::g"`)
    dircnts=${#dirs[@]}
    for ((i=0;i<${dircnts};i++))
    do
        notice "(${i})${dirs[$i]}"
    done
    if [ ${dircnts} -eq 0 ]; then
        error "Not directories are found."
    else
        warning_read "Select the directories To Rsync [a | 0 1 2 3 ...]:" input
        if [ "$input" == "a" ]; then
            DIRS=(${dirs[@]})
        else
            for tmp in ${input}
            do
                if [ ${tmp} -ge 0 -a ${tmp} -lt ${dircnts} ]; then
                    DIRS=(${DIRS[@]} ${dirs[$tmp]})
                fi
            done
        fi
        dircnts=${#DIRS[@]}
    fi
}

if ${TOREMOTE} ; then
    dirs=`cd ${DIRPATH}; find . -maxdepth 1 -type d`
    select_dir "${dirs}"
    for ((i=0;i<${dircnts};i++))
    do
        echo ${DIRS[$i]}
    done
    warning_read "The directories above will rsync[Y/n]? " yn
    while [ "${yn}" != "y" -a  "${yn}" != "Y" -a "${yn}" != "n" -a "${yn}" != "N" ]
    do
        notice_read "The directories above will rsync[Y/n]? " yn 
    done
    if [ "${yn}" == "Y" -o "${yn}" == "y" ] ; then
        for ((i=0;i<${dircnts};i++))
        do
            notice "rsync -av --progress --delete ${DIRPATH}/${DIRS[$i]}/ ${REMOTE}:${DIRPATH}/${DIRS[$i]}/"
            rsync -av --progress --delete ${DIRPATH}/${DIRS[$i]}/ ${REMOTE}:${DIRPATH}/${DIRS[$i]}/
            if [ $? -ne 0 ]; then
                error "Error during: Rsync from ${DIRPATH}/${DIRS[$i]}/ to ${REMOTE}:${DIRPATH}/${DIRS[$i]}/"
            fi
        done
    else
        error "Exit as you expected."
    fi
    notice "Rsync directories ${DIRS[@]} success."
else
    dirs=`ssh ${REMOTE} "cd ${DIRPATH}; find . -maxdepth 1 -type d"`
    select_dir "${dirs}"
    for ((i=0;i<${dircnts};i++))
    do
        echo ${DIRS[$i]}
    done
    warning_read "The directories above will rsync[Y/n]? " yn
    while [ "${yn}" != "y" -a  "${yn}" != "Y" -a "${yn}" != "n" -a "${yn}" != "N" ]
    do
        notice_read "The directories above will rsync[Y/n]? " yn
    done
    if [ "${yn}" == "Y" -o "${yn}" == "y" ] ; then
        for ((i=0;i<${dircnts};i++))
        do
            notice "rsync -av --progress --delete ${REMOTE}:${DIRPATH}/${DIRS[$i]}/ ${DIRPATH}/${DIRS[$i]}/"
            rsync -av --progress --delete ${REMOTE}:${DIRPATH}/${DIRS[$i]}/ ${DIRPATH}/${DIRS[$i]}/
            if [ $? -ne 0 ]; then
                error "Error during: Rsync from ${REMOTE}:${DIRPATH}/${DIRS[$i]}/ to ${DIRPATH}/${DIRS[$i]}/"
            fi
        done
    else
        error "Exit as you expected."
    fi
    notice "Rsync directories ${DIRS[@]} success."
fi
