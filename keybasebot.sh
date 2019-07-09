#!/bin/bash
# ./keybasebot.sh >> /tmp/keybase.log &
username="$(keybase id 2>&1|sed 's/.* //;1q')"; echo keybase user: $username
CHANNEL=rholang.macrhobot # default
keybase chat api-listen | while true; do L="$(sed 's/```\(.*\)```/\1/;1q')"
{
	OUT=$(jq --raw-output 'select(.type == "chat")|select(.msg.content.text.body|startswith("!rhobot "))| .msg.content.text.body | "" + ltrimstr("!rhobot ") + ""' <<< "$L" 2>&1 || echo "error: invalid json" 1>&2 )
	CHANNEL=$(jq --raw-output '.msg.channel.name' <<< "$L" )
	USER=$(jq --raw-output '.msg.author.username' <<< "$L" )
	echo channel $CHANNEL 1>&2
    if [[ "${CHANNEL}" =~ "$USER" ]]; then : private; else echo $L ; fi # exclude private channels
    case "$OUT" in
	eval\ *) 
	    echo "${OUT:5}" >/tmp/userid.rho
	    keybase chat send "$CHANNEL" "$(rnode eval /tmp/userid.rho \
		    | sed '/Storage Contents:/q'|egrep -v "(^Storage|^Result for|^Evaluating)" &&
		    tac ~rchain/rnode.log|sed '/^Evalu/q;/^\}$/q'|grep -v "^}$"|head -20|tac)"
	    echo '}' >>~rchain/rnode.log #tweak to stop repeating results on syntax error
	    ;;
        *)
           if [ "${OUT}" != "" ]; then
           {
               echo keybase chat send "${CHANNEL}" "${OUT}" 1>&2
           }; fi ;;
	esac
}; done
