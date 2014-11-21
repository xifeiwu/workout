# !/bin/sh
if [ $# -le 0 ]; then
    echo "the dir path should put as first parameter."
    exit 1
fi
TMPDIR="TMP"
if [ ! -d $1 ]; then
    echo "$1 is not a dir"
    exit 1
else
    mkdir -p ./${TMPDIR}/$1
fi
for file in `find $1`
do
    if [ -f $file ]; then
        dstfile="./${TMPDIR}/$file"
        dstdir=`dirname $dstfile`
        if [ ! -d $dstdir ]; then
            mkdir -p $dstdir
        fi
        echo "from $file to $dstfile"
        sed 's/    /  /g' $file > $dstfile
    fi
done