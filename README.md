# cli-utils

Additional command to make a variety of my daily tasks easier.

_The following readme is mainly automatically generated from the help menu of each command._

## Installation

Use `sudo make target1 target2 ...` to install all the commands. "target" here are the title of the sections in "__Commands__".

If you want to install all the target you can run `sudo make all`, if you run `sudo make`, only the `base` target will be installed.

`sudo make update` will only update already installed package.

# Commands

## Base


### _cmdsup_

```bash
Used to update this package.


Usage: "sudo cmdsup"
	-h help
```

### _install-cmd_

```bash
installs all commands as exectuables to /bin/ and removes the extension.


Usage: "sudo install-cmd cmd1.sh cmd2.py ..."
	-h help
```

## 3dPrinting


### _3dfile-scale_

```bash
Scales a Gcode file. use "param" to set the scaling.


Usage: "3dfile-scale-setparam file1 file2 ..."
    -h help
```

### _3dfile-scale-setparam_

```bash
Sets the scaling for "3dfile-scale".


Usage: "sudo 3dfile-scale-setparam axis (char, 'X', 'Y' or 'Z'), scaling_factor (float), base_height (float), offset (float)"
    -h help
```

## debian


### _initall_

```bash
Installs all .deb or .AppImage the commands find.


Usage: "sudo initall directory1 directory2 ..."
	-h help
```

## desktop


### _reformat-files-nerd_

```bash
Reformats all file names to avoid uppercase, special character, and replaces any length of spaces to a single underscore.


Usage: "reformat-files-nerd"
	-h help
```

### _compress-all-pdfs_

```bash
Compresses all pdfs.


Usage: "compress-all-pdfs"
	-h help

	-r recursive
```

### _pandoc-convert_

```bash
Can convert .ipynb, .html, .md, and a lot of file type to some other file types.


Usage: "pandoc-convert -p -o file1 file2 ..."
	-h help

	-p convert to .pdf
	-o convert to .odt
	-d convert to .docx
	-H convert to .html
	-i convert to .ipynb
	-t convert to .txt
	-l convert to .tex

	-O any other type
```

## git


### _gitcheat_

```bash
Used to give a small git cheat-sheet.


Usage: "gitcheat -v/t"
    -h help

    -v visual cheat-sheet about branches
    -t textual cheat-sheet
```

### _git-delete-history_

```bash
WARNING: Some part may only works with Github (for now) !

Delete all comit history from the main branch of a repo.


Usage: "git-delete-history"
	-h help
	-v verbose

	-m commit name, default is 'first_commit'
	-b set branch name, default is whatever beanch you are on
	-S hard delete (only for repository set up with "git-remote-gcrypt")
	-H use https (default is ssh) for cloning for hard delete (-S)
	-s (for "git-stage-commit") max added file size [Mb], default is -1 (not limit).
		If negative, will fallback to gitup.
	-p (for "git-stage-commit") push only at the end (default behaviour is to push at each commit)
```

### _git-fix-detached-head_

```bash
Used to fix a "git detached HEAD" error without loosing changes.

Usage: "git-fix-detached-head"
	-h help

	-b set branch name, default is whatever beanch you are on
```

### _git-https-to-ssh_

```bash
Code by Matt Farmer [https://gist.github.com/m14tode] found at [https://gist.github.com/m14t/3056747]

WARNING: Only works with Github (for now)

This command will set the git origin from https to ssh.


Usage: "git-https-to-shh":
	-h help
```

### _gitdown_

```bash
Clones recursively all submodules.


Usage: "gitdown ..."
	-h help
```

### _gitup_

```bash
Equivalent to "git add . ; git commit -am 'update' ; git push -f origin 'branch'"

If "stagecommit.maxfilesize" is set in git config, will fallback to
"git-stage-commit" to respect this set limit.


Usage: "gitup"
	-h help
	-v verbose

	-m commit name, default is 'update'
	-b set branch name, default is whatever beanch you are on
	-A remove the '-a' flag (don't add un-added files)
```

### _gogit_

```bash
Gets the go version of a directory used as a go package.


Usage: "gogit"
	-h help
```

## nas


### _smbadd_

```bash
Used to add a samba share.


Usage: "sudo smbadd -n share_name -f share_path -u share_allowed_user"
	-h help

	-n share name (mendatory)
	-f share path (mendatory)
	-u allowed user (if not specified will be jo)
```

### _smbdel_

```bash
Deletes a samba share.


Usage: "sudo smbdel share_name1 share_name2 ..."
	-h help
```

### _spindown_

```bash
Adds a spindown timer to a hard drive.


Usage: "sudo spindown -d drive_device_name -t time"
	-h help

	-t spin down time (default is 25, see hdparm for more info)
	-d drive name (default is "sda")
```

## photo


### _convert-all-raw_

```bash
Converts all raw images to jpg.


Usage: "convert-all-raw"
	-h help

	-r recursive
```

### _iAT-clear-all_

```bash
Automatically unlocks and clears a swissbit archive sd card.


Usage: "iAT-clear-all -m /dev/sdxx"
	-h help

	-m (required): device mount point (like /dev/sdxx)
```

### _iAT-download-merge-all_

```bash
Automatically unlocks and copies all of the data of a swissbit archive sd card to a single forlder.


Usage: "iAT-download-merge-all -m /dev/sdxx -o ~/Download/sync"
	-h help

	-m (required): device mount point (like /dev/sdxx)
	-o (required): output folder for merged data
```

### _compress-all-jpg_

```bash
Compress all jpg images here.


Usage: "compress-all-jpg"
	-h help

	-r recursive
```

### _convert-all-raw-video_

```bash
Converts all raw videos to mp4.


Usage: "convert-all-raw"
	-h help

	-r recursive
```

### _deface-auto_

```bash
Automatically blurs faces in all image files here.


Usage: "compress-all-jpg"
	-h help
```


# License

MIT License

Copyright (c) 2020 joseph touzet

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

