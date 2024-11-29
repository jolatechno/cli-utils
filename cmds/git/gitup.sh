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

Equivalent to \"git add . ; git commit -am 'update' ; git push -f origin 'branch'\"

If \"stagecommit.maxfilesize\" is set in git config, will fallback to
\"git-stage-commit\" to respect this set limit.


Usage: \"gitup\"
	-h help
	-v verbose

	-m commit name, default is 'update'
	-b set branch name, default is whatever beanch you are on
	-A remove the '-a' flag (don't add un-added files)
"
}

add_files=true
commit_name=update
branch=None
verbose=false
stage_commit_args=

while getopts 'hm:Ab:v' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	A) add_files=false ;;
	m) commit_name="${OPTARG}";;
	b) branch="${OPTARG}";;
	v) verbose=true;
	   stage_commit_args+=-v;;
	*) print_usage;
		exit 1 ;;
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
			echo "Installing command not found, try to install yourself."
			exit 1
		fi
	else
		exit 0
	fi
fi

if [ "${branch}" = None ]; then
	branch=$(git rev-parse --abbrev-ref HEAD)
fi

max_file_size=$(git config --list --local | grep stagecommit.maxfilesize | head -n 1 | sed -n -e 's/^.*=//p')
if ! [ -z "${max_file_size}" ]; then
	echo -e "git config \"stagecommit.maxfilesize\" is set (to ${max_file_size}), will now fallback to \"git-stage-commit\" to follow this config.\nTo force single commit, use \"git-stage-commit -s -1\", or unset \"stagecommit.maxfilesize\"\n"
	git-stage-commit -m ${commit_name} -b ${branch} -s ${max_file_size} ${stage_commit_args}
else
	if [ "${add_files}" = true ]; then
	   git add .
	fi
	git commit -am "${commit_name}"
	git push -f origin ${branch}
fi