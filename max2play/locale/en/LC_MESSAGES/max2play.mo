��          �            h  #   i     �  ,   �  '   �     �       �   .            *   1  \   \     �     �     �  �  �  #   �  �  �  �  �  f  �	  �    �   �  �   �  �   `  �  U  *   �  L     !   h     �     �               
                    	                                             //www.youtube.com/embed/GjYnHZF2Oek DONATE-BUTTON Important Information Filesystem Description Important Information Samba Description SQUEEZEPLAYER INFO DESCRIPTION SQUEEZESERVER INFO DESCRIPTION The Max2Play Interface is used to configure the device without having to set up monitor, keyboard and mouse on the device itsself or login by ssh.<br />All settings are directly written to the players config files. WLAN INFO DESCRIPTION XBMC INFO DESCRIPTION http://shop.tellows.de/de/anrufblocker-faq http://shop.tellows.de/de/lizenzschlussel-fur-tellows-community-sperrliste-anrufblocker.html http://www.max2play.com/faq/ logo tellows Anrufblocker Project-Id-Version: Max2Play Übersetzungen
Report-Msgid-Bugs-To: 
POT-Creation-Date: 2015-02-06 12:26+0100
PO-Revision-Date: 2015-02-06 12:26+0100
Last-Translator: 
Language-Team: 
Language: en_GB
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Poedit-KeywordsList: _;gettext;gettext_noop;translate
X-Poedit-Basepath: .
X-Poedit-SourceCharset: UTF-8
X-Generator: Poedit 1.5.4
X-Poedit-SearchPath-0: y:\projects\max2play
 //www.youtube.com/embed/wMunsRtFQ6M <form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top"><input type="hidden" name="cmd" value="_s-xclick"><input type="hidden" name="hosted_button_id" value="Y89SJ9MMLEBRQ"><input type="image" src="https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif" border="0" name="submit" alt="PayPal – The safer, easier way to pay online."><img alt="" border="0" src="https://www.paypalobjects.com/de_DE/i/scr/pixel.gif" width="1" height="1"></form> Network Shares like NFS (e.g. Synology Diskstation) are mounted following the example:<br />	<b>Mountpoint (IP or hostname and Path):</b> z.B. <i>//IP-ADDRESS/PATH</i> <br /><b>existing Path on Max2Play (for usage in Squeezeserver or XBMC):</b> <i>/mnt/mountdir/</i> <br />	<b>Type:</b> mostly <i>cifs</i> <br /><b>Options (user, password and other options for network share):</b> e.g. <i>user=name,password=pass,sec=ntlm,iocharset=utf8</i><br />important: always add to the options <i>sec=ntlm</i> ! Samba is used to set up network shares for other devices to access the Players filesystem. If, for example a USB-disk is connected to the Player, this USB-disk may contain media data that should be accessed by other computers.<br /><b>Example #1 - Share USB-drive to local network:</b> <br />Name: max2play-usb<br />Path: /media/usb<br />Writeable: yes<br /> Squeezelite is a software designed for the Squeezebox player, which works with the Logitech Media Server (Squeezebox Server) and is similar to a Squeezebox Receiver and how it is controllable via the server.<br />Shairport is a service of Apple Airplay. <br />Both services of ODROID will start with a slight delay to load (less than a minute) to avoid conflict with the sound drivers.   Squeezeserver (Logitech Media Server) is the server used for Squeezebox and is responsible for the control of the player. At least one such network server should be running. The server can be installed on the Start Setup on Max2Play. The Max2Play Interface is used to configure the device without having to set up monitor, keyboard and mouse on the device itsself or login by ssh.<br />All settings are directly written to the players config files. Info: Please restart the device after changing the network parameters! When operating several Max2Play devices, the MAC address for LAN must be different in each case on the devices. 	<br /> Keep in mind the network name upper and lower case.   XBMC is a Media-Center for videos, Music and more.<br /><br /><sup>#1</sup>Autostart XBMC: if activted, the device boots directly into XBMC. This option is suggested if you use the Player mostly for videos. If the device is not connected to a TV or the video playback is seldom used remove the XBMC from autostart. Therefore it uses less resources.<br /><br /><b>IMPORTANT:</b><br />If XBMC is running Squeezelite will be deactivated! This is neccessary to get Audio in XBMC working. XBMC uses pulseaudio and Squeezelite as well as Shairplay use Alsa to play sounds/music at the same time. When XBMC is closed, Squeezelite will start again if it is set to autostart. http://shop.tellows.de/en/anrufblocker-faq http://shop.tellows.de/en/licence-key-for-tellows-blocklist-callblocker.html http://www.max2play.com/en/faq-2/ logo-en tellows Callblocker 