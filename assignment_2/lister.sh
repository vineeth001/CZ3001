#!/usr/bin/zsh
setopt null_glob
for name in *
do
	if [ $name ]
	then
		for file in *$name* 
		do			
			if [ $file ]
			then		
				echo $name | sed -e 's/\(^.*submission_\)\(.*\)\(_att.*$\)/\2/' >> ../list.txt
			fi
		done
	fi
done
