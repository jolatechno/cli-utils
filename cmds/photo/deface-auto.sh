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

Usage: \"compress-all-jpg\"
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

if ! command -v deface &> /dev/null; then
    read -p "deface not found, install ? [Y|n] " prompt
    if [[ $prompt == "Y" ]]; then
        python3 -m pip install deface
    else
        exit 0
    fi
fi

deface --mask-scale 1.0 --replacewith blur --thresh 0.18 \
	*[^\(_anonymized\)].jpg *[^\(_anonymized\)].png *[^\(_anonymized\)].jpeg *[^\(_anonymized\)].JPG *[^\(_anonymized\)].PNG *[^\(_anonymized\)].JPEG
