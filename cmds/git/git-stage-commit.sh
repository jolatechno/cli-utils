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

Stage commits so that not too many files are added at once.

It is usefull for \"git-remote-gcrypt\" so that the encrypted commit doesn't exceed the max commit size.


Usage: \"git-stage-commit\"
	-h help
	-v verbose

	-s max added file size [Mb], default is 25Mb (half of Github recommandation of 50Mb).
		If negative, will fallback to gitup.
	-m commit name, default is 'update'
	-b set branch name, default is whatever beanch you are on
	-p push only at the end (default behaviour is to push at each commit)
"
}

max_file_size_default=true
commit_name_default=true
max_file_size=25
commit_name=update
push_each=true
branch=None
verbose=false

while getopts 'hm:s:b:pv' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	s) max_file_size="${OPTARG}";
	   max_file_size_default=false;;
	m) commit_name="${OPTARG}";
	   commit_name_default=false;;
	b) branch="${OPTARG}";;
	p) push_each=false;;
	v) verbose=true;;
	*) print_usage;
		exit 1 ;;
	esac
done

if [ "${commit_name_default}" = true ]; then
	read -p "did not provide commit name, continue (unrecommanded) [Y|n] " prompt
	if [[ $prompt != "Y" ]]; then
		exit 0
	fi
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

max_file_size_config=$(git config --list --local | grep stagecommit.maxfilesize | head -n 1 | sed -n -e 's/^.*=//p')
if ! [ -z "${max_file_size_config}" ] && [ "${max_file_size_default}" = true ]; then
	echo "No max file size where passed, and \"stagecommit.maxfilesize\" is set, so falling back to its value (${max_file_size_config})"
	max_file_size=${max_file_size_config} 
fi

if [ "${branch}" = None ]; then
	branch=$(git rev-parse --abbrev-ref HEAD)
fi

if (( $max_file_size <= 0 )); then
	echo -e "Falling back to 'gitup'.. \n"

	git add .
	git commit -am "${commit_name}"
	git push -f origin ${branch}
else
	idx=0

	OIFS="$IFS"
	IFS=$'\n'
	while true; do
		added_file_size=0
		num_added=0

		to_add_dif=$(git diff --name-only)
		to_add_new=$(git ls-files --others --exclude-standard)

		to_add=$to_add_dif
		if [ ! -z "${to_add}" ] && [ ! -z "${to_add_new}" ]; then
			to_add+="$IFS"
		fi
		to_add+=$to_add_new

		if [ -z "${to_add}" ]; then
			break
		fi

		for unformated_file in $to_add; do
			file=$(printf "${unformated_file}")

			if [ -d "${file}" ] && ( [ -d "${file}/.git" ] || [ -f "${file}/.git" ] ); then
				if [ "${verbose}" = true ]; then
					echo "'${file}' should be a submodule, ignoring"
				fi
				continue
			fi

			if [ ! -f "${file}" ] && [ ! -d "${file}" ]; then
				git add "${file}"
				
				num_added=$((${num_added} + 1 ))

				if [ "${verbose}" = true ]; then
					echo "'${file}' deleted or moved"
				fi
			else
				IFS=$' \t' read _ _ _ this_file_size _ <<< $(git ls-tree -r -l HEAD "${file}")
				this_file_size=$(echo $this_file_size | tr -d ' ')
				if [ -d "${file}" ]; then
					this_file_size=0
					size_from="0 size, probably symlink of directory"
				else
					if [[ ! $this_file_size =~ ^[0-9] ]] || [ -z "${this_file_size}" ]; then
						this_file_size=$(du -sh --block-size=K "${file}" | awk -F"K" '{print $1}')
						size_from="size from du"
					else
						this_file_size=$(( ${this_file_size}/1000 ))
						size_from="size from git"
					fi
				fi

				if [ "${num_added}" = 0 ] || (( ${added_file_size} + ${this_file_size} < ${max_file_size}*1000 )); then
					git add "${file}"

					added_file_size=$((${added_file_size} + ${this_file_size}))
					num_added=$((${num_added} + 1 ))

					if [ "${verbose}" = true ]; then
						echo "adding '${file}' ${this_file_size}Kb (${size_from})"
					fi
				fi
			fi
		done

		if [ "${num_added}" = 0 ]; then
			break
		fi

		echo -e "\ncommited ${num_added} files, $(( ${added_file_size}/1000 ))M to '${commit_name}_${idx}'"
		git commit -m "${commit_name}_${idx}"

		if [ "${push_each}" = true ]; then
			echo -e "\nPushing directly...\n"
			git push -f origin ${branch}
		fi
		echo ""

		idx=$((${idx} + 1))
	done
	IFS="$OIFS"

	if ! [ "${push_each}" = true ]; then
		echo -e "\nPushing at the end...\n"
		git push -f origin ${branch}
	fi
fi