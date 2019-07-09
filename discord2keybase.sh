 username="$(keybase id 2>&1|sed 's/.* //;1q')"; echo keybase user: $username
 discordchannel=keybase
 keybasechannel=rholang.macrhobot
 tail -0f /home/rchain/.pm2/logs/rho-bot-out-5.log |
	 grep --line-buffered '^message: $discordchannel:'| 
	 grep -v --line-buffered "^message: $channel: $username"|tee /dev/tty|
	 while true; do L="$(sed 's/message: '"$channel"'://;s/ 20..-[^ ]* / /;s/\\n/\n/g;1q')";
		 if [ "$L" ]; then 
                    echo "L=$L"; keybase chat send $keybasechannel <<< "$L"; 
                 else sleep 1;
		 fi; 
	 done
