#!/bin/bash

#Printersettings
printer=ghost
papersize=a4


#Declaration of Variables
toprint=()
printoptions=()
printnumber=()
mode=
pmode=
testmode=
twopages=

#argument handling

while getopts ctdx opt
do
   case $opt in
	t) twopages=1 ;;
	x) pmode=test ;;
	c) mode=all ;;
	d) delete=1 ;;
   esac
done

mode=${mode:=interactive}
pmode=${pmode:-$mode}
delete=${delete:=0}

#get files to print
while read Line; do
#	echo $Line
	case $mode in
	interactive)
		read -r -p "Are you sure to print $Line? [Y/n]" response </dev/tty
	 	response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
	 	if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    			toprint=(${toprint[@]} $Line);

			#options		
			printoptions=(${printoptions[@]} media=$papersize,fit-to-page)
	
			read -r -p "Do you want to print both sides? [Y/n]" response </dev/tty
		 	response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
		 	if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    				printoptions=(${printoptions[@]},sides=two-sides-long-edge)
		 	else
				printoptions=(${printoptions[@]},sides=one-side)
			fi;
			read -r -p "Do you want two document pages on one page? [y/N]" response </dev/tty
	 		response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
	 		if [[ $response =~ ^(no|n| ) ]] || [[ -z $response ]]; then
 				printoptions=(${printoptions[@]})
			else
  				printoptions=(${printoptions[@]},number-up=2,number-up-layout="tblr")
	 		fi;
			read -r -p "How many copies? [1]" response </dev/tty
			if ! [[ "$response" =~ ^[1-9]+$ ]]; then
				printoptions=(${printoptions[@]},collate=true)
 				printnumber=(${printnumber[@]} 1)		
			else
				printoptions=(${printoptions[@]},collate=true)
 				printnumber=(${printnumber[@]} $response)
	 		fi;
		printf "\n"
		fi;
		;;
	all)
		toprint=(${toprint[@]} $Line)
		printoptions=(${printoptions[@]} media=$papersize,fit-to-page,collate=true)
		if [ "$twopages" == 1 ];then
			printoptions=(${printoptions[@]},sides=two-sides-long-edge)
		else
			printoptions=(${printoptions[@]},sides=one-side)

		fi;
		printnumber=(${printnumber[@]} 1)
		;;
	esac
done < <(ls *.pdf)

#check files to print
if [ $mode == interactive ]; then
	printf "\nSelected files to print:\n"
	for file in ${toprint[@]}
	do
		printf "\t%s\n" "$file"
	done
	read -r -p "Are you sure? [Y/n]" response </dev/tty
	response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
	if  [[ $response =~ ^(no|n) ]] ; then
		exit 0
	fi
	read -r -p "Should the files be deleted after printing? [y/N]" response </dev/tty
	response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # tolower
	if [[ $response =~ ^(yes|y) ]]; then
		delete=1
	else
		delete=0
	fi
fi

#print
case $pmode in
	interactive)
		for i in "${!toprint[@]}"
		do
			lpr -P "$printer" -# "${printnumber[$i]}"  -o "${printeroptions[$i]}" "${toprint[$i]}"

			if [ $delete == 1 ]; then
				rm ${toprint[$i]}
			else 
				mv ${toprint[$i]} done/
			fi
		done
		;;
	all)
		for i in "${!toprint[@]}"
		do
			lpr -P "$printer" -# "${printnumber[$i]}" -o "${printeroptions[$i]}" "${toprint[$i]}"
	
			if [ $delete == 1 ]; then
				rm ${toprint[$i]}
			else 
				mv ${toprint[$i]} done/
			fi
		done
		;;
	test)
		printf "\n\nPrinttest:\tFiles to print:\tNumber:\tOptions:\n"
		for i in "${!toprint[@]}"
		do
			printf "\t\t%s\t%d\t%s\n" "${toprint[$i]}" "${printnumber[$i]}" "${printoptions[$i]}"
		done
		printf "Delete: %s\n" "$delete"
esac

exit 0
