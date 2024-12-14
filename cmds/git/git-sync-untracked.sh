#!/bin/bash

License="MIT License

Copyright (c) 2024 joseph touzet

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

Copy untracked files from one repo (the \"source\" repo) to another similar repo (which you should be at the root of). This can be used to restore backup after clowning a repo.


Usage: \"git-sync-untracked\"
	-h help

	-s [mandatory] source repository
	-r recursive (relative to submodules)
	-y copy without asking for confirmation
"
}

recursive=
ask=true
source=

while getopts 'hrys:' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	r) recursive="-r";;
	s) source="${OPTARG}";;
	y) ask=false;;
	*) print_usage;
		exit 1 ;;
	esac
done

if [ -z ${source} ]; then
	>&2 echo "ERROR:    No source repository provided."
	exit
fi

if ! command -v git &> /dev/null; then
	read -p "git not found, install ? [Y|n] " prompt
	if [[ $prompt == "Y" ]]; then
		if command -v pacman &> /dev/null; then
			sudo pacman -Sy git
		elif command -v apt-get &> /dev/null; then
			sudo apt-get install git
		else
			>&2 echo "Installing command not found, try to install yourself."
			exit 1
		fi
	else
		exit 0
	fi
fi

untracked_files=$(cd source && git-list-untracked ${recursive})
# TODO