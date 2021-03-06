#!/bin/sh
if [ -f ./get_parameters.sh ]; then
    source ./get_parameters.sh
else
    echo -e "\033[2;31m-./get_parameters.sh not found.\033[0m"
    exit 1
fi

#parse parameter
while [ "$#" -gt "0" ]; do
    case $1 in
    "--help"|"-h")
        echo "Usage: sync to(from) 124.16.141.172"
        echo ""
        echo "Arguments:"
        echo "  --to[-t]        sync from localhost to 172"
        echo "  --from[-f]      sync from 172 to localhost"
        exit 0
        ;;
    "--to"|"-t")
        TOSERVER=true
        shift
        ;;
    "--from"|"-f")
        TOSERVER=false
        shift
        ;;
    *)
        error "wrong parameter..."
        ;;
    esac
done

if [ -z ${TOSERVER} ]; then
    error "--to(-t) or --from(-f) server must be specified"
fi

#select directory want to sync
ALLDIRS=(dists pool project upgrade db)
size=${#ALLDIRS[@]}
notice "All directories are listed below:"
for ((i=0; i<$size; i++)); do
    echo "$((i+1)). ${ALLDIRS[$i]}"
done
warning_read "Select directory you want to sync[a|1|2|...]: "
read sel
declare -a SELECTEDDIR
case $sel in
    "a")
        SELECTEDDIR=(${ALLDIRS[@]})
        ;;
    [1-9])
        if [ "${sel}" -le ${size} -a "${sel}" -gt "0" ]; then
            SELECTEDDIR=(${ALLDIRS[$((sel-1))]})
        fi
        ;;
    *)
        error "input is not recognized."
        ;;
esac
warning "Selected directories: ${SELECTEDDIR[@]}"
if ${TOSERVER} ; then
    warning_read "sync from localhost to server(172)[Y/n]? "
    read yn
else
    warning_read "sync from server(172) to localhost[Y/n]? "
    read yn
fi
if [ "${yn}" != "y" -a "${yn}" != "Y" ]; then
    error "exit, as you wished."
fi

LOCAL=
SERVER=
for dir in ${SELECTEDDIR[@]}; do
    LOCAL="${BASEDIR}/${dir}/"
    SERVER="cos@192.168.160.16:/home/cos/website/cos/${dir}/"
    if ${TOSERVER} ; then
        if [ ! -d ${LOCAL} ]; then
            error "${LOCAL} is not found."
        fi
        notice "rsync from ${LOCAL} to ${SERVER}"
        rsync -av --progress --delete ${LOCAL} ${SERVER}
    else
        notice "rsync from ${SERVER} to ${LOCAL}"
        rsync -av --progress --delete ${SERVER} ${LOCAL}
    fi
done
