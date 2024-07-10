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

Automatically unlocks and copies all of the data of a swissbit archive sd card to a single forlder.


Usage: \"iAT-download-merge-all -m /dev/sdxx -o ~/Download/sync\"
	-h help

	-m (required): device mount point (like /dev/sdxx)
	-o (required): output folder for merged data
"
}

mount_point=""
output_folder=""

while getopts 'm:o:h' flag; do
	case "${flag}" in
		h) print_usage;
			exit 1;;
		m) mount_point="${OPTARG}";;
		o) output_folder="${OPTARG}";;
		*) print_usage;
			exit 1;;
	esac
done

if [ -z "${output_folder}" ]; then
	echo 'Missing mount point (-m)' >&2
	exit 1
fi

if [ -z "${output_folder}" ]; then
	echo 'Missing output folder (-o)' >&2
	exit 1
elif [ ! -d ${output_folder} ]; then
	echo "Creating output folder \"${output_folder}\"..."
	mkdir -p ${output_folder};
fi

read -p 'Unlock pin (empty if card is unlocked): ' -s PIN
if [ ! -z "${PIN}" ]; then
	echo "Unlocking card..."

	iATcli ${mount_point} login --pin ${PIN}
fi

sessions=$(iATcli ${mount_point} listSessions | tail -n +2 | awk '{print $1;}' | paste -sd " " -)

mount_folder=$(grep ${mount_point} /etc/mtab | awk '{print $2;}')
for session in $(echo "${sessions}"); do
	echo "Syncing session \"${session}\""

	iATcli ${mount_point} switchToSession --id ${session}
	rsync -a --ignore-existing "${mount_folder}/" ${output_folder}
done