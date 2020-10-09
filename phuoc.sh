#/bin/bash
# TodoList

#Handle event
click_add(){
	data=$(yad --form --width=300 --height=200 --center \
		--field=Name)
	IncomingTime=$(zenity --forms --title="Add Time" \
	--separator=":" \
	--add-entry="Hour" \
	--add-entry="Minute" \
	--add-entry="Second" \ )
	
	echo $IncomingTime
	IncomingDate=$(zenity --forms --title="Add Date" \
	--separator=":" \
	--add-calendar="Date" \ )

	Incoming="$IncomingDate $IncomingTime"


	echo $Incoming

	while [ : ]
	do

	Datenow=$(date +'%m/%d/%Y')
	Timenow=$(date +'%T')

	CurrentDate="$Datenow $Timenow"

	duration=$(($(date -d "$Incoming" '+%s') - $(date -d "$CurrentDate" '+%s')))

	echo $CurrentDate
	echo $duration
	if [[ $duration -eq 0 ]]
	then break
	fi

	done
	zenity --notification --text="Bay gio la $Incoming.\nTO-DO: $data"
	ffplay -nodisp -autoexit alarm.mp3 >/dev/null 2>&1
	# yad --center --text="Success"
	
}

click_delete(){
	yad --center --text="Delete"
}

select_item_in_list(){
	choice=$1
	yad --center --text=$choice
}

export -f click_add click_delete select_item_in_list

#Read data from file text
items=()



while IFS='|' read -r stt name dueDay status; do
    if [[ status ]]; then
        items+=( "$stt" "$name" "$dueDay" "$status" )
    else
        items+=( "$stt" "$name" "$dueDay" "False" )
    fi
done < <(sort -t'|' -k2 data.txt)

#while(true);
#do
choice=$(yad --width=1000 --height=800  \
	     --title "Todo-List" \
	     --list \
	     --button=Add:"bash -c click_add" \
	     --button=Delete:"bash -c click_delete " \
	     --separator= --column="Stt" --column="Name" \
	     --column="Due day" --column="Status" \
	     "${items[@]}")

#echo $choice
#if [[ $? == 0 ]] && [[ $choice == "" ]];
#then break
#else yad --center --text=$choice
#fi
	     
#done
