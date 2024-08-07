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

Used to give a small git cheat-sheet.


Usage: \"gitcheat -v/t\"
    -h help

    -v visual cheat-sheet about branches
    -t textual cheat-sheet
"
}

print_text() {
  printf "branch:
  to list all branches use \"git branch -a\"
  to create a branch use \"git branch branch_name\"
  to switch to a branch use \"git checkout branch_name\"
  to merge a branch use \"git merge branch_name\" (it will merge it with the branch you are currently on)
  to delete a merged branch use \"git branch -d branch_name\"
  to delete ANY branch (UNSAFE) use \"git branch -D branch_name\"

push:
  to queue all file in a path for later commit use \"git add path\"
  to commit all staged change use \"git commit -m 'comment'\"
  to push to the server us \" git push origin branch_name\"

credential:
  to remember creadentials use \"git config --global credential.helper store\"
  to forget them use \"git config --global credential.helper erase\"
"
}

print_visual() {
  printf "
  |                        ___________________
  |                       |                   |
  |                       |   git branch -a   |
  |                       |                   |
  |                       |     - *master     |
  |                       |___________________|
  |                                 |
  |                        _________v_________
  |                       |                   |
  |\ _ _ _ _ _ _ _        | git branch branch |
  |               \       |___________________|
  |               |                 |
  |                        _________v_________
  |               |       |                   |
  |                       |   git branch -a   |
  |               |       |                   |
  |                       |     - *master     |
  |               |       |     - branch      |
  |                       |___________________|
  |               |                 |
  |                       __________v__________
  |               |      |                     |
  | ------------> |      | git checkout branch |
                  |      |_____________________|
  |               |                 |
                  |        _________v_________
  |               |       |                   |
                  |       |   git branch -a   |
  |               |       |                   |
                  |       |     - master      |
  |               |       |     - *branch     |
                  |       |___________________|
  |               |                 |
                                    |\________________________
                                    |                         \\
        . . .                 commits etc...                  |
                                    |                         |
                                    |                         |
  |               |       __________v__________               |
                  |      |                     |              |
  | <------------ |      | git checkout master |              |
  |               |      |_____________________|              |
  |                                 |                         |
  |               |        _________v_________                |
  |                       |                   |               |
  | _____________/|       | git merge branch  |               |
  |/                      |___________________|               |
  |               |                 |                         |
  |                        _________v_________                |
  |               |       |                   |               |
  |                       |   git branch -a   |               |
  |               |       |                   |               |
  |                       |     - master      |               |
  |               |       |     - *branch     |               |
  |                       |___________________|               |
  |               |                 |                         |
  |                       __________v___________    __________v___________
  |               |      |                      |  |                      |
  |               X      | git branch -d branch |  | git branch -D branch |
  |                      |______________________|  |______________________|
  |                                 | ________________________/
  |                                 |/
  |                        _________v_________
  |                       |                   |
  |                       |   git branch -a   |
  |                       |                   |
  |                       |     - *master     |
  |                       |___________________|

_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

     ___________________
    |                   |
    |   git add files   |
    |___________________|
              |
   ___________v___________
  |                       |
  | git commit -m message |/______________________________________
  |_______________________|\              \                       \\
              |                           |                       |
   ___________v____________     __________|_________     _________|________
  |                        |   |                    |   |                  |
  | git push origin branch |   |  git revert index  |   | git reset index  |
  |________________________|   |____________________|   |__________________|
              |                          /\                      /\\
              \\__________________________/_______________________/

"
}

while getopts 'hvt' flag; do
  case "${flag}" in
    h) print_usage;
      exit 1;;
    v) print_visual;;
    t) print_text;;
    *) print_usage;
       exit 1 ;;
  esac
done
