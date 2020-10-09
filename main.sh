#/bin/bash
# TodoList

#Handle event
click_add(){
	data=$(yad --form --width=300 --height=200 --center \
		--field=Name --field="Due day":DT)
	data+="False|"
	yad --center --text=$i
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
done < <(sort -t'|' -k2 contactlist.txt)

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
	     
	     
	     
