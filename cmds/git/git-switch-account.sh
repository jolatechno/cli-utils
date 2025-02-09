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

	-l list all acounts

	-n acount number (default 0 = globaly set account)
	-s set account (will not change the local git account)
	-d delete the acount
	-k set a ssh key to use (host set in ~/.ssh/config)


If you want to use this last option
you need to setup an account in the ~/.ssh/config file
as shown in https://gist.github.com/alejandro-martin/aabe88cf15871121e076f66b65306610

You thus should have a entry in your ~/.ssh/config file looking like :
  Host hostname
  HostName host_url                        (github.com for example)
  IdentityFile ~/.ssh/IdentityFileName
"
}

account_num=0
list=false
set=false
delete=false
set_host=false

while getopts 'hn:sdlk' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	n) account_num="${OPTARG}";;
	s) set=true;;
	d) delete=true;;
	l) list=true;;
	k) set_host=true;;
	*) print_usage;
		exit 1 ;;
	esac
done

if [ "${set}" = true ]; then
	if [ "${delete}" = true ]; then
		>&2  echo "ERROR:   can't set and delete account at the same time"
		exit 1
	fi
	if [ "${list}" = true ]; then
		>&2  echo "ERROR:   can't set and list account at the same time"
		exit 1
	fi
fi
if [ "${delete}" = true ] && [ "${list}" = true ]; then
	>&2  echo "ERROR:   can't delete and list account at the same time"
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

	if [ "${set_host}" = true ]; then
		echo ""
		echo "You have chosen to set a host for this account,"
		echo "you thus need to setup an account in the ~/.ssh/config file"
		echo "as shown in https://gist.github.com/alejandro-martin/aabe88cf15871121e076f66b65306610"
		echo ""
		echo "You thus should have a entry in your ~/.ssh/config file looking like :"
		echo "  Host hostname"
		echo "  HostName host_url                        (github.com for example)"
		echo "  IdentityFile ~/.ssh/IdentityFileName"
		echo ""

		read -p 'Enter your hostname: ' hostname
		if [ ! -z "${hostname}" ]; then
			git config --global ${account}.host "${hostname}"
		else
			>&2 echo "Did not read any hostname, skipping"
		fi
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
elif [ "${list}" = true ]; then
	account_num=0
	while true; do
		account="user"
		if [ "${account_num}" != 0 ]; then
			account="${account}${account_num}"
		fi

		name=$(git config --list --global | grep "${account}.name" | head -n 1 |  sed -n -e 's/^.*=//p')
		email=$(git config --list --global | grep "${account}.email" | head -n 1 |  sed -n -e 's/^.*=//p')
		host=$(git config --list --global | grep "${account}.host" | head -n 1 |  sed -n -e 's/^.*=//p')
		if [ -z "${name}" ] && [ -z "${email}" ]; then
			exit 0
		fi

		if [ "${account_num}" != 0 ]; then
			echo ""
		fi
		echo "Profile \"${account}\" :"
		if [ ! -z "${name}" ]; then
			echo "   user.name  \"${name}\""
		fi
		if [ ! -z "${email}" ]; then
			echo "   user.email \"${email}\""
		fi
		if [ ! -z "${host}" ]; then
			echo "   user.host \"${host}\""
		fi

		account_num=$((${account_num} + 1))
	done
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

	host=$(git config --list --global | grep "${account}.host" | head -n 1 |  sed -n -e 's/^.*=//p')
	if [ ! -z "${host}" ]; then
		USER_REPO=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*:([^[:space:]]*).*#\1#p'`
		if [ -z "$USER_REPO" ]; then
			>&2 echo "ERROR:    Could not identify Repo url."
			>&2 echo "Coud not set hostname, skipping"
			exit 1
		fi

		USER=`echo $USER_REPO | sed -Ene's#([^/]*)/(.*).git#\1#p'`
		if [ -z "$USER" ]; then
			>&2 echo "ERROR:    Could not identify User."
			>&2 echo "Coud not set hostname, skipping"
			exit 1
		fi

		REPO=`echo $USER_REPO | sed -Ene's#([^/]*)/(.*).git#\2#p'`
		if [ -z "$REPO" ]; then
			>&2 echo "ERROR:    Could not identify Repo."
			>&2 echo "Coud not set hostname, skipping"
			exit 1
		fi

		NEW_URL="git@${host}:${USER}/${REPO}.git"
		echo "Changing repo url to $NEW_URL"

		git remote set-url origin $NEW_URL
	else
		>&2 echo "Did not read any host in \"${account}.host\""
	fi
fi