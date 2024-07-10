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

Usage: \"convert-all-raw\"
	-h help

	-r recursive
"
}

recursive=false

while getopts 'hr' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	r) recursive=true;;
	*) print_usage;
		exit 1 ;;
	esac
done

find_all() {
	first=1
	for ext in "$@"; do
		if [[ $first == 1 ]]; then
			find_filter=(-iname "*.$ext")
			first=0
		else
			find_filter+=( -o -iname "*.$ext")
		fi
	done

	additional_flag=""
	if [ $recursive == false ] ; then
		additional_flag+="-maxdepth 1"
	fi

	echo "$(find . ${additional_flag} -type f \( "${find_filter[@]}" \) | cut -b 3-)"
}

if ! command -v ffmpeg &> /dev/null; then
	read -p "ffmpeg not found, install ? [Y|n] " prompt
	if [[ $prompt == "Y" ]]; then
		if command -v pacman &> /dev/null; then
			sudo pacman -Sy ffmpeg
		elif command -v apt-get &> /dev/null; then
			sudo apt-get install ffmpeg
		else
			echo "Installing command not found, try to install yourself."
			exit 1
		fi
	else
		exit 0
	fi
fi

all=$(find_all "MTS" "CRW")
OIFS="$IFS"
IFS=$'\n'
for file in $all; do
	outfile=converted_$(basename "${file%.*}").mp4
	if [ ! -f "$outfile" ]; then
		echo "exporting $file -> $outfile"
		ffmpeg -i $file -c:v copy -c:a aac -strict experimental -b:a 128k $outfile
	fi
done
IFS=$OIFS