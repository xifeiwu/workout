#!/bin/bash

[ -e /var/log/s4.log ] && rm -f /var/log/s4.log
if [ `grep "timeout=-1" /boot/grub/grub.cfg | wc -l` -eq 2 ];then
	sed -i '81s/timeout=-1/timeout=0/' /boot/grub/grub.cfg
fi
dat=$(date +%s -d "12 hour")
while :
do
	tim=$(date +%s)
	if [ $tim -lt $dat ];then
		sleep 10
		echo "rtcwake S4 `date`" >>/var/log/s4.log
		rtcwake -m disk -s 120
	else
		break
	fi
done

