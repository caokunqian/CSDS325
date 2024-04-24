#!/bin/bash
# This line defines the script's interpreter, indicating the script is to be executed using the Bash shell.

# Program:
# Description comment to outline the purpose of the script, which is to configure core dump output paths.

#	script to config core dump output path

CORE_PATTERN_FILE=/proc/sys/kernel/core_pattern
# This line assigns the path to the system's core pattern configuration file to a variable.

if [ "$1" != "--silent" ]; then
# This conditional checks if the first argument ($1) is not "--silent", used to run the script silently.

	value=`cat ${CORE_PATTERN_FILE}`
# Retrieves the current setting for core dump handling from the system configuration and stores it in 'value'.

	if [ "${value:0:1}" = "|" ];
# Checks if the first character of 'value' is '|', indicating a pipe symbol which means core dumps are being piped to a program.
	then
		echo "Instead of writing the core dump to disk, your system is configured to send it to the \"$value\" instead."
# Outputs a message stating that core dumps are being sent to a program, not written to disk.
	else
		echo "The current core dump file name is \"$value\"." 
# If the first character is not '|', outputs the current core dump file path.
	fi
	echo "Do you want to modify the core dump file name?"
# Prompts the user if they want to modify the core dump configuration.
	read -p " (yes) or (no):" selection
# Reads user input into the variable 'selection'.

	if [ $selection == "yes" ] || [ $selection == "y" ]; 
# Checks if the user's input indicates a desire to modify the core dump settings.
		then :
# No operation (':') is used here as a placeholder for syntax purposes.
	else
		exit 1
# If the user does not want to modify settings, the script exits with a status of 1.
	fi
fi

CORE_FILE="/tmp/core_zoom_%p"
# Sets the default core file path to include the process ID (%p) in the filename under /tmp directory.

echo "Do you want to specify a core dump file name or use the default one?"
# Asks the user if they want to specify their own core dump file name or use the default.

function specify_file_name()
# Defines a function to allow the user to specify a custom core dump file name.
{
	read -p "Please specify core dump file name:" CORE_FILE
# Prompts the user to enter a core dump file name and stores it in 'CORE_FILE'.
	if [ "${CORE_FILE:0:1}" = "/" ]; then
# Checks if the specified core dump file name starts with '/', indicating an absolute path.
		echo "The core dump file name is $CORE_FILE"
# Confirms the specified core dump file name to the user.
		echo $CORE_FILE > $CORE_PATTERN_FILE
# Writes the new core dump file name to the system's core pattern configuration file.
		exit 0
# Exits the script successfully.
	fi
	echo "Invalid file name! File name must start with an absolute path"
# If the file name does not start with '/', outputs an error message.
	specify_file_name
# Recursively calls the function to let the user attempt to specify the file name again.
}
#$1 user selection
function handle_selection()
# Defines a function to handle the user's selection between default or specified file name.
{
	echo "    (1) Default core dump file name(/tmp/core_zoom_%p)"
# Presents the default core dump file name option.
	echo "    (2) Specify a file name(file name must start with an absolute path)"
# Presents the option to specify a custom file name.
	read -p "Your selection?" selection
# Reads the user's choice into 'selection'.

	if [ $selection == "1" ] || [ $selection == "(1)" ]; then
# Checks if the user selected the default file name.
		echo $CORE_FILE > $CORE_PATTERN_FILE
# Writes the default core file name to the core pattern configuration file.
	elif [ $selection == "2" ] || [ $selection == "(2)" ]; then
# Checks if the user wants to specify a custom file name.
		specify_file_name
# Calls the function to handle custom file name specification.
	else
		echo "Invalid selection"
# If the user's input is neither valid option, outputs an error message.
		handle_selection
# Recursively calls the function to let the user attempt to choose again.
	fi
}

handle_selection
# Calls the function to start the selection process.
