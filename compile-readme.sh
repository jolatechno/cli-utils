#!/bin/bash

License=$(cat ./LICENSE)

echo "# cli-utils

Additional command to make a variety of my daily tasks easier.

_The following readme is mainly automatically generated from the help menu of each command._

## Installation

Use \`sudo make target1 target2 ...\` to install all the commands. \"target\" here are the title of the sections in \"__Commands__\".

If you want to install all the target you can run \`sudo make all\`, if you run \`sudo make\`, only the \`base\` target will be installed.

\`sudo make update\` will only update already installed package.

# Commands

## Base

" > ./README.md


for executables in $(cd cmds && find "." -maxdepth 1 -executable -type f); do
	help=$( cd cmds && ${executables} -h )
	help_after_update=$( echo "${help}" | grep -A 100 -m 1 -e 'Updates' | tail -n +3 )
	
	filename="${executables:2}"
	filename="${filename%.*}"

	echo "### _${filename}_

\`\`\`bash
${help_after_update}
\`\`\`
" >> ./README.md
done


for target in $(cd cmds && find "." -maxdepth 1 -type d); do
	if [ "${target}" = "." ]; then
		continue
	fi

	target="${target:2}"

	echo "## ${target}

" >> ./README.md

	for executables in $(cd cmds/${target} && find "." -maxdepth 1 -executable -type f); do
		help=$( cd cmds/${target} && ${executables} -h )
		help_after_update=$( echo "${help}" | grep -A 100 -m 1 -e 'Updates' | tail -n +3 )
		
		filename="${executables:2}"
		filename="${filename%.*}"

		echo "### _${filename}_

\`\`\`bash
${help_after_update}
\`\`\`
" >> ./README.md
	done
done 


echo "
# License

${License}
" >> ./README.md