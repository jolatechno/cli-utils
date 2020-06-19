# git-cli-utils
additional command to make using the git cli with github easier. Also help with golang developement

## Installation

use `sudo bash ./init` or `chmod +x ./init && sudo ./init` to init all the commands.

***IMPORTANT:*** the `./init` file will **only** move file to the `/usr/bin/` directory (and not install anything else), but some commands (like `initall` and `smbinit`) will check if some software is installed and install it if not **without prompting the user**. If you don't want any software install **just don't run them**. Those command are marked in the readme by an _(installed required)_ in the title.

## Usage

### gogit

Using `gogit` in a github repository will return a version like `v0.0.0-20200611092339-bfa8c546e108` which can then be use in a `go.mod` file to import a go project.

### gitup

Using  `gitup` in a github repository is equivalent to running `git add . && git commit -am 'update' && git push -f origin master` which make it faster option to manage simple hit project.

### gitkey

`gitkey` will generate an ssh key and add it to your github account with the folowing option:

```
Usage: "gitkey -u github_username -e github_email@mail.com -N passphrase -f key/file/name -k github_key_name"
  -u github username (mendatory)
  -e github email (mendatory)
  -N ssh key passphrase
  -f ssh key file name

  -h help
```

### gitdown

`gitdown ...` is exatly like `git clone --recurse-submodules -j $N ...` with `$N` being the number of thread that your computer has.

### initall _(installed required)_

`initall $directory1 $directory2 ...` will go through every file in each specified directory and install it if it is a `.deb` file and integrate it using [AppImageLauncher](https://github.com/TheAssassin/AppImageLauncher) if it is a `.AppImage` or `.appimage` file.

`initall` will check if `AppImageLauncher` is installed each time it is used and install it if it's not.

### smbinit _(installed required)_

`smbinit` will create a new samba share with the specified parameters.

`smbinit` will check if `samba` is installed each time it is used and install it if it's not.

```
Usage: " sudo smdadd -n share_name -f share_path -u share_allowed_user"
  -u allowed user (if not specified will be $(whoami))
  -n share name (mendatory)
  -f share path (mendatory)

  -h help
```
