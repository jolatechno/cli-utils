# git-cli-utils
additional command to make using the git cli with github easier. Also help with golang developement

## Installation

use `sudo make target1 target2 ...` to init all the commands.

If you want to install all the target you can run `sudo make all`, if you run `sudo make`, only the `base` target will be installed.

`sudo make update` will only update already installed package

## updating

Use `sudo cmdsup` to update all installed commands.

## Usage

#### cmdsup

`sudo cmdsup` will clone this directory, update all installed commands then and delete it.

### _git_

#### gogit

Using `gogit` in a github repository will return a version like `v0.0.0-20200611092339-bfa8c546e108` which can then be use in a `go.mod` file to import a go project.

#### gitup

Using  `gitup` in a github repository is equivalent to running `git add . && git commit -am 'update' && git push -f origin master` which make it faster option to manage simple hit project.

#### gitkey

`gitkey` will generate an ssh key and add it to your github account with the folowing option:

```
Usage: "gitkey -u github_username -e github_email@mail.com -N passphrase -f key/file/name -k github_key_name"
  -u github username (mendatory)
  -e github email (mendatory)
  -N ssh key passphrase
  -f ssh key file name

  -h help
```

#### gitdown

`gitdown ...` is exatly like `git clone --recurse-submodules -j $N ...` with `$N` being the number of thread that your computer has.

### _nas_

#### spindown

`sudo spindowsn` will set a spindown delay on a specific hard drive.

```
Usage: " sudo spindown -d drive_device_name -t time "
-t spin down time (default is 25, see hdparm for more info)
-d drive name (default is "sda")

-h help
```

#### smbinit

`sudo smbinit` will create a new samba share with the specified parameters.

```
Usage: " sudo smbinit -n share_name -f share_path -u share_allowed_user"
  -u allowed user (if not specified will be $(whoami))
  -n share name (mendatory)
  -f share path (mendatory)

  -h help
```

### _3dPrinting_

#### param

`sudo param ...` will change the parameters for the `scale` command.

#### scale

`scale file1 file2 ...` will scale `file1 file2 ...` according to the parameters set by the `param` command.

#### _desktop_

### initall

`sudo initall $directory1 $directory2 ...` will go through every file in each specified directory and install it if it is a `.deb` file and integrate it using [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher) if it is a `.AppImage` or `.appimage` file.
