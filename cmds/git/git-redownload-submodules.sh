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

Redownload all submodules from scratch (WARNING : will loose untracked files)

WARNING: Is very likely to lead to loss of untracked files, please backup before use.


Usage: \"git-redownload-submodules\"
	-h help

	-r redownload recursively
	-s skip deleting (only \"submodule add\" submodules)
	-Y redownload all submodules without asking, !! DANGEROUS !!
"
}

ask=true
recursive=false
skip_delete=false
verbose=false

while getopts 'hvrsY' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	v) verbose=true;;
	r) recursive=true;;
	s) skip_delete=true;;
	Y) ask=false;;
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

git_root=$(git rev-parse --show-toplevel)

redownload() {
	readarray -t submodules <<< $(git-list-submodules -pu)

	IFS=$'\n'
	for i in `seq 0 $(( ${#submodules[@]} - 1 ))`; do
		readarray -d ' ' -t path_url <<< "${submodules[$i]}"
		path=${path_url[0]}
		url=${path_url[1]}
		url=${url%$'\n'}

		if [ -z "${path}" ] || [ -z "${url}" ]; then
			continue
		fi

		prompt="Y"
		if [ "${ask}" = true ]; then
			read -p "Redownload \"${url}\" to \"${path}\" ? [Y|n] " prompt
		fi

		if [[ "${prompt}" == "Y" ]]; then
			if [ -d ${path} ]; then
				if [ "${skip_delete}" = false ]; then
					rm -r ${path}
				fi
			else
				dir=$(dirname ${path})
				if [ ! -d "${dir}" ]; then
					mkdir -p ${dir}
				fi
			fi
			if [ "${skip_delete}" = false ]; then
				git rm --cached -r ${path}
			fi

			git submodule add -f ${url} ${path}

			if [ "${verbose}" = true ]; then
				echo "redownloaded \"${url}\" at path \"${path}\""
			fi

			if [ "${recursive}" = true ]; then
				(cd ${path} && redownload)
			fi
		fi
	done
}

(cd ${git_root} && redownload)