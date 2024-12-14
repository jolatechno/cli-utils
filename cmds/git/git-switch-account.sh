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

Used to switch (and manage) between multiple saved git account.


Usage: \"git-switch-account\"
	-h help

	-n acount number (default 0 = globaly set account)
	-s set account (will not change the local git account)
	-d delete the acount
"
}

account_num=0
set=false
delete=false

while getopts 'hn:sd' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	n) account_num="${OPTARG}";;
	s) set=true;;
	d) delete=true;;
	*) print_usage;
		exit 1 ;;
	esac
done

if [ "${set}" = true ] && [ "${delete}" = true ]; then
	>&2  echo "ERROR:   can't set and delete account at the same time"
	exit 1
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

account="user"
if [ "${account_num}" != 0 ]; then
	account="${account}${account_num}"
fi

if [ "${set}" = true ]; then
	if [ "${account_num}" = 0 ]; then
		>&2 echo "Can't set the 0th git account as it is the default git profile"
		>&2 echo ""
		>&2 echo "Modify using normal git commands:"
		>&2 echo ""
		>&2 echo "   git config --global user.name  \"name\""
		>&2 echo "   git config --global user.email \"email\""
		exit 1
	fi

	read -p 'Enter git username: ' name
	if [ ! -z "${name}" ]; then
		git config --global ${account}.name "${name}"
	else
		>&2 echo "Did not read any name, skipping"
	fi

	read -p 'Enter git email: ' email
	if [ ! -z "${email}" ]; then
		git config --global ${account}.email "${email}"
	else
		>&2 echo "Did not read any email, skipping"
	fi
elif [ "${delete}" = true ]; then
	if [ "${account_num}" = 0 ]; then
		>&2 echo "Can't delete the 0th git account as it is the default git profile"
		exit 1
	fi

	read -p "Are you sure you want to delete the ${account_num}th git profile ? [Y|n] " prompt
	if [[ "${prompt}" == "Y" ]]; then
		git config --global --unset ${account}.name
		git config --global --unset ${account}.email
	fi
else
	name=$(git config --list --global | grep "${account}.name" | head -n 1 |  sed -n -e 's/^.*=//p')
	if [ ! -z "${name}" ]; then
		git config --local user.name "${name}"
	else
		>&2 echo "Did not read any name in \"${account}.name\", skipping"
	fi

	email=$(git config --list --global | grep "${account}.email" | head -n 1 |  sed -n -e 's/^.*=//p')
	if [ ! -z "${email}" ]; then
		git config --local user.email "${email}"
	else
		>&2 echo "Did not read any email in \"${account}.email\", skipping"
	fi
fi