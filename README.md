HandShaker
==========
- Detect, deauth, capture, crack WPA/2 handshakes and WEP keys.
- Crack WPS Pins
- Record AP location with Android GPS.
- Maintain a db of pwnd APs to avoid repetition.

Installation:
==========

Run 'make install' in the HandShaker directory.
handshaker will now be installed and can be run with 'handshaker'.
	
Usage
==========
		
		HandShaker - Detect, deauth, capture, crack WPA/2 handshakes and WEP Keys automagically. 
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
			-W  - Only attack WEP encrypted APs
			-s  - Silent
			-h  - This help

		Examples: 
			 handshaker -a -i wlan0 -T 5			       ~ Autobot mode on wlan0 and attempt 5 times.
			 handshaker -e Hub3-F -w wordlist.txt	 	   ~ Find AP like 'Hub3-F' and crack with wordlist.
			 handshaker -l -o out/dir			           ~ List all APs and save handshakes to out/dir.
			 handshaker -c handshake.cap -w wordlist.txt   ~ Crack handshake.cap with wordlist.
			 
		all your AP are belong to us..
