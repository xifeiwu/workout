#! /bin/sh

#
# h=hour m=minute change the "9" or "30" if needed (now is 9:30)
# Write log to /var/log/reboot.log
#
rm -vf /var/log/s3.log

i=0
endtime=`date +%s --date="+12 hour"`

while true
do
timec=`timedatectl |awk '/Local/ {print $5}'`
date=`timedatectl|awk '/Local/ {print $4}'`

time=`date +%s`

if [ ${time} -lt ${endtime} ];then
	sleep 8s
	i=`expr ${i} + 1`
	echo "S3 Times" ${i} $date $timec >> /var/log/s3.log
	rtcwake -m mem -s 120
else
exit 0
fi
done

