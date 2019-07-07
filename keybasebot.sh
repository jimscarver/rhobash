#!/bin/bash
CHANNEL=rholang.macrhobot
keybase chat api-listen | while true; do L="$(sed 's/```\(.*\)```/\1/;1q')"
{
	OUT=$(jq --raw-output 'select(.type == "chat")|select(.msg.content.text.body|startswith("!rhobot "))| .msg.content.text.body | "" + ltrimstr("!rhobot ") + ""' <<< "$L" 2>&1 || echo "error: invalid json" )
	CHANNEL=$(jq --raw-output '.msg.channel.name' <<< "$L" )
	echo channel $CHANNEL
    echo $L 
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
               echo keybase chat send "${CHANNEL}" "${OUT}"
           }; fi ;;
	esac
}; done
