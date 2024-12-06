#!/bin/bash
# Created by : Ian Seymour
# Date : 12/5/24
# File Name : SpellCheck.sh 

# Description : This script takes in a text file, a dictionary file (a text file containing a large list of words), and an integer
# provided by user to determine the number of most common typos to display. Punctuation, quotes, and numerals will be ignored. All
# words in the provided text file will be compared to the words in the dictionary file, and if the words are not in the dictionary,
# then they will be considered a typo. Single apostrophes are not used as delimiters since they could be a part of contractions.
# More complex grammar mistakes will not be considered.

# How to call this script :
# bash SpellCheck.sh [textfile] [dictionaryfile] [num of errors to display]
# For example : bash SpellCheck.sh test.txt dictionary.txt 5

# Dictionary files can sometimes be found included with some Linux distros, otherwise they can be downloaded. The one used to test
# this script was found here : https://gist.github.com/WChargin/8927565

# Parameters: $1 = text file to be parsed, $2 = dictionary file to search, $3 = number n for how many common typos to be returned.

# ensure text file is valid:
if [ -f $1 ]
then 
	echo "Valid text file."
else
	echo "ERROR: Invalid text file."
	exit
fi

# ensure dictionary is valid:
if [ -f $2 ]
then 
	echo "Valid dictionary."
else
	echo "ERROR: Invalid dictionary file."
	exit
fi

# add new line for readability:
echo -e "\n"

# append . ? , ! " ; to IFS so words can be split if punctuation or quotes used:
IFS=$IFS\".?,!;
# declare array to hold tokenized words
declare -a wordarray
# create temp file to hold typo'd words:
touch typo.txt
# create file descriptor for read command
exec {file}<"./$1"

# read file and split all words into array:
read -a wordarray -u $file

# close file descriptor
exec {file}>&-

# iterate through array, converting all words to lowercase to make final sort function as intended:
for word in ${wordarray[@],,} ;
do 
	# use grep to search dictionary for each word in array, if the line count returned is 0, then
	# the word is not in the dictionary, the count will be stored in match variable.
	match=`grep -icw $word $2`
	
	# isnum variable to store whether or not $word is a numeral, since a numeral on its own is
	# not necessarily a typo, just potentially bad practice if used for numbers nine or less:
	isnum=0
	
	# check if $word is a numeral, if it is, set isnum to 1:
	if [[ $word =~ ^[0-9]+$ ]] ;
	then
		isnum=1
	fi
	
	# if match variable is 0, and $word is not a numeral, then append word to typo.txt
	if [[ $match == 0 && $isnum == 0 ]] ;
	then
		echo $word >> typo.txt
	fi
done

# count typo occurrences and sort by reverse numerical order and transfer to 2nd temp file:
sort typo.txt | uniq -c | sort -nr > errorcount.txt

# remove typo.txt as it is no longer needed:
rm typo.txt

# display the n most frequent errors, with n passed as $3 param
echo "---$3 MOST COMMON TYPOS---"
echo "frequency | typo"
head -n $3 errorcount.txt

# remove errorcount.txt
rm errorcount.txt

# restore IFS to standard:
IFS=" \t\n"
