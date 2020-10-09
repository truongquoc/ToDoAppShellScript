#!/bin/bash

# NAME: websync
# PATH: $HOME/bin
# DESC: Provide list of files and corresponding website addresses.

# DATE: Mar 25, 2017.

# NOTE: Uses yad which is fork of zenity which is GUI fork of dialog.

# TODO: Add local file date modified. Add Answer last revision date.
#       Add question title.
#       Add file word count, or size, or ignore as irrelevant?
#   Add answer word count if file word count is displayed.
#       Add answer up votes.
#   Scan directory to add all files. ("Populate" button)
#   Initialize $ListArr[@] < /home/$USER/bin/.websync
#   Use "|" as ListArr delimeter or (double quotes?) for file names with spaces

# Must have the yad package.
command -v yad >/dev/null 2>&1 || { echo >&2 "yad package required but it is not installed.  Aborting."; exit 99; }

# Must have the zenity package.
command -v zenity >/dev/null 2>&1 || { echo >&2 "yad package required but it is not installed.  Aborting."; exit 99; }

RenumberListArr () {
# This is called after inserting or deleting records.
# Record numbers may not be sequential because user can sort on any column
# Record nubmers must be unique as they are used to find the correct record in ListArr array.
# Matching on "file name" or any other field is impossible because there may be duplicate names.

# Define variables for easy reading and fewer code line changes when expanding
RecArrCnt=5
ListArrCnt=${#ListArr[@]}

i=1 # First element (0) is "false", followed by record number element (1)
j=1 # Record numbers start at 1

while [ $i -lt $ListArrCnt ] ; do
    ListArr[$i]=$j
    j=$(($j + 1))
    i=$(($i + $RecArrCnt))
# echo "Renumber i: $i j: $j"
done

}

OLDIFS="$IFS"
IFS="|"
ListArr=()

# TODO: Replace this section with IFS=' ' read -ra CfgArr < /home/$USER/bin/.websync

while IFS=";" read -r select stt name dueDay status; do
      ListArr+=( "$select" "$stt" "$name" "$dueDay"  "$status" )
done < <(sort -t'|' -k2 data.txt)

TransCount=0 # Number of Inserts, Edits and Deletes

# Read Only Status column: Recalc, Different, Matches, Bad File, No Address, Bad Address
# Debugging: --hide-column=2 hides Read Only record number column for normal operation

while true ; do

# adjust width & height below for your screen 900x600 default for 1920x1080 HD screen
# also adjust font="14" below if blue title text is too small or too large
Record=(`yad \
    --title "Planner Application" --list \
        --text '<span foreground="blue" font="14"> \
        Click column heading to sort.\
        Select record before clicking: Insert / Delete</span>' \
        --width=900 --height=600 --center --radiolist -separator="$IFS" \
        --button="Insert before":10 --button="Delete":30 \
        --button="Exit":50 --button="Save":60 --search-column=3 \
        --column "Select" --column "ID" --column "Name" \
        --column "Due day" --column "Description" \
        "${ListArr[@]}"`)
Action=$?

RecSelected=false
RecArr=()
i=0

# Button values 1 and 3 don't work for returning selected record for some reason???
# Button values 11, 13 and 15 don't work either. 12, 14 and 16 work. 
# Therefore use Button values (10, 20, 30...) for readability.
for Field in "${Record[@]}" ; do
    RecSelected=true
    RecArr[i++]=$Field
done

# Define variables for easy reading and fewer code line changes when expanding
RecArrCnt=5
ListArrCnt=${#ListArr[@]}

# Error checking
if [[ $Action == 10 ]] || [[ $Action == 20 ]] || [[ $Action == 30 ]] ; then
    if [[ $RecSelected == false ]] ; then
    zenity --error --text 'You must select a record before clicking: Insert / Edit / Delete.'
    continue
    fi
fi

# Insert before || or Edit ?
if [[ $Action == 10 ]]; then

    # --text="Set fields and click OK to update" 
    # Note if there is a space at end of line, next line generates invalid command error from yad
    NewRecArr=(`yad --width=900 --height=300 --title="Insert a task" \
        --form --center \
        --field="Name" \
        --field="Description" \
        ${RecArr[2]} ${RecArr[4]}`)
    ret=$?

    # Cancel =252, OK = 0
    # OK & Insert operation?
    if [[ $ret == 0 ]] && [[ $Action == 10 ]]; then
        # Create new list entry and renumber
    ((TransCount++)) # Update number of changes
        let i=1      # Base 0 array, record number is second field
        

    IncomingTime=$(zenity --forms --title="Add Time" \
	--separator=":" \
	--add-entry="Hour" \
	--add-entry="Minute" \
	--add-entry="Second" \ )

    IncomingDate=$(zenity --forms --title="Add Date" \
	--separator=":" \
	--add-calendar="Date" \ )

    Incoming="$IncomingDate $IncomingTime"
    name="${NewRecArr[0]}"
    export Incoming
    export name
    export 
  ./notify.sh &
  echo "The message is: $Incoming"
    while [ $i -lt $ListArrCnt ] ; do
        if [ ${ListArr[$i]} -eq ${RecArr[1]} ]; then
        # We have matching record number to insert before
            NewArr+=( false )
            NewArr+=( "${ListArr[$i]}" )
            NewArr+=( "${NewRecArr[0]}" )
            NewArr+=( "${Incoming}" )
            NewArr+=( "${NewRecArr[1]}" )
        fi
        let j=$(( $i-1 ))
        let k=$(( $j+$RecArrCnt ))
        while [ $j -lt $k ] ; do
            NewArr+=( "${ListArr[$j]}" )
        j=$(($j + 1))
        done
        let i=$(($i + $RecArrCnt)) # Next list array entry to copy
    done
    ListArr=("${NewArr[@]}")
    unset NewArr
    RenumberListArr

    # OK & Edit operation?
    elif [[ $ret == 0 ]] && [[ $Action == 20 ]]; then
        # Update array entry
    ((TransCount++))
        let i=1
    while [ $i -lt $ListArrCnt ] ; do
        if [ ${ListArr[$i]} -eq ${RecArr[1]} ]; then
        # We have matching record number
        ListArr[++i]="${NewRecArr[0]}"
        ListArr[++i]="${NewRecArr[1]}"
        ListArr[++i]="${NewRecArr[2]}"
        let i=$(($ListArrCnt + 1)) # force exit from while loop
        else
        let i=$(($i + $RecArrCnt)) # Check next entry
        fi
    done
    fi

# Delete record?
elif [[ $Action == 30 ]] ; then
    # --text="click OK to confirm delete" 
    # Note if there is a space at end of a script line, the next line generates 
    # "invalid command error from yad
    yad --width=900 --height=300 --title="Do you really want to delete this record?" \
        --text '<span foreground="blue" font="14">Click OK to confirm delete.</span>' \
        --form --center \
        --field="Name":RO --field="Due day":RO \
        --field="Description":RO \
        ${RecArr[2]} ${RecArr[3]} ${RecArr[4]}
    ret=$?

    # Cancel =252, OK = 0
    if [[ $ret == 0 ]] ; then
        # Delete record from list array and renumber
    ((TransCount++))
        let i=1
    while [ $i -lt $ListArrCnt ] ; do
        if [ ${ListArr[$i]} -eq ${RecArr[1]} ]; then
        # We have matching record number
        j=$(($i - 1))
        k=$(($j + $RecArrCnt))
        while [ $j -lt $k ] ; do
            unset 'ListArr[$j]'
            j=$(($j + 1))
        done
        for i in "${!ListArr[@]}"; do
                NewArr+=( "${ListArr[$i]}" )
        done
        ListArr=("${NewArr[@]}")
        unset NewArr
        let i=$(($ListArrCnt + 1)) # force exit from while loop
        else
        let i=$(($i + $RecArrCnt)) # Check next entry
        fi
    done
    RenumberListArr
    else
        continue # cancel changes.
    fi

# Run update process?
elif [[ $Action == 40 ]] ; then
    continue # TODO: Run

# Cancel all changes?
elif [[ $Action == 50 ]] || [[ $Action == 252 ]] ; then
    # Cancel ALL || or X the window or Escape
    if [[ $TransCount -gt 0 ]] ; then
    zenity --question --text "You have made $TransCount change(s). Do you really want to cancel?"
    rc=$? 
    if [[ $rc -eq 0 ]] ; then
        exit
    fi
    else
    exit
    fi

# Save changes?
elif [[ $Action == 60 ]] ; then
    # Remove file
    rm -f ~/APIDocumatation/ProjectLInux/Linux/data.txt
    touch ~/APIDocumatation/ProjectLInux/Linux/data.txt
    #Save
    item=""
    n=1
    for i in ${ListArr[@]}
    do
    	item+="$i;"
    	n=$((n+1))
    	if [[ $n > 5 ]];
    	then
    		echo $item >> ~/APIDocumatation/ProjectLInux/Linux/data.txt
    		n=1
    		item=""
    	fi
    done
    exit
else
    zenity --error --text "~/bin/websync - Unknown button return code: $Action"
    exit
fi

done # End of while loop

IFS="$OLDIFS"

exit

