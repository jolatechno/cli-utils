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

WARNING: Only tested with Github

Delete all comit history from the main branch of a repo.


Usage: \"gcrypt-set-repo\"
	-h help

	-u this flag to change remote url
	-k this flag to set gpg key
	-v this flag to set git environment variables
	-p this flag to pull after the changes (if you pulled the directory as a normal, unencrypted directory)
	-b sets the branch for the \"git pull\" called by the flag \"-p\" (default: \"main\") 
"
}

set_url=false
set_gpg_key=false
set_variables=false
pull=false
branch="main"

while getopts 'hukvpb' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	u) set_url=true;;
	k) set_gpg_key=true;;
	v) set_variables=true;;
	p) pull=true;;
	b) branch="${OPTARG}";;
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
			>&2 echo "Installing command not found, try to install yourself."
			exit 1
		fi
	else
		exit 0
	fi
fi

echo "WARNING: Only tested with github (for now)"
read -p "Are you sure you want to continue? [Y|n] " prompt
if [[ $prompt == "Y" ]]; then
	if [ "${set_url}" = true ]; then
		continue_=true

		REPO_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*https://([^[:space:]]*).*#\1#p'`
		if [ -z "$REPO_URL" ]; then
			REPO_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*git@([^[:space:]]*).*#\1#p'`
			if [ -z "$REPO_URL" ]; then
				>&2 echo "ERROR:    Could not identify Repo url. Not changing the URL."
				>&2 echo "It is possible this repo URL is already setup for gcrypt. "
				continue_=false
			fi
		fi

		if [ "${continue_}" = true ]; then
		echo "arzeez"
			GIT_PROVIER=`echo $REPO_URL | sed -Ene's#([^\:]*)[:/][^/]*/(.*).git#\1#p'`
			if [ -z "$GIT_PROVIER" ]; then
				>&2 echo "ERROR:    Could not identify git provider. Not changing the URL."
			else

				USER=`echo $REPO_URL | sed -Ene's#[^\:]*[:/]([^/]*)/(.*).git#\1#p'`
				if [ -z "$USER" ]; then
					>&2 echo "ERROR:    Could not identify User. Not changing the URL."
				else

					REPO=`echo $REPO_URL | sed -Ene's#[^\:]*[:/]([^/]*)/(.*).git#\2#p'`
					if [ -z "$REPO" ]; then
						>&2 echo "ERROR:    Could not identify Repo. Not changing the URL."
					else

						NEW_URL="gcrypt::git@${GIT_PROVIER}:${USER}/${REPO}"
						echo "Changing repo url from "
						echo "'$REPO_URL'"
						echo "        to "
						echo "'$NEW_URL'"

						git remote set-url origin $NEW_URL
					fi
				fi
			fi
		fi
	fi

	if [ "${set_gpg_key}" = true ]; then
		key_fingerprint=$(gpg-choose-key)
		if [ -z "${key_fingerprint}" ]; then
			>&2 echo "Key not found !"
		else
			git config remote.origin.gcrypt-participants "${key_fingerprint}" && \
			git config --local user.signingkey "${key_fingerprint}"
		fi
	fi

	if [ "${set_variables}" = true ]; then
		git config --local gc.auto 0
		git config --local gc.autoPackLimit 0

		read -p 'Max commit size [Mb] (recommanded: 25-75): ' max_file_size

		git config --local stagecommit.maxfilesize ${max_file_size}
	fi

	if [ "${pull}" = true ]; then
		git pull origin "${branch}"
		git checkout "${branch}"
	fi
else
	exit 0
fi

