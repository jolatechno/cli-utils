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

List all submodules in the current repo.


Usage: \"git-list-submodules\"
	-h help

	-r recursivly list submodules (thus list submodules of submodules)
	-p print path
	-u print url
"
}

recursive=false
path=false
url=false

while getopts 'hpur' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	r) recursive=true;;
	p) path=true;;
	u) url=true;;
	esac
done

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

if [ "${path}" = false ] && [ "${url}" = false ]; then
	>&2 echo "WARNING:   Nothing to do"
fi

git_root=$(git rev-parse --show-toplevel)

list_submodules() {
	root_path="$1"

	submodule_size=0
	if [ "${path}" = true ]; then
		readarray -t path_list <<< $(git config --file ".gitmodules" --get-regexp path | awk '{ print $2 }')
		if [ ! -z "${path_list}" ]; then
			submodule_size=${#path_list[@]}
		fi
	fi
	if [ "${url}" = true ]; then
		readarray -t urls <<< $(git config --file ".gitmodules" --get-regexp url | awk '{ print $2 }')
		if [ ! -z "${urls}" ]; then
			submodule_size=${#urls[@]}
		fi
	fi

	for i in `seq 0 $(( ${submodule_size} - 1 ))`; do
		if [ "${path}" = true ]; then
			if [ "${url}" = true ]; then
				echo "${root_path}${path_list[$i]} ${urls[$i]}"
			else
				echo "${root_path}${path_list[$i]}"
			fi
		else
			echo "${urls[$i]}"
		fi
	done

	if [ "${recursive}" = true ] && [ ! "${submodule_size}" = 0 ]; then
		for submodule_path in $(git config --file ".gitmodules" --get-regexp path | awk '{ print $2 }'); do
			(cd ./${submodule_path} && list_submodules "${root_path}${submodule_path}/")
		done
	fi
}

(cd ${git_root} && list_submodules "")