#!/bin/sh
set -e

REPODIR=~/Public
REPONAME="cosrepo"
RELEASE="iceblue"

if [ ! -e ${REPODIR}/${REPONAME} ]; then
    echo "directory ${REPODIR}/${REPONAME} not exist. exit"
    exit
fi

cd ${REPODIR}/${REPONAME}

echo -e "\033[31m - git pull from repository.\033[0m"
git pull origin master

echo -e "\033[31m - update parameters.\033[0m"
echo "make apt.conf"
echo "APT::FTPArchive::Release {" >  dists/${RELEASE}/apt.conf
echo "Origin \"cos\";"   >> dists/${RELEASE}/apt.conf
echo "Label \"cos\";"  >> dists/${RELEASE}/apt.conf
echo "Suite \"iceblue\";"    >> dists/${RELEASE}/apt.conf
echo "Codename \"iceblue\";"  >> dists/${RELEASE}/apt.conf
echo "Versin \"0.5\";"    >> dists/${RELEASE}/apt.conf
echo "Architecture \"i386\";"  >> dists/${RELEASE}/apt.conf
echo "Components \"main\";"   >> dists/${RELEASE}/apt.conf
echo "Description \"cos iceblue\";" >> dists/${RELEASE}/apt.conf
echo "};"  >> dists/${RELEASE}/apt.conf

echo "make index file : Package, Package.gz, Package.bz2 ."
apt-ftparchive packages pool/main > dists/${RELEASE}/main/binary-i386/Packages
cat dists/${RELEASE}/main/binary-i386/Packages | gzip > dists/${RELEASE}/main/binary-i386/Packages.gz
cat dists/${RELEASE}/main/binary-i386/Packages | bzip2 > dists/${RELEASE}/main/binary-i386/Packages.bz2

echo "make content file : Contents-i386.gz"
apt-ftparchive contents pool/ | gzip -9c > dists/${RELEASE}/Contents-i386.gz

echo "make release file : Release, Release.gpg"
apt-ftparchive -c dists/${RELEASE}/apt.conf release dists/${RELEASE} > dists/${RELEASE}/Release
gpg -a --detach-sign -o dists/${RELEASE}/Release.gpg dists/${RELEASE}/Release

echo -e "\033[31m - git push to repository.\033[0m"
COMMITMSG=sil-58-`date +%Y-%m-%d-%H.%M`
git status
git add -A
git commit -m ${COMMITMSG}
git push origin master
