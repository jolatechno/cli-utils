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

Equivalent to \"git add . ; git commit -am 'update' ; git push -f origin main\"

Usage: \"gitup\"
	-h help

    -m commit name, default is 'update'
    -b set branch name, default is whatever beanch you are on
    -A remove the '-a' flag (don't add un-added files)
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

add_files=true
commit_name=update
branch=$(git rev-parse --abbrev-ref HEAD)

while getopts 'hm:Ab:' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
    A) add_files=false ;;
    m) commit_name="${OPTARG}";;
    b) branch="${OPTARG}";;
	*) print_usage;
		exit 1 ;;
	esac
done

if [ "${add_files}" = true ]; then
   git add .
fi
git commit -am "${commit_name}"
git push -f origin ${branch}
