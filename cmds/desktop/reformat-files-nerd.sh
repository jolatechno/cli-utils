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

Usage: \"reformat-files-nerd\"
	-h help
"
}

while getopts 'h' flag; do
	case "${flag}" in
		h) print_usage;
			exit 1;;
		*) print_usage;
			exit 1 ;;
	esac
done


read -p "Are you sure you want to continue? [Y|n] " prompt

recursion()
{
    for file in `find "." -maxdepth 1`; do
    	if [ "$file" == "." ]; then
    		continue
    	fi

		outfile="$(echo $file | tr " " "_")"
		while true; do
			in_size=${#outfile}
			outfile="$(echo $outfile | sed 's/__/_/')"
			out_size=${#outfile}
			if  [ "$in_size" == "$out_size" ]; then
				break
			fi
		done
		outfile="$(echo $outfile | tr '[:upper:]' '[:lower:]')"
		outfile="$(echo $outfile | iconv -f utf8 -t ascii//TRANSLIT)"

		if [ "$file" != "$outfile" ]; then
			mv "$file" "$outfile"
			echo "mv $file $outfile"
		fi

		if [[ -d $outfile ]]; then
			cd $outfile
			recursion
			cd ../
		fi
	done
}

if [[ $prompt == "Y" ]]; then
	OIFS="$IFS"
	IFS=$'\n'
	recursion
	IFS=$OIFS
else
	exit 0
fi