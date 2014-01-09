#!/bin/bash
#deblist=`cat deblist | awk '{print $3}'`
#echo deblist:${deblist}
#cosdeb=`echo ${deblist} | sed "s/null//g"`
#echo cosdeb:${cosdeb}
#sudo apt-get install -y --force-yes --reinstall ${cosdeb}
COSREPOIP="124.16.141.172"
    DEBLIST=`wget -q -O - http://${COSREPOIP}/cos/project/deblist`
    deblist=`echo "${DEBLIST}"| awk '{print $2}'`
    mintdeb=(${deblist})
    debcnt=${#mintdeb[*]}
    deblist=`echo "${DEBLIST}" | awk '{print $3}'`
    cosdeb=(${deblist})
echo cosdeb:${cosdeb[*]}
installdeb=`echo ${cosdeb[*]} | sed "s/null//g"`
echo installdeb:${installdeb} 
