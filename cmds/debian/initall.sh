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

Updates the commands installed from \"https://github.com/jolatechno/cli-utils.git\"

Installs all .deb or .AppImage the commands find.


Usage: \"sudo initall directory1 directory2 ...\"
	-h help
"
}

while getopts 'h' flag; do
	case "${flag}" in
		h) print_usage;
			exit 1;;
	esac
done

if [ "$(id -un)" != "root" ]; then
		>&2 echo "root privilege needed..."
		exit 1
fi

for directory in $*; do
	echo "going through $directory ..."

	for filename in $directory/*; do
		echo "found $filename"

		if [[ $filename =~ \.deb$ ]]; then
			echo "installing $filename..."

			apt install -y $filename
		fi

		if [[ $filename =~ \.AppImage$ ]] || [[ $filename =~ \.appimage$ ]]; then
			echo "integrating $filename..."

			chmod +x $filename && \
			ail-cli integrate $filename && \
			cd $directory
		fi
	done
done
