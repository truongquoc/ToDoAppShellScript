
echo "The message is: $Incoming"
echo "The name is: " $name
while [ : ]
	do

	Datenow=$(date +'%m/%d/%Y')
	Timenow=$(date +'%T')

	CurrentDate="$Datenow $Timenow"

	duration=$(($(date -d "$Incoming" '+%s') - $(date -d "$CurrentDate" '+%s')))

	if [[ $duration -eq 0 ]]
	then break
	fi

	done
	zenity --notification --text="Bay gio la $Incoming.\nTO-DO: $name"
	ffplay -nodisp -autoexit alarm.mp3 >/dev/null 2>&1
