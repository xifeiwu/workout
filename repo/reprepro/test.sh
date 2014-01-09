#!/bin/sh
args=$#
echo "args : $args"
argv=($@)
echo "argv : ${argv[*]}"
function error()
{
    echo -e "\033[31m-$1 \033[0m"
    exit 1
}
function warning()
{
    echo -e "\033[34m-$1 \033[0m"
}
function notice()
{
    echo -e "\033[31m-$1 \033[0m"
}

INCOMING=/home/xifei/Public/project/workout/debsaved
DEBFILE=
i=0
while [ $i -lt $args ]
do
#echo "${i} : $(eval echo "\$$i")"
    case ${argv[$i]} in
    "-i"|"--incoming")
        ((i++))
        incoming=${argv[$i]}
        if [ -z "$incoming" ] ; then
            error "Incoming directory parameter is empty."
        else
            INCOMING=${incoming}
            ((i++))
            warning "Incoming directory you selected is : ${INCOMING}"
        fi
        ;;
    "-d"|"--deb")
        ((i++))
        debfile=${argv[$i]}
        while [ "${debfile##*.}" == "deb" ]
        do
            DEBFILE=(${DEBFILE[*]} ${debfile})
            ((i++))
            debfile=${argv[$i]}
        done
        warning "${DEBFILE[*]} will be added to repository."
        ;;
    *)
        ((i++))
    esac
done
    
cd $INCOMING
#  See if we found any new packages
found=0
for i in $INCOMING/*.changes; do
  if [ -e $i ]; then
    found=`expr $found + 1`
  fi
done
echo "found : ${found}"
