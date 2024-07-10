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
Usage: \"sudo smbadd -n share_name -f share_path -u share_allowed_user\"
	-h help

	-n share name (mendatory)
	-f share path (mendatory)
	-u allowed user (if not specified will be $(whoami))
"
}

user="$(whoami)"
name=""
path=""


while getopts 'n:f:uh' flag; do
	case "${flag}" in
		h) print_usage;
			exit 1;;
		n) name="${OPTARG}";;
		f) path="${OPTARG}";;
		u) user="${OPTARG}";;
		*) print_usage;
			 exit 1 ;;
	esac
done

if [ "$(id -un)" != "root" ]; then
		echo "root privilege needed..."
		exit 1
fi

old_IFS=$IFS; IFS=$'\n'

param="
\0
[$name]
	 path = $path
	 read only = no
	 browseable = yes
	 hide dot files = yes
	 guest ok = no
	 valid user = $user
	 public = no
	 create mode = 0777
	 directory mode = 0777
	 read raw = yes
	 write raw = yes
	 socket option = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
	 min receivefile size = 16384
	 use sendfile = true
	 aio read size = 16384
	 aio write size = 16384
	 getwd cache = true
	 write cache size = 2097152
\0
"

for line in $param; do
	echo -e "adding \""$line"\""
	echo -e $line >> /etc/samba/smb.conf
done

IFS=$old_IFS

service smbd restart
