#!/usr/bin/zsh
setopt NULL_GLOB
fileIO_tb_files="../fileIO_tb_files/*"
echo Name \#Errors Score>> grades.csv
for name in *
do
	if [ -d $name ]
	then
	        echo "Student $name"
		for file in *$name* 
		do
			if [ -d $file ]
			then
				echo "mv test_bench files to ./$name"
				# copy fileIO test files to student directory
				cp $fileIO_tb_files ./$name			
				# find and copy alu.v/ALU.v (case insensitive) to the main student directory
				find $name -iname "alu.v" -exec cp {} $name \;
				# replace module names to 'alu' from 'ALU' to maintain consistency
				sed -i 's/module ALU/module alu/' ./$name/*.v
				
				#ModelSim simulations
				cd ./$name				
				vlib work
				vlog *.v && vsim -c -do 'run 1000ns;quit' alu_tb_file_io				
				if [ -e output.txt ]
				then 
					ERR=$(grep -o "Error" output.txt|wc -w)
					echo "********************************************************"					
					echo "My God"
				else 
					ERR=11
					echo "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
					echo "No Output.txt"					

				fi
				echo $name $ERR $(($(($((11-$ERR))*100))/11))>> ../grades.csv				
				cd ..
			fi
		done
	fi
done


