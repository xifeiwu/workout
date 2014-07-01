#!/bin/sh
if [ -f ./assist.sh ]; then
    source ./assist.sh
else
    echo "File assist.sh is not found in current directory."
fi

TOREMOTE=""
REMOTE=""
REMOTEDIR=""
LOCALDIR=""
while [ $# -gt 0 ]
do
    case $1 in
    "--help"|"-H")
        echo "Usage: rsync directories from one host to another"
        echo ""
        echo "Arguments:"
        echo "  --from[-F|-f]           rsync from remote"
        echo "  --to[-T|-t]             rsync to remote"
        echo "  --remote[-R]            set remote: user@ip"
        echo "  --remote-dir[-RD]       specify the path to rsync"
        echo "  --local-dir[-LD]        specify the path to rsync"
        exit 0
        ;;
    "--from"|"-F"|"-f")
        TOREMOTE=false
        shift
        ;;
    "--to"|"-T"|"-t")
        TOREMOTE=true
        shift
        ;;
    "--remote"|"-R")
        shift
        REMOTE="$1"
        shift
        ;;
    "--remote-dir"|"-RD")
        shift
        REMOTEDIR="$1"
        shift
        ;;
    "--local-dir"|"-LD")
        shift
        LOCALDIR="$1"
        shift
        ;;
    *)
        error "Wrong parameter..."
        ;;
    esac
done

if [ -z "${TOREMOTE}" -o -z "${REMOTE}" -o -z "${REMOTEDIR}" ]; then
    error "rsync from or to remote, remote ip and dir must be set.\n-Use -H for more info."
fi
if [ ! -d "${LOCALDIR}" ]; then
    error "LOCAL DIR: ${LOCALDIR} does not exist."
fi

warning "TOREMOTE\t:${TOREMOTE}"
warning "REMOTE\t\t:${REMOTE}"
warning "REMOTE-DIR\t:${REMOTEDIR}"
warning "LOCAL-DIR\t:${LOCALDIR}"
if ${TOREMOTE} ; then
    warning "Script will rsync from local:${LOCALDIR} to ${REMOTE}:${REMOTEDIR}"
else
    warning "Script will rsync from ${REMOTE}:${REMOTEDIR} to local:${LOCALDIR}"
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
    dirs=`cd ${LOCALDIR}; find . -maxdepth 1 -type d`
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
            notice "rsync -av --progress --delete ${LOCALDIR}${DIRS[$i]}/ ${REMOTE}:${REMOTEDIR}${DIRS[$i]}/"
            rsync -av --progress --delete ${LOCALDIR}${DIRS[$i]}/ ${REMOTE}:${REMOTEDIR}${DIRS[$i]}/
            if [ $? -ne 0 ]; then
                error "Error during: Rsync from ${LOCALDIR}${DIRS[$i]}/ to ${REMOTE}:${REMOTEDIR}${DIRS[$i]}/"
            fi
        done
    else
        error "Exit as you expected."
    fi
    notice "Rsync directories ${DIRS[@]} success."
else
    dirs=`ssh ${REMOTE} "cd ${REMOTEDIR}; find . -maxdepth 1 -type d"`
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
            notice "rsync -av --progress --delete ${REMOTE}:${REMOTEDIR}${DIRS[$i]}/ ${LOCALDIR}${DIRS[$i]}/"
            rsync -av --progress --delete ${REMOTE}:${REMOTEDIR}${DIRS[$i]}/ ${LOCALDIR}${DIRS[$i]}/
            if [ $? -ne 0 ]; then
                error "Error during: Rsync from ${REMOTE}:${REMOTEDIR}${DIRS[$i]}/ to ${LOCALDIR}${DIRS[$i]}/"
            fi
        done
    else
        error "Exit as you expected."
    fi
    notice "Rsync directories ${DIRS[@]} success."
fi
