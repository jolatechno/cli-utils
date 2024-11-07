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

WARNING: Some part may only works with Github (for now) !

Delete all comit history from the main branch of a repo.


Usage: \"git-delete-history\"
	-h help
	-v verbose

	-m commit name, default is 'first_commit'
	-b set branch name, default is whatever beanch you are on
	-S hard delete (only for repository set up with \"git-remote-gcrypt\")
	-H use https (default is ssh) for cloning for hard delete (-S)
	-s (for \"git-stage-commit\") max added file size [Mb], default is -1 (not limit).
		If negative, will fallback to gitup.
	-p (for \"git-stage-commit\") push only at the end (default behaviour is to push at each commit)
"
}

git_params=
max_file_size=-1
commit_name=first_commit
branch=None
hard_delete=false
use_https=false
max_file_size_default=true
verbose=false
stage_commit_args=

while getopts 'hb:s:m:pSHv' flag; do
	case "${flag}" in
	h) print_usage;
		exit 1;;
	s) max_file_size="${OPTARG}";
	   max_file_size_default=false;;
	m) commit_name="${OPTARG}";;
	b) branch="${OPTARG}";;
	p) git_params+=" -p";;
	S) hard_delete=true;;
	H) use_https=true;;
	v) verbose=true;
	   stage_commit_args+=-v;;
	*) print_usage;
		exit 1 ;;
	esac
done

if ! command -v git &> /dev/null; then
	read -p "git not found, install ? [Y|n] " prompt
	if [[ $prompt == "Y" ]]; then
		if command -v pacman &> /dev/null; then
			pacman -Sy git
		elif command -v apt-get &> /dev/null; then
			apt-get install git
		else
			echo "Installing command not found, try to install yourself."
			exit 1
		fi
	else
		exit 0
	fi
fi

if [ "${branch}" = None ]; then
	branch=$(git rev-parse --abbrev-ref HEAD)
fi

max_file_size_config=$(git config --list --local | grep stagecommit.maxfilesize | head -n 1 | sed -n -e 's/^.*=//p')
if ! [ -z "${max_file_size_config}" ] 2> /dev/null && [ "${max_file_size_default}" = true ]; then
	echo "No max file size where passed, and \"stagecommit.maxfilesize\" is set, so falling back to its value (${max_file_size_config})"
	max_file_size=${max_file_size_config} 
fi

git_root=$(git rev-parse --show-toplevel)
echo "WARNING: Some part may only works with Github (for now) !"
read -p "Are you sure you want to continue? [Y|n] " prompt
if [[ "${prompt}" == "Y" ]]; then
	if [ "${hard_delete}" = true ]; then
		REPO_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*git@([^[:space:]]*).*#\1#p'`
		if [ -z "$REPO_URL" ]; then
			echo "ERROR:    Could not identify Repo url."
			exit
		fi

		USER=`echo $REPO_URL | sed -Ene's#github.com[:/]([^/]*)/(.*)#\1#p'`
		if [ -z "$USER" ]; then
			echo "ERROR:    Could not identify User."
			exit
		fi

		REPO=`echo $REPO_URL | sed -Ene's#github.com[:/]([^/]*)/(.*)#\2#p'`
		if [ -z "$REPO" ]; then
			echo "ERROR:    Could not identify Repo."
			exit
		fi

		key_fingerprint=$(git config --list --local | grep remote.origin.gcrypt-participants | head -n 1 | sed -n -e 's/^.*=//p')
		if [ -z "${key_fingerprint}" ]; then
			>&2  echo "Key finger print not found ! You should setup \"git-remote-gcrypt\" properly first"
			exit 1
		fi

		read -p "You need to go to github (https://github.com/${USER}/${REPO}.git) and delete the reposotory, then create a new one with the exact same name. Press enter when done !" null

		(
			cd /tmp
			rm -rf ${REPO}
			if [ "${use_https}" = true ]; then
				git clone "https://github.com/${USER}/${REPO}.git"
			else
				git clone "git@github.com:${USER}/${REPO}.git"
			fi
			cd ${REPO}
			git commit --allow-empty -am 'root commit'
			git config remote.origin.gcrypt-participants "${key_fingerprint}"
			git config --global user.signingkey "${key_fingerprint}"
			git remote set-url origin "gcrypt::git@github.com:${USER}/${REPO}"
			git push origin main
			cd ../
			rm -rf ${REPO}
		)
	fi

	git checkout --orphan temp_branch
	git rm --cached -rf .
	git branch -D ${branch} && git branch -m ${branch}
	if [ -f "${git_root}/.gitignore"  ]; then
		git add "${git_root}/.gitignore"
	fi
	git commit --allow-empty -am 'root commit'
	git-stage-commit -s ${max_file_size} -m ${commit_name} -b ${branch} ${git_params} ${stage_commit_args}
else
	exit 0
fi
