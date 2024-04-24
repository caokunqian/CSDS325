DEVICE_LIST=`iw dev | awk '$1=="Interface"{print $2}'`
# This line gets the list of network interfaces using `iw dev` and filters it using `awk` to extract the second field, which is the interface name, when the first field is 'Interface'.

for d in $DEVICE_LIST ; do
# This begins a loop over each device in the DEVICE_LIST.

	bssid=`iwconfig ${d} | sed -n 's/.*Access Point: \([0-9\:A-F]\{17\}\).*/\1/p'`
# Retrieves the BSSID of the Wi-Fi access point the interface is connected to using `iwconfig` and parses it with `sed` to capture the MAC address pattern.

	if [ ! -z "$bssid" ]; then
# Checks if the BSSID variable is not empty.

		echo $bssid
# Prints the BSSID if it is present.
	fi
done
# Ends the loop.




PID=$1
# Assigns the first command line argument to the variable PID, representing a process ID.

SMAP=/proc/$PID/smaps
# Sets the SMAP variable to the path of the memory map file for the given PID.

  grep -q 'Private_Dirty' $SMAP;
# Searches for 'Private_Dirty' in the smaps file, which indicates memory pages that have been modified (dirty).

  if [ $? -ne 0 ]; then
# Checks if the last command (`grep`) failed to find any lines (meaning no dirty pages).

    continue;
# Continues to the next iteration of a surrounding loop (if applicable, though this appears to be an error as no loop is visible here).
  fi;
  awk '/Private_Dirty/ {print $2,$3}' $SMAP |
# Extracts the memory size and unit for private dirty pages using awk.

   sed 's/ tB/*1024 gB/;s/ gB/*1024 mB/;s/ mB/*1024 kB/;s/ kB/*1024/;1!s/^/+/;' |
# Converts units from TB to GB, GB to MB, MB to KB, and KB to bytes, preparing to sum them up.

   tr -d '\n' |
# Removes newline characters to prepare the input for `bc`.

   sed 's/$/\n/' |
# Adds a newline at the end for correct input to `bc`.

   bc |
# Performs arithmetic calculation to sum up all memory values.

   tr -d '\n';
# Removes any newlines from the output of `bc`.

  echo;
# Prints a newline (effectively outputs the result from `bc`).
