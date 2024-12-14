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

Give choise to user of GPG key, and return (print to stdout) properly formated public key. Is usefull for other commands.


Usage: \"choose-gpg-key\"
	-h help

	-k key name to first try without user input
	-n number of try (default is 3)
	-y continue for the first try if a key is found.
		ATTENTION: is pretty unsafe because you may have found the wrong key.
"

exit 1
}

n_try=3
input_keyid=
continue_first_try=false

while getopts 'hk:n:y' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	n) n_try="${OPTARG}";;
	k) input_keyid="${OPTARG}";;
	y) continue_first_try=true;;
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
if ! command -v gpg &> /dev/null; then
	read -p "gpg not found, install ? [Y|n] " prompt
	if [[ $prompt == "Y" ]]; then
		if command -v pacman &> /dev/null; then
			sudo pacman -Sy gpg
		elif command -v apt-get &> /dev/null; then
			sudo apt-get install gpg
		else
			>&2 echo "Installing command not found, try to install yourself."
			exit 1
		fi
	else
		exit 0
	fi
fi

for try in `seq 1 1 ${n_try}`; do
	if ! [ -z "${input_keyid}" ] 2> /dev/null && [ ${try} == 1 ]; then
		>&2 echo "(try ${try}/3) using provided key identifier \"${input_keyid}\""
		keyid=${input_keyid}
	else
		read -p "(try ${try}/3) Key identifier: " keyid
	fi
	full_key=$(gpg --list-signatures --with-colons | grep 'sig' | grep "${keyid}" | head -n 1)
	
	if [ -z "${full_key}" ]; then
		>&2 echo "key not found !"
	else
		>&2 echo "Found \"${full_key}\""

		if [ "${continue_first_try}" = true ] 2> /dev/null && [ ${try} == 1 ]; then
			continue=Y
			>&2 echo "Continuing without user input because the -y flag was provided"
		else
			read -p 'continue ? [Y|n] ' continue
		fi

		if [ "${continue}" = Y ]; then
			key=$(echo ${full_key} | sed -Ene 's#.*::([^:]+)::*.#\1#p' | sed 's/..$//')
			echo ${key}
			exit 0
		fi
	fi
	>&2 echo ""
done

>&2 echo "ERROR: Could not locate a GPG key, retry or generate a key using \"gpg --full-gen-key\""
exit 1