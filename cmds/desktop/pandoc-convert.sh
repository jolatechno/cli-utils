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

Can convert .ipynb, .html, .md, and a lot of file type to some other file types

Usage: \"pandoc-convert -p -o -f file1 file2 ...\"
	-h help

	-p convert to .pdf
	-o convert to .odt
	-d convert to .docx
	-H convert to .html
	-i convert to .ipynb
	-t convert to .txt
	-l convert to .tex

	-O any other type

"
}


outputs=()

exlude_files="-p -o -d -H -i -t -l -O"

while getopts 'hpodHitlO:' flag; do
	case "${flag}" in
	p) outputs+=" pdf";;
	o) outputs+=" odt";;
	d) outputs+=" docx";;
	H) outputs+=" html";;
	i) outputs+=" ipynb";;
	t) outputs+=" txt";;
	l) outputs+=" tex";;
	O) outputs+=" ${OPTARG}";
	   exlude_files+=" ${OPTARG}";;
	h) print_usage;
		exit 1;;
	*) print_usage;
		exit 1 ;;
	esac
done

if [ ${#outputs[@]} -eq 0 ]; then
	print_usage

	echo "Error: No output format provided !!"
	exit 1
fi

if ! command -v pandoc &> /dev/null; then
    read -p "pandoc not found, install ? [Y|n] " prompt
    if [[ $prompt == "Y" ]]; then
        if command -v pacman &> /dev/null; then
            sudo pacman -Sy pandoc
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install pandoc
        else
            echo "Installing command not found, try to install yourself."
            exit 1
        fi
    else
        exit 0
    fi
fi

for file in $@; do
	if [[ ! " $exlude_files " =~ .*\ $file\ .* ]]; then
		base_file_name=$(basename "${file%.*}")

		for output in $outputs; do
			output_file_name="${base_file_name}.${output}"

			pandoc $file -o $output_file_name
		done
	fi
done