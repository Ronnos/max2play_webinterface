#!/bin/bash
# Preparations for different Systems: ODROID U3/C1/Raspberry PI
# start with "sudo install_max2play.sh firststart"
# after reboot just start install_max2play.sh

CWD=$(pwd)

HW_RASPBERRY=$(cat /proc/cpuinfo | grep Hardware | grep -i "BCM2708\|BCM2709" | wc -l)
HW_ODROID=$(cat /proc/cpuinfo | grep Hardware | grep -i Odroid | wc -l)
if [ "$HW_ODROID" -gt "0" ]; then
  USER=odroid
  echo "Hardware is odroid"
fi

if [ "$HW_RASPBERRY" -gt "0" ]; then
  USER=pi
  sudo mount -o remount,rw /
  echo "Hardware is Raspberry"
fi

if [ "$1" = "firststart" ]; then
	sudo apt-get update
	echo "Y" | sudo apt-get upgrade
	#get it FROM BETA!!!
	wget shop.max2play.com/media/downloadable/beta/max2play_complete.zip
	unzip max2play_complete.zip -d max2play
	sudo cp -r max2play/opt/* /opt
	chmod -R 777 /opt/max2play/
	
	#Expand FS!
	sudo /opt/max2play/expandfs.sh
	echo "Expand Filesystem finished"
	reboot
	exit 0
elif [ "$1" != "install" ]; then
	echo "Start with Parameter 'install_max2play.sh firststart' or 'install_max2play.sh install'"
	echo "firststart: update/upgrade and expand filesystem and get Max2Play files - automatically rebootes"
	echo "install: do all the fancy stuff and bring the webinterface to life"
	echo "This Script should be placed in /root"
	echo "Add Execute rights with 'chmod 777 install_max2play.sh'"
	exit 0
fi

chmod 666 /etc/fstab
echo "##USERMOUNT" >> /etc/fstab
cp /etc/fstab /etc/fstab.sav

crontab -u $USER -l > cronmax2play
sudo echo "* * * * * /opt/max2play/start_audioplayer.sh > /dev/null 2>&1" >> cronmax2play
crontab -u $USER cronmax2play
rm cronmax2play

sudo echo "Y" | apt-get install apache2 php5 php5-json
sudo a2enmod rewrite
rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default
cp max2play/CONFIG_SYSTEM/apache2/sites-enabled/max2play.conf /etc/apache2/sites-enabled/
sed -i 's/LogLevel warn/LogLevel error/' /etc/apache2/apache2.conf
cp -r max2play/max2play/ /var/www/max2play 
sudo /etc/init.d/apache2 restart
sudo echo "Y" | apt-get install samba samba-common mc
#NOT neccesary anymore: allow www-data access ssh

sudo apt-get install debconf-utils
if [ "$HW_RASPBERRY" -gt "0" ]; then
  	sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/;s/# it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/;s/# fr_FR.UFT-8 UTF-8/fr_FR.UFT-8 UTF-8/;s/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/;s/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen
  	locale-gen
else
	locale-gen ru_RU.UTF-8 
	locale-gen it_IT.UTF-8
	locale-gen fr_FR.UFT-8
	locale-gen de_DE.UTF-8 
fi

export LANG=en_GB.UTF-8
dpkg-reconfigure -f noninteractive locales
echo "Europe/Berlin" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

sudo apt-get install ifplugd
sudo echo "Y" | apt-get install nmap
sudo echo "Y" | apt-get remove xscreensaver

#HDidle
dpkg -i max2play/hd-idle_1.05_armhf.deb
#Config kopieren nach /etc/default

# Build hdidle:
#cvs -d:pserver:anonymous@hd-idle.cvs.sourceforge.net:/cvsroot/hd-idle login
#apt-get install cvs
#dpkg-reconfigure locales
#cvs -d:pserver:anonymous@hd-idle.cvs.sourceforge.net:/cvsroot/hd-idle login
#cvs -z3 -d:pserver:anonymous@hd-idle.cvs.sourceforge.net:/cvsroot/hd-idle co -P hd-idle
#apt-get install libc6-dev
#dpkg-buildpackage -rfakeroot
#cd hd-idle/
#dpkg-buildpackage -rfakeroot
#dpkg -i ../hd-idle_*.deb
#cd ..

sudo echo "Y" | apt-get install usbmount
cp -f max2play/CONFIG_SYSTEM/usbmount/usbmount.conf /etc/usbmount/usbmount.conf
 
#shairplay install 
#echo "Y" | apt-get install autoconf automake libtool libltdl-dev libao-dev libavahi-compat-libdnssd-dev avahi-daemon
#cd /tmp
#git clone git://github.com/juhovh/shairplay.git
#cd shairplay/
#./autogen.sh
#./configure
#make
#make install
#mkdir /opt/shairplay
#mkdir /opt/shairplay/log
#chmod 777 /opt/shairplay/log
#cp scr/shairplay /opt/shairplay

#shairport install
echo "Y" | apt-get install libssl-dev libavahi-client-dev libasound2-dev
pushd /tmp
git clone https://github.com/abrasive/shairport.git
cd shairport
./configure
make
mkdir -p /opt/shairport/log
chmod 777 /opt/shairport/log
cp shairport /opt/shairport

echo "Y" | apt-get install nettle-dev caps libasound2-dev
pushd /tmp
wget http://www.thedigitalmachine.net/tools/alsaequal-0.6.tar.bz2
tar xvjf alsaequal-0.6.tar.bz2 
cd alsaequal/
patch ctl_equal.c < $CWD/max2play/OTHER/alsaequal_ctl_equal.patch
make
mkdir /usr/lib/alsa-lib
make install
mkdir /usr/lib/arm-linux-gnueabihf/alsa-lib/
cp -R /usr/lib/alsa-lib/* /usr/lib/arm-linux-gnueabihf/alsa-lib/

#Squeezelite
echo -e "Y\ny\n" | apt-get install libav-tools cmake
# Raspberry PI Wheezy soxr:
if [ "$HW_RASPBERRY" -gt "0" ]; then
	#Raspberry PI: User PI nutzen!
	echo "SYSTEM_USER=pi" >> /opt/max2play/audioplayer.conf	
	echo -e "Y\ny\n" | apt-get install libavformat-dev ffmpeg libmpg123-dev libfaad-dev libvorbis-dev libmad0-dev libflac-dev libasound2-dev
	pushd /tmp
	wget -O soxr.tar.gz "http://downloads.sourceforge.net/project/soxr/soxr-0.1.1-Source.tar.xz"
	tar -xf soxr.tar.gz
	cd soxr*
	./go
	cd Release
	make install
else
   	echo -e "Y\ny\n" | apt-get install libsoxr-dev
   	echo "SYSTEM_USER=odroid" >> /opt/max2play/audioplayer.conf   	
fi

cp /opt/max2play/audioplayer.conf /opt/max2play/audioplayer.conf.sav

pushd /tmp
git clone https://code.google.com/p/squeezelite/
cd squeezelite
OPTS="-DFFMPEG -DRESAMPLE -DVISEXPORT" make
mkdir /opt/squeezelite
mkdir /opt/squeezelite/log
chmod 777 /opt/squeezelite/log
cp /tmp/squeezelite/squeezelite /opt/squeezelite/
pushd $CWD

#Squeezeboxserver unter Ubuntu 14.04
echo "Y" | apt-get install libungif-bin
#symlinks von /usr/lib/libungif.so auf /usr/lib/arm-linux.../libgif.so
#cd /tmp
#mkdir lms
#cd lms 
#git clone -b public/7.8 https://github.com/Logitech/slimserver-vendor.git
#buildme.sh -> tests raus
#tar -pczf Image-Scale-0.08.tar.gz Image-Scale-0.08 adc -> add in fixes header
#symlinks auf libgif.* in build/lib/libungif.la,a,so

#CPAN-Fixes auf Image kopieren für Perl 5.18
mkdir -p /opt/CPAN/7.8

#fix exzessives Logging in syslog & co (cron)
cp -f max2play/CONFIG_SYSTEM/rsyslog.conf /etc/rsyslog.conf

#Copy Config Files / Update Max2Play einmalig nötig
echo "1.0" > /var/www/max2play/application/config/version.txt

if [ "$HW_RASPBERRY" -gt "0" ]; then
	rm -R /opt/CPAN
	rm -R /opt/squeezeslave
	
	#Squeezeplug Header & CSS & Plugin-Auswahl
	cp -f /var/www/max2play/application/plugins/squeezeplug/view/header_custom.php /var/www/max2play/application/view/
	cp -f /var/www/max2play/public/addons/squeezeplug/custom.css /var/www/max2play/public/
	cp -f /var/www/max2play/application/plugins/squeezeplug/scripts/plugins.xml /var/www/max2play/application/config/plugins.xml
	
	#Raspberry: asound.conf.pi (Equalizer Options)
	cp -f max2play/CONFIG_SYSTEM/asound.conf.pi /etc/asound.conf
	#Sudoers
	cp -f max2play/CONFIG_SYSTEM/sudoers.d/max2play /etc/sudoers.d/
	#Network
	cp -f max2play/CONFIG_SYSTEM/network/* /etc/network/
	chmod 666 /etc/network/*
	#Samba
	cp -f max2play/CONFIG_SYSTEM/samba/smb.conf /etc/samba/
	#Udev Rules
	cp -f max2play/CONFIG_SYSTEM/udev/rules.d/* /etc/udev/rules.d/
	
	sudo sed -i 's/SQUEEZELITE_PARAMETER.*/SQUEEZELITE_PARAMETER=-o plug:plugequal/' /opt/max2play/audioplayer.conf	
	
	echo "Gesamtlautstärke auf 100% setzen: alsamixer"
	su - $USER -c 'amixer -q set "PCM" 100'
	sudo amixer -q set "PCM" 100
	sudo alsactl store 0
	
	echo "TODO: Update to latest Beta - nur möglich nach eMail-Adresseingabe in Max2Play-Webinterface"
	echo "TODO: Reboot!"	
fi

#Change Password to default
echo -e "max2play\nmax2play\n" | passwd
mkdir /mnt/mountdir
chmod -R 777 /mnt/mountdir
chmod 666 /etc/hostname
echo "max2play" > /etc/hostname

#ODROID C1:
#edit /etc/passwd allow login www-data /bin/bash for XBMC/Kodi start
#edit Desktop for Max2Play Picture AND Desktop Start Kodi
#Add Autostart xbmc for session lxpanel 
#Wlan zum laufen bringen
#feste Mac löschen: rm /etc/smsc95xx_mac_addr
#udev persistent net rules Mac-Adresse von eth0 ist falsch
#echo "Y" | apt-get install iw
#nano /etc/default/autogetty # remove enabled for 100%CPU usage bash

#Remove Install Files in local directory
rm -R max2play
rm -R max2play_complete.zip
rm -R shairport
rm install_max2play.sh