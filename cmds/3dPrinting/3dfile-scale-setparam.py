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

Sets the scaling for \"3dfile-scale\".


Usage: \"sudo 3dfile-scale-setparam axis (char, 'X', 'Y' or 'Z'), scaling_factor (float), base_height (float), offset (float)\"
    -h help""")
    sys.exit()

if len(sys.argv) == 1:
    print_usage()

if sys.argv[1] == "-h":
    print_usage()

if not os.getuid() == 0:
    print("root privilege needed...")
    sys.exit()

file_name = '/etc/git-cli-utils/3dPrinting/params.json'

with open(file_name, 'r') as infile:
    data = json.load(infile)

assert sys.argv[1] in ["X", "Y", "Z"], "axis not understood"
data['axis'] = sys.argv[1]

if len(sys.argv) > 2:
	data['scaling_factor'] = float(sys.argv[2])

if len(sys.argv) > 3:
	data['base_height'] = float(sys.argv[3])

if len(sys.argv) > 4:
	data['offset'] = float(sys.argv[4])

with open(file_name, 'w') as outfile:
    json.dump(data, outfile)
