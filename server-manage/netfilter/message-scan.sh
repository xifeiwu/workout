#!/bin/bash
cat /var/log/messages | awk '/124.16.141.173/ {
if($8 == "SRC=124.16.141.173") 
{
#    sport=substr($str, 5)
    if($17 != "SPT=22" && $17 != "SPT=80")
    {
        print $0
    }
}
}'| uniq
