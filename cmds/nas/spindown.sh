#!/bin/bash

License="MIT License

Copyright (c) 2020 joseph touzet

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"

print_usage() {
	printf "$License

Updates the commands installed from \"https://github.com/jolatechno/cli-utils.git\"

Adds a spindown timer to a hard drive.


Usage: \"sudo spindown -d drive_device_name -t time\"
	-h help

	-t spin down time (default is 25, see hdparm for more info)
	-d drive name (default is \"sda\")
"
}

drive="sda"
time=25

while getopts 't:d:h' flag; do
	case "${flag}" in
		h) print_usage;
			exit 1;;
		t) time="${OPTARG}";;
		d) drive="${OPTARG}";;
		*) print_usage;
			 exit 1 ;;
	esac
done

if [ "$EUID" -ne 0 ]; then
	>&2 echo "root privilege needed..."
	exit
fi

if ! command -v hdparm &> /dev/null; then
	read -p "hdparm not found, install ? [Y|n] " prompt
	if [[ $prompt == "Y" ]]; then
		if command -v pacman &> /dev/null; then
			sudo pacman -Sy hdparm
		elif command -v apt-get &> /dev/null; then
			sudo apt-get install hdparm
		else
			>&2 echo "Installing command not found, try to install yourself."
			exit 1
		fi
	else
		exit 0
	fi
fi

param="\n
command_line {\n
			 hdparm -S $time /dev/$drive\n
}\n"

echo -e $param >> /etc/hdparm.conf
hdparm -S $time /dev/$drive
