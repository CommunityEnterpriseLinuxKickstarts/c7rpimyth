#!/bin/sh
##Builds the c7rpiMyth Image##
#BUILT NATIVELY ON A RPI3 with CENTOS 7 altarch 1810
#place this script, revfat+4rpi.sh and your lmc kickstart in a common directory.
#mark as executable if needed #chmod +x 
#The only arg is the kickstart configuration name
#Place in a location with enough space to build your image
#The script will increment up with $BUILD each time it finishs a regeneration
#after a good build you can rewrite the /boot back out as vfat with revfat+4rpi.sh 
if [ $(id -u) -ne 0 ]; then
    echo "Root privileges are required for running $0."
    exit 1
elif [ -z $1 ]; then
    echo "Usage: $0 [KICKSTARTFILE]"
    exit 1
fi

BUILD=1;#++
nextBUILD=$((++BUILD))
DATESTAMP=`date +%Y%m%d`
UPREL=1810
#change to your proxy or rem out
MYPROXY=http://192.168.1.1:3128
TMPDIR=./TMPDIR
LOGFILE=c7rpiMyth.imagecreation.build.log
IMAGENAME=c7rpiMyth.raw.img

if [ ! -d ./TMPDIR ];then
	mkdir -v ./TMPDIR	
else 
	rm -rfv ./TMPDIR/*
fi


nohup livemedia-creator --ks $1 --no-virt --image-only --keep-image --make-disk --proxy=$MYPROXY --logfile=$LOGFILE --tmp=$TMPDIR --resultdir ./OUT --image-name=$IMAGENAME && sed -i "/#++$/s/=.*#/=$nextBUILD;#/" ${0} &

#dont forget to rewrite the /boot part and update fstab with revfat+4rpi.sh
#eg use
#./revfat+4rpi.sh [IMAGENAME]  RPIBOOTPART 
