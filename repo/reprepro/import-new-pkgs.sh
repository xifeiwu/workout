#!/bin/sh
if [ -f ./get_parameters.sh ]; then
    source ./get_parameters.sh
else
    echo -e "\033[2;31m-./get_parameters.sh not found.\033[0m"
    exit 1
fi

INCOMING=
declare -a DEBFILES
declare -a CHANGESFILES
args=$#
argv=($@)
argp=0
if [ "${args}" == "0" ] ; then
    error "More parameters are needed. -h or --help for more infomation."
fi
while [ "${argp}" -lt "${args}" ]
do
    case ${argv[$argp]} in
    "-C"|"--component")
        ((argp++))
        COMPONENTS=${argv[${argp}]}
        echo ${COMPONENTS} | egrep '^main$|^multiverse$|^restricted$|^universe$' > /dev/null 2>&1
        if [ $? -eq 0 ] ; then
            ((argp++))
        else
            error "${COMPONENTS} is not a component, select from (main multiverse restricted universe)"
        fi
        ;;
    "-I"|"--incoming")
        ((argp++))
        INCOMING=`echo ${argv[$argp]} | sed "s:\(.*\)/$:\1:"`
        if [ -d "${INCOMING}" ] ; then
            ((argp++))
        else
            error "${INCOMING} is not a directory."
        fi
        ;;
    "-d"|"--deb")
        ((argp++))
        arg=${argv[$argp]}
        if [ ! -z ${arg} ] && [ ${arg} == "." ]; then
            if [ -d ${INCOMING} ]; then
                DEBFILES=(`find $INCOMING -name '*.deb'`) > /dev/null 2>&1
                ((argp++))
                continue
            else
                error "${INCOMING} is not a directory."
            fi
        fi
        while [ "${arg##*.}" == "deb" ] && [ "$argp" -lt "$args" ]
        do
            arg=${INCOMING}/${arg}
            if [ -f ${arg} ]; then
                DEBFILES=(${DEBFILES[@]} ${arg})
            else
                warning "Warning: ${arg} is not a file."
            fi
            ((argp++))
            arg=${argv[$argp]}
        done
        ;;
    "-c"|"--changes")
        ((argp++))
        arg=${argv[$argp]}
        #echo "in changes: argp: ${argp} arg : ${arg} args: ${args}"
        if [ ! -z ${arg} ] && [ ${arg} == "." ]; then
            if [ -d ${INCOMING} ]; then
                CHANGESFILES=(`find $INCOMING -name '*.changes'`) > /dev/null 2>&1
                ((argp++))
                continue
            else
                error "${INCOMING} is not a directory."
            fi
        fi
        while [ "${arg##*.}" == "changes" ] && [ "$argp" -lt "$args" ]
        do
            arg=${INCOMING}/${arg}
            if [ -f ${arg} ]; then
                CHANGESFILES=(${CHANGESFILES[@]} ${arg})
            else
                warning "Warning: ${arg} is not a file."
            fi
            ((argp++))
            arg=${argv[$argp]}
        done
        ;;
    "-h"|"--help")
        echo "Usage import-new-pkgs:"
        echo "Used to refresh repository by import .changes or .deb files"
        echo "  [-C | --component]  :   specify component"
        echo "  [-I | --incoming]   :   set incoming directory"
        echo "  [-c | --changes]    :   add .changes file manually in incoming directory."
        echo "  [-d | --deb]        :   add .deb file manually in incoming directory."
        echo "More : if . is follow by parameter -c or -d the corresponding file will find automatically in incoming directory."
        exit 1
        ;;
    *)
        warning "parameter ${argv[$argp]} is not recognized."
        ((argp++))
    esac
done
if [ -z ${INCOMING} ]; then
    error "In coming directory is not given, -h for help"
fi
if [ "${#DEBFILES[@]}" == "0" ] && [ "${#CHANGESFILES[@]}" == "0" ]; then
    error "No .changes file or .deb file was found by parameter you given, -h for help."
fi
#exit 9

notice "BASEDIR: ${BASEDIR}"
notice "CODENAME: ${CODENAME}"
notice "SignWith: ${KEYRING}"
notice "COMPONENTS: ${COMPONENTS}"
notice "Incoming directory: ${INCOMING}"
if [ "${#DEBFILES[@]}" == "0" ] ; then
    warning "No .deb file was find in directory ${INCOMING}."
else
    notice ".deb file found are listed below:"
    for ((i=0; i<${#DEBFILES[@]}; i++)); do
        tmp=`echo ${DEBFILES[$i]} | sed "s:${INCOMING}/::g"`
        echo -e $(($i+1)).$tmp
    done 
fi
if [ "${#CHANGESFILES[@]}" == "0" ] ; then
    warning "No .changes file was find in directory ${INCOMING}."
else
    notice ".changes file found are listed below:"
    for ((i=0; i<${#CHANGESFILES[@]}; i++)); do
        tmp=`echo ${CHANGESFILES[$i]} | sed "s:${INCOMING}/::g"`
        echo -e $(($i+1)).$tmp
    done 
fi
while true
do
    read -p "-Make sure the messages above is correct, go on?[y/n] : " yn
    if [ -z ${yn} ] ; then
        continue
    fi
    if [ "${yn}" == "y" ] ; then
        break
    elif [ "${yn}" == "n" ] ; then
        exit 0
    fi
done

#export gpg pub key to dir ${BASEDIR}/project
gpg --export -a ${KEYRING} > ./project/keyring.gpg
while true
do
    read -p "-Update dir project? [y/n] : " yn
    if [ -z ${yn} ] ; then
        continue
    fi
    if [ "${yn}" == "y" ] ; then
        cp -r ./project/ ${BASEDIR}
        break
    elif [ "${yn}" == "n" ] ; then
        break 
    fi
done

#import package from .changes files in incoming directory
notice "Start import .changes files."
cnt=1
for file in ${CHANGESFILES[@]}; do
    name=`sed -n '/Binary:/p' ${file} | awk '{print $2}'`
    if [ -z $name ] ; then
        echo "error : not find package name in .change file."
        exit 1
    fi
    
    while true
    do
        read -p "-${cnt}.Add file ${file} to repo, yes? [y/n] " yn
        if [ -z ${yn} ] ; then
            continue
        fi
        if [ "${yn}" == "y" ] ; then
            reprepro -V --confdir ./conf -C ${COMPONENTS} -A ${ARCHITECTURE} ${IGNORE} remove ${CODENAME} $name
            reprepro -V --confdir ./conf -C ${COMPONENTS} -A ${ARCHITECTURE} ${IGNORE} include ${CODENAME} $file
            if [ "$?" == "0" ] ; then
                notice "Add $file to repos successd."
                ((cnt++))
            else
                notice "Add $file to repos fail."
            fi
            break
        elif [ "${yn}" == "n" ] ; then
            notice "File ${file} ignored."
            break
        elif [ "${yn}" == "N" ] ; then
            notice "All other .changes file ignored."
            break 2
        fi
    done
done
notice "Finished import .changes files."

#import package from .deb files in incoming directory
notice "Start import .deb files."
for file in ${DEBFILES[@]}; do
    while true
    do
        read -p "-${cnt}.Add file ${file} to repo, yes? [y/n] " yn
        if [ -z ${yn} ] ; then
            continue
        fi
        if [ "${yn}" == "y" ] ; then
            reprepro -V --confdir ./conf -C ${COMPONENTS} -A ${ARCHITECTURE} ${IGNORE} remove ${CODENAME} `dpkg -f $file Package`
            reprepro -V --confdir ./conf -C ${COMPONENTS} -A ${ARCHITECTURE} ${IGNORE} includedeb ${CODENAME} $file
            if [ "$?" == "0" ] ; then
                notice "Add $file to repos successd."
                ((cnt++))
            else
                notice "Add $file to repos fail."
            fi
            break
        elif [ "${yn}" == "n" ] ; then
            notice "File ${file} ignored."
            break
        elif [ "${yn}" == "N" ] ; then
            notice "All other deb file ignored."
            break 2
        fi
    done
done
notice "Finished import .deb files."


#=================================================================
#find .changes file in incoming directory
#found=0
#for file in $INCOMING/*.changes; do
#    if [ -e $file ]; then
#        found=`expr $found + 1`
#    fi
#done
#for file in $INCOMING/*.deb; do
#    if [ -e $file ]; then
#        found=`expr $found + 1`
#    fi
#done
#if [ "$found" -lt 1 ]; then
#    echo "not find .changes file in incoming dir : ${INCOMING}."
#    exit 1
#fi

#    sed '1,/Files:/d' $file | sed '/BEGIN PGP SIGNATURE/,$d' \
#         | while read MD SIZE SECTION PRIORITY NAME; do
#        if [ -z "$NAME" ]; then
#             continue
#        fi
#        if [ -f "$INCOMING/$NAME" ]; then
#            rm "$INCOMING/$NAME"  || exit 1
#        fi
#    done
#    rm  $file
