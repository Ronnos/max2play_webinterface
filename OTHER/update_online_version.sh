#!/bin/bash
# Update Version Script
# Zip Files for new Version - Update Version and send Files to Server
echo "Usage: update_online_version.sh live|beta"

if [ "$1" = "live" ]; then
  VERSION="currentversion"
elif [ "$1" = "beta" ]; then
  VERSION="beta"
else
  exit 0
fi
echo "Sync to $VERSION"

LOGFILE='rsync.log'
SOURCEPATH='/home/webuser/projects/max2play_git'
SOURCEPATHPREMIUM='/home/webuser/projects/Max2Play_Premium'
DESTPATH="/var/www/shopmax2play/magento2/pub/media/downloadable/$VERSION"
SOURCEPATHOPT='/home/webuser/projects/max2play_git/opt/max2play/'
NEWSPATH='/var/www/max2play/wordpress/wp-content/uploads/max2play/news/'

#Change File permissions due to eclipse Bug
chmod -R 777 $SOURCEPATH/max2play
chmod -R 777 $SOURCEPATH/opt/max2play
find $SOURCEPATH -name "*.sh" | xargs chmod 777
find $SOURCEPATH -name "*.exp" | xargs chmod 777
find $SOURCEPATH -type f -regextype sed -regex ".*/init.d/[^\.]*" | xargs chmod 777
find $SOURCEPATHPREMIUM -name "*.sh" | xargs chmod 777
find $SOURCEPATHPREMIUM -name "*.exp" | xargs chmod 777
find $SOURCEPATHPREMIUM -not -name "*.*" -not -type d | xargs chmod 777

HOSTS=( "176.9.62.132")
DESTHOSTNEWS="176.9.62.131"
PREMIUMPLUGINS=( "clementine" "fhem" "jivelite" "callbot" "homematic" "raspberrysettings" "multisqueeze" "sdcardprotection" "vnc" "printserver" "hifiberry" "iqaudio" "justboom" "mpd" "imageburner" "rpitouchdisplay" "rpicam" "rpisensehat" "voicecontrol" "frankenmatic" "bluetooth" "remotecontrol" "pluginbuilder" "allo" "multishairport" "autostartbrowser" "audiophonics" "arbalet" "spotifyconnect" "hardwarecontrol" "openhab" "SSLConnectionFix" )
# integrate "accesspoint" and "passwordprotection" in default Max2Play -> removed from ODPLUGINS
ODPLUGINS=( "kernelmodules_odroid_u3" "speechcontrol" "squeezeplug" )
PLUGINS=("${ODPLUGINS[@]}" "${PREMIUMPLUGINS[@]}")
PLUGINSTRING=$(printf " *\\%s\\*" "${PLUGINS[@]}")
PLUGINSTRING=${PLUGINSTRING:1}
echo "external Plugins: $PLUGINSTRING"

for DESTHOST in "${HOSTS[@]}"
do
	echo $'\n'
	echo $DESTHOST
	pushd $SOURCEPATH
	EXCLUDE="\*svn\* .settings\* \*screens\* Anleitung_Install.txt $PLUGINSTRING" #hd-idle_1.05\* CPAN_ARM_ODROID\*
	
	if [ "$VERSION" = "beta" ]; then
		cp -f max2play/application/config/version.txt max2play/application/config/mainversion.txt
		echo "Beta-"$(date +"%y%m%d") > max2play/application/config/version.txt
	fi
	
	eval "zip -r max2play_complete.zip . -x  $EXCLUDE"	
	eval "zip -r webinterface.zip ./max2play -x $EXCLUDE"
	
	if [ "$VERSION" = "beta" ]; then
		cp -f max2play/application/config/mainversion.txt max2play/application/config/version.txt
		rm max2play/application/config/mainversion.txt
	fi
	
	#include files from /etc and put them to right place before zipping
	mkdir etc	
	cp -R CONFIG_SYSTEM/init.d etc/init.d
	cp -R CONFIG_SYSTEM/sudoers.d etc/sudoers.d		
	cp -R CONFIG_SYSTEM/usbmount etc/usbmount
	
	###  include config files from /home/odroid - panel erstmal rausgenommen - genügt in Grundkonfiguration ###
	#mkdir -p home/odroid/.config
	#cp -R CONFIG_USER/lxpanel home/odroid/.config	
	#in folgenden zip befehl zu scripts.zip ./home/odroid/.config/lxpanel
	
	zip -r scripts.zip ./opt/max2play ./etc/usbmount/usbmount.conf ./etc/init.d/squeezelite ./etc/init.d/gmediarender ./etc/init.d/shairport ./etc/sudoers.d/max2play -x /opt/max2play/playername.txt /opt/max2play/samba.conf /opt/max2play/wpa_supplicant.conf /opt/max2play/audioplayer.conf /opt/max2play/autostart.conf
	rm -R etc
	#rm -R home
	scp $SOURCEPATH/webinterface.zip root@$DESTHOST:$DESTPATH
	scp $SOURCEPATH/scripts.zip root@$DESTHOST:$DESTPATH
	scp $SOURCEPATH/max2play_complete.zip root@$DESTHOST:$DESTPATH
	scp $SOURCEPATH/max2play/application/config/version.txt root@$DESTHOST:$DESTPATH
	rm webinterface.zip
	rm scripts.zip
	rm max2play_complete.zip
	echo "Completed Max2Play"
	
	#Create and upload Plugins
	for ODPLUGIN in "${ODPLUGINS[@]}"
	do
    	tar -cf $ODPLUGIN.tar -C $SOURCEPATH/max2play/application/plugins/ $ODPLUGIN
		scp $SOURCEPATH/$ODPLUGIN.tar root@$DESTHOST:$DESTPATH
		rm $ODPLUGIN.tar
	done
	
	#Create and upload Plugins
	for PREMIUMPLUGIN in "${PREMIUMPLUGINS[@]}"
	do
		tar -cf $PREMIUMPLUGIN.tar -C $SOURCEPATHPREMIUM/plugins/ $PREMIUMPLUGIN
		scp $SOURCEPATH/$PREMIUMPLUGIN.tar root@$DESTHOST:$DESTPATH
		rm $PREMIUMPLUGIN.tar
	done
		
done

exit

#################################### NEWS #############################################
scp $SOURCEPATHPREMIUM/news/news.php root@$DESTHOSTNEWS:$NEWSPATH

#################################### Callblocker #######################################
# Update Version Script
 
LOGFILE='rsync.log'
SOURCEPATH='/home/webuser/projects/max2play/max2play/application/plugins'
DESTPATH="/var/www/cdn.tellows/wordpress/uploads/downloads/callblocker/$VERSION"
SOURCEPATHOPT='/home/webuser/projects/callblocker'

HOSTS=( "176.9.62.132" )

for DESTHOST in "${HOSTS[@]}"
do
	echo $'\n'
	echo $DESTHOST
	#### Pack and Copy Webinterface and Version ####
	pushd $SOURCEPATH
	zip -r webinterface_max2play_plugin.zip ./callblocker -x  *svn* *custom*
	scp $SOURCEPATH/webinterface_max2play_plugin.zip root@$DESTHOST:$DESTPATH	
	rm webinterface_max2play_plugin.zip
	
	#### Pack and Copy Scripts ####
	pushd $SOURCEPATHOPT
	zip -r scripts.zip ./callblocker -x /callblocker/tellows.conf /callblocker/linphone.conf /callblocker/button.c /callblocker/cache	
	scp $SOURCEPATHOPT/scripts.zip root@$DESTHOST:$DESTPATH
	scp $SOURCEPATHOPT/callblocker/version.txt root@$DESTHOST:$DESTPATH
	
	rm scripts.zip
	echo "Completed Callblocker" 
done