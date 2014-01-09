REPODIR=~/Public
REPONAME="cosrepo"
RELEASE="iceblue"

cd ${REPODIR}
if [ -e ${REPONAME} ] ; then
    echo "dir ${REPONAME} already exist. exit"
    exit
else
    echo "make dir ${REPONAME}."
    mkdir ${REPONAME}
fi

echo "make sub directory."
cd ${REPONAME}
mkdir -p dists/${RELEASE}/{main,restrict,universe,multiverse}/{binary-i386,binary-amd64}
mkdir -p pool/{main,restrict,universe,multiverse}
mkdir -p project

echo "create gpg."
#gpg -K
#gpg --gen-key
#gpg --export -a 72368F36 > project/keyring.gpg

