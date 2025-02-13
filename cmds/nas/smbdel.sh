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

Deletes a samba share.


Usage: \"sudo smbdel share_name1 share_name2 ...\"
	-h help
"
}

while getopts 'h' flag; do
	case "${flag}" in
		h) print_usage;
			exit 1;;
		*) print_usage;
			exit 1 ;;
	esac
done

if [ "$(id -un)" != "root" ]; then
	>&2 echo "root privilege needed..."
	exit 1
fi

old_IFS=$IFS; IFS=$'\n'

for name in $*; do
	del=0
	file=$(cat /etc/samba/smb.conf)

	echo "" > /etc/samba/smb.conf

	for line in $file; do
		if [[ $del == 1 ]]; then
			if [[ $line = '   '* ]]; then
				echo "deleting \"$line\""
			else
				del=0
				echo $line >> /etc/samba/smb.conf
			fi
		else
			if [ $line == "[$name]" ]; then
				echo "deleting \"$line\""
				del=1
			else
				echo $line >> /etc/samba/smb.conf
			fi
		fi
	done
done

IFS=$old_IFS

service smbd restart
