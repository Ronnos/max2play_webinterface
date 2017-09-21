#!/bin/sh
installcheck=$(dpkg -s xbmc | grep 'Status: install' | wc -l)

source=$2

#Only Check if installed 
if [ "$1" = "check" ]; then	
	echo "installed=$installcheck"
else
	if [ "1" -gt "$installcheck" ] || [ "$1" = "update" ]; then
		
		#Only on RPI with Jessie: Update to latest Kodi from Repository pplware
		RELEASE=$(lsb_release -a 2>/dev/null | grep Codename | sed "s/Codename:\t//")		
		if [ "$RELEASE" = "jessie" -a "$source" = "kodiupgradepi" ]; then
			echo "deb http://pipplware.pplware.pt/pipplware/dists/jessie/main/binary /" > /etc/apt/sources.list.d/pplware.list
    		wget -O - http://pipplware.pplware.pt/pipplware/key.asc | sudo apt-key add -
    		apt-get update
    		apt-get install kodi -y
    		apt-get install kodi-pvr-stalker kodi-pvr-iptvsimple kodi-pvr-demo kodi-pvr-dvblink kodi-pvr-hts kodi-pvr-nextpvr -y
		elif [ "$RELEASE" = "stretch" -a "$source" = "kodiupgradepi" ]; then
			echo "TODO: this might not work yet!!! Check repository for Stretch version of Kodi on http://pipplware.pplware.pt/pipplware/dists/stretch/" 
			echo "deb http://pipplware.pplware.pt/pipplware/dists/stretch/main/binary /" > /etc/apt/sources.list.d/pplware.list
    		wget -O - http://pipplware.pplware.pt/pipplware/key.asc | sudo apt-key add -
    		apt-get update
    		apt-get install kodi -y --allow-unauthenticated
    		apt-get install kodi-pvr-stalker kodi-pvr-iptvsimple kodi-pvr-demo kodi-pvr-dvblink kodi-pvr-hts kodi-pvr-nextpvr -y --allow-unauthenticated
		else
		    # Old update routine by path or .deb file
			apt-get update
			if [ "$(cat /proc/cpuinfo | grep Hardware | grep BCM270 | wc -l)" -gt "0" ]; then
				# Fix Download for Raspberry PI Version
				cd /opt			
				wget -O kodi-15.tar.gz $source
				if [ ! -s kodi-15.tar.gz ]; then
					echo "ERROR! Given HTTP-Link to Kodi package does not exist! Please check URL $source"
					echo "finished"
					exit 
				fi			
				tar -xzf kodi-15.tar.gz
				apt-get remove kodi-bin -y
				cd kodi-15
				./install
				./install_cec3
				# get support for PVR-Addons
				sudo /var/www/max2play/application/plugins/max2play_settings/scripts/buildkodiplatform.sh			
			else		
				echo "Remove old version"
				dpkg -r xbmc
				dpkg -r kodi		
				wget -O /opt/max2play/xbmc.deb $source
				dpkg -i /opt/max2play/xbmc.deb
				# XU3/XU4 Ubuntu 15.04			
				# apt-get install libgnutls-dev
				echo "Installation abgeschlossen"
						
				# Fix Ubuntu 15.04 and ODROID XU4
				if [ "$(cat /proc/cpuinfo | grep Hardware | grep XU3 | wc -l)" -gt "0" ]; then
					# Fix für Bild, das nicht angezeigt wird (Fehler bei Kodi Start)
					rm -R /usr/lib/arm-linux-gnueabihf/mesa-egl/
					apt-get install fonts-roboto javascript-common libhdhomerun1 libjs-iscroll libjs-jquery libshairport2 -y
					# Needed for PVR-Plugins and others
					sudo /var/www/max2play/application/plugins/max2play_settings/scripts/buildkodiplatform.sh
					echo "Update for XU4 done"
				fi
				rm -R /usr/lib/arm-linux-gnueabihf/mesa-egl/
			fi
		fi
		echo "<b><a href='/plugins/max2play_settings/controller/Xbmc.php'>Click here to reload Page</a></b>"
	else
		echo "Is already installed - installed=$installcheck"
	fi
fi
echo "finished"


