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

Stage commits so that not too many files are added at once.

It is usefull for \"git-remote-gcrypt\" so that the encrypted commit doesn't exceed the max commit size.

Usage: \"git-stage-commit\"
	-h help

	-s max added file size [Mb], default is 25Mb (half of Github recommandation of 50Mb)
    -m commit name, default is 'update'
    -b set branch name, default is whatever beanch you are on
    -p push at each commit
"
}

if ! command -v git &> /dev/null; then
    read -p "git not found, install ? [Y|n] " prompt
    if [[ $prompt == "Y" ]]; then
        if command -v pacman &> /dev/null; then
            pacman -Sy git
        elif command -v apt-get &> /dev/null; then
            apt-get install git
        else
            echo "Installing command not found, try to install yourself."
            exit 1
        fi
    else
        exit 0
    fi
fi

max_file_size=25
commit_name=update
push_each=false
branch=$(git rev-parse --abbrev-ref HEAD)

while getopts 'hm:s:b:p' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
    s) max_file_size="${OPTARG}";;
    m) commit_name="${OPTARG}";;
    b) branch="${OPTARG}";;
	p) push_each=true;;
	*) print_usage;
		exit 1 ;;
	esac
done

echo "commiting changes to existing file to '${commit_name}_change'"
git commit -am "${commit_name}_change"
if [ "${push_each}" = true ]; then
	git push -f origin ${branch}
fi


idx=0
added_file_size=0
to_add=$(git ls-files --others --exclude-standard)


OIFS="$IFS"
IFS=$'\n'
for file in $to_add; do
	this_file_size=$(du -sh --block-size=M ${file} | awk -F"M" '{print $1}')
	if (( $added_file_size + $this_file_size > $max_file_size )); then
		if [ "$added_file_size" = 0 ]; then
			git add "${file}"
		fi

		echo "commited ${added_file_size}M to '${commit_name}_${idx}'"

		git commit -m "${commit_name}_${idx}"
		if [ "${push_each}" = true ]; then
			git push -f origin ${branch}
		fi
		idx=$(($idx + 1))

		if ! [ "$added_file_size" == 0 ]; then
			added_file_size=$this_file_size
			git add "${file}"
		else
			added_file_size=0
		fi
	else
		git add "${file}"
		added_file_size=$(($added_file_size + $this_file_size))
	fi
done
IFS=$OIFS

if ! [ "${push_each}" = true ]; then
	git push -f origin ${branch}
fi
