#!/bin/bash

#########################################
#   Filename: pre-commit.sh             #
#   Nedko Stefanov Nedkov               #
#   nedko.stefanov.nedkov@gmail.com     #
#   April 2014		                #
#########################################

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

declare -a FLAGS=(
1 # (1) show options
0 # (2) delete trailing whitespaces from modified files
0 # (3) run pychecker on modified files
0 # (4) run tests

### WHEN ADDING NEW FUNCTIONALITY TOUCH HERE ###
)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#

declare -A colors
colors["red"]="\e[0;31m"
colors["blue"]="\e[00;36m"
colors["dark_green"]="\e[00;32m"
colors["yellow"]="\e[01;33m"

function print() {
	if (( $# == 2 )); then
		echo -e "${colors[$1]}$2\e[00m"
	else
		echo -e $1
	fi
}


if (( $# > 0 )); then
	declare -a FLAGS=(0 0 0 0) ### WHEN ADDING NEW FUNCTIONALITY TOUCH HERE ###
	for arg do
   		case $arg in
    		1)   ((FLAGS[0]=1));;
    		2)   ((FLAGS[1]=1));;
   		3)   ((FLAGS[2]=1));;
		4)   ((FLAGS[3]=1));;

	        ### WHEN ADDING NEW FUNCTIONALITY TOUCH HERE ###
   		esac
	done
fi

######################################################################################################
# show options

function show_options() {
	print "blue" "\n*** Showing options ***"
	print "(1) show options\n"
	print "(2) delete trailing whitespaces from modified files\n"
	print "(3) run pychecker on modified files\n"
	print "(4) run tests\n"

	### WHEN ADDING NEW FUNCTIONALITY TOUCH HERE ###
}

######################################################################################################
# delete trailing whitespaces from modified files

function delete_trail_whitespaces_modified_files() {
	print "blue" "\n*** Deleting trailing whitespaces from modified files ***"
	FILES=(`git status | awk '$1 == "modified:" { print head$2 }'`)
	for file in ${FILES[@]}; do
		print "dark_green" "Deleting trailing whitespaces from file: $file"
		sed -i '' -e's/[ \t]*$//' $file >& /dev/null
	done
	echo
}

######################################################################################################
# run pychecker on modified files

function pycheck_modified_files() {
	print "blue" "\n*** Running pychecker on modified files ***"
	FILES=(`git status | awk '$1 == "modified:" { print head$2 }' | grep .py`)
	for file in ${FILES[@]}; do
		print "dark_green" "\nPychecking file: $file\n"
		pychecker $file
	done
	echo
}

######################################################################################################
# run tests

function run_tests() {
	CLUSTER_FILES=("req_arr":"req_arr_214_0x0001_0x0001"
		       "req_miss":"req_miss_214_0x0001_0x0001"
		       "res_miss":"res_miss_214_0x0001_0x0001"
		       "res_arr":"res_arr_214_0x0001_0x0001")
	print "blue" "\n*** Running tests ***"
	for file in ${CLUSTER_FILES[@]}; do
		key="${file%%:*}"
		value="${file##*:}"
		print "dark_green" "\n$key (internal) cluster for (214, 0x0001, 0x0001):"
		diff "clustering_results/214/content_214_0x0001_0x0001/for_tests/internal_view/$value.txt" "/home/nedko/Inria/test/$value.txt" >/dev/null
		if (( $? == 1 )); then
			print "red" "Not correct"
			mkdir "logs" 2> /dev/null
			diff "clustering_results/content_214_0x0001_0x0001/for_tests/internal_view/$value.txt" "/home/nedko/Inria/test/$value.txt" > "logs/$value.diff"
		else
			echo "Correct"
		fi
	done
	echo
	CONTENT_DIRS=(`ls -d -1 ./clustering_results/**`)
	for content_dir in ${CONTENT_DIRS[@]}; do
		print "dark_green" "\nRunning tests on: $content_dir"
		python tester.py $content_dir
	done
	echo
}

######################################################################################################

if (( FLAGS[0] == 1 )); then
	show_options
fi

if (( FLAGS[1] == 1 )); then
	delete_trail_whitespaces_modified_files
fi

if (( FLAGS[2] == 1 )); then
	pycheck_modified_files
fi

if (( FLAGS[3] == 1 )); then
	run_tests
fi

### WHEN ADDING NEW FUNCTIONALITY TOUCH HERE ###

