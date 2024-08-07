#!/usr/bin/env python3

License = '''MIT License

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
'''

import json
import sys
import os

def print_usage():
    print(License)
    print("""

Updates the commands installed from \"https://github.com/jolatechno/cli-utils.git\"

Scales a Gcode file. use \"param\" to set the scaling.


Usage: \"3dfile-scale-setparam file1 file2 ...\"
    -h help""")
    sys.exit()

if len(sys.argv) == 1:
    print_usage()

if sys.argv[1] == "-h":
    print_usage()

List = '1234567890.'
file_name = '/etc/git-cli-utils/3dPrinting/params.json'

with open(file_name, 'r') as infile:
    data = json.load(infile)

    axis = data['axis']
    scaling_factor = data['scaling_factor']
    base_height = data['base_height']
    offset = data['offset']

for name in sys.argv[1:]:
    lines = open(name, 'r').readlines()

    with open(name, 'w') as in_file:
        for line in lines:
            if line[:3] in ['G0 ', 'G1 '] and axis in line:

                i = line.index(axis) + 1
                number, new_line = '', line[:i]

                while line[i] in List:
                    number += line[i]
                    i += 1

                new_number = (float(number) + offset)*scaling_factor - base_height*(scaling_factor - 1)
                new_line += '%.3f'%(new_number) + line[i:]

                in_file.write(new_line)
            else:
                in_file.write(line)
