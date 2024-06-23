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

Delete all comit history from the main branch of a repo.

Usage: \"git-delete-history\"
	-h help

    -b set branch name, default is whatever beanch you are on
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


branch=$(git rev-parse --abbrev-ref HEAD)

while getopts 'hb:' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
    b) branch="${OPTARG}";;
	*) print_usage;
		exit 1 ;;
	esac
done

read -p "Are you sure you want to continue? [Y|n] " prompt
if [[ $prompt == "Y" ]]; then
	git checkout --orphan temp_branch && \
	git add -A                        && \
	git commit -am "the first commit" && \
	git branch -D ${branch}           && \
	git branch -m ${branch}           && \
	git push -f origin ${branch}
else
	exit 0
fi
