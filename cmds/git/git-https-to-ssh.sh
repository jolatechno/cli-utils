#!/bin/bash
#code by Matt Farmer https://gist.github.com/m14t
#code at https://gist.github.com/m14t/3056747

print_usage() {
    printf "code by Matt Farmer https://gist.github.com/m14t
code at https://gist.github.com/m14t/3056747

this command will set the git origin from https to ssh.

Usage: \"git-https-to-shh\":
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

read -p "Are you sure you want to continue? [Y|n] " prompt
if [[ $prompt == "Y" ]]; then

    #-- Script to automate https://help.github.com/articles/why-is-git-always-asking-for-my-password

    REPO_URL=`git remote -v | grep -m1 '^origin' | sed -Ene's#.*(https://[^[:space:]]*).*#\1#p'`
    if [ -z "$REPO_URL" ]; then
        echo "ERROR:    Could not identify Repo url."
        echo "It is possible this repo is already using SSH instead of HTTPS."
        exit
    fi

    USER=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\1#p'`
    if [ -z "$USER" ]; then
        echo "ERROR:    Could not identify User."
        exit
    fi

    REPO=`echo $REPO_URL | sed -Ene's#https://github.com/([^/]*)/(.*).git#\2#p'`
    if [ -z "$REPO" ]; then
        echo "ERROR:    Could not identify Repo."
        exit
    fi

    NEW_URL="git@github.com:$USER/$REPO.git"
    echo "Changing repo url from "
    echo "'$REPO_URL'"
    echo "        to "
    echo "'$NEW_URL'"

    git remote set-url origin $NEW_URL
else
    exit 0
fi