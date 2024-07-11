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

Renames all files/directories according to some paterns and parameters.


Usage: \"rename-all -b/e -r/f [patern to replace] [patern to replace with]\" 
	-h help

	-r recursive (not yet supported)
	-b add patern to begin of file name
	-e add patern to end of file name (before extension)
	-R replace following patern with the given patern
	-f patern to find to add the patern, without replacing it
	-E replace with empty patern
"
}

recursive=false
place=
to_replace=
to_find=
empty=false

while getopts 'hrbeR:f:E' flag; do
	case "${flag}" in
		h) print_usage;
			exit 1;;
    	r) recursive=true;;
		b) if [ "${place}" = "end" ] || [ ! -z "${to_replace}" ]; then
			>&2 echo "Can't add to end (-e) or replace (-R) AND begin (-b) !"
			exit 1
		fi
		place=begin;;
		e) if [ "${place}" = "begin" ] || [ ! -z "${to_replace}" ]; then
			>&2 echo "Can't add to begin (-b) or replace (-R) AND end (-e) !"
			exit 1
		fi
		place=end;;
		R) if [ "${place}" = "end" ] || [ "${place}" = "begin" ] || [ ! -z "${to_find}" ]; then
			>&2 echo "Can't add to begin (-b), end (-e), or find (-f) AND replace (-R) !!"
			exit 1
		fi
		to_replace="${OPTARG}";;
		f) if [ ! -z "${to_replace}" ]; then
			>&2 echo "Can't replace (-R) AND find (-f) !!"
			exit 1
		fi
		to_find="${OPTARG}";;
		E) empty=true;;
		*) print_usage;
			exit 1 ;;
	esac
done

to_add=
if [ "${empty}" = false ]; then
	to_add="${@: -1}"
	if [ -z "${to_add}" ]; then
		>&2 echo "No patern to replace with/add given !"
		exit 1
	fi
fi

read -p "Are you sure you want to continue? [Y|n] " prompt

recursion()
{
    for file in `find "." -maxdepth 1`; do
    	if [ "$file" == "." ]; then
    		continue
    	fi

    	if [ ! -z "${to_find}" ]; then
    		if [ -z "$(echo "${file}" | grep ${to_find} )" ]; then
    			if [[ -d ${file} ]] && [ ${recursive} = true ]; then
					cd ${file}
					recursion
					cd ../
				fi
    			continue
    		fi
		fi

		outfile="${file}"
		if [ "${place}" = "begin" ]; then
			outfile="./${to_add}${file:2}"
		elif [ "${place}" = "end" ]; then
			filename="${file:2}"
			extension="${filename##*.}"
			filename="${filename%.*}"

			outfile="./${filename}${to_add}.${extension}"
		else
			if [ ! -z "${to_replace}" ]; then
				outfile="${outfile/"${to_replace}"/"${to_add}"}"
			fi
		fi

		if [ "${file}" != "${outfile}" ]; then
			mv "$file" "$outfile"
			echo "mv $file $outfile"
		fi

		if [[ -d ${outfile} ]] && [ ${recursive} = true ]; then
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