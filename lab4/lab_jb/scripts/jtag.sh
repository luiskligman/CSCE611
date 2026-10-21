#!/bin/sh

# script to make sure jtag is working properly

set -e
set -u

TEMP="$(mktemp)"

retries=$1

echo "setting up JTAG, $retries retries left... "

if ! lsusb | grep -q "Altera Blaster" ; then
	echo "no Altera Blaster USB device detected, is your cable connected and board powered on?" 1>&2
	rm -f "$TEMP"
	exit 1
fi

if [ ! -x "$(which quartus_pgm)" ] ; then
	echo "environment problem: no quartus_pgm in PATH" 1>&2
	rm -f "$TEMP"
	exit 1
fi

restart_jtagd () {

	# check if another user is running jtagd
	if LD_LIBRARY_PATH="" ps aux | awk '$11 ~ /^jtagd/ {print($1)}' | grep -v -q "$(whoami)" ; then
		echo "someone else is running jtagd on this system, please ask them to close their instance" 1>&2
		rm -f "$TEMP"
		exit 1
	fi

	# jtagd not running
	if [ "$(LD_LIBRARY_PATH="" ps aux | awk '$11 ~ /^jtagd/' | wc -l)" -lt 1 ] ; then
		printf "" # do nothing
	else
		# kill the running jtagd instance
		echo "restarting jtagd... "
		LD_LIBRARY_PATH="" ps aux | awk '$1 ~ /^'"$(whoami)"'$/' | awk '$11 ~ /^jtagd/ {print($2)}' | LD_LIBRARY_PATH="" xargs kill
	fi

	# start jtagd
	if [ -e "/usr/local/3rdparty/altera/18.1/quartus/linux64/pgm_parts.txt" ] ; then
		# on a lab machine
		jtagd --config /usr/local/3rdparty/altera/18.1/quartus/linux64/pgm_parts.txt
	else
		jtagd
	fi
}


STATUS=OK
if ! timeout 10s quartus_pgm --auto > "$TEMP" 2>&1 ; then
	echo "programming error!"
	restart_jtagd
	STATUS=FAIL
fi

if grep -q "JTAG chain broken" < "$TEMP" ; then
	echo "broken JTAG chain!"
	restart_jtagd
	STATUS=FAIL
fi

if [ "$STATUS" != "OK" ] ; then
	if [ $retries -lt 1 ] ; then
		echo "no retries left, something is wrong, here is the log file... " 1>&2
		cat "$TEMP" 1>&2
		rm -f "$TEMP"
		exit 1
	else
		sh $0 $(expr $retries - 1)
		exit $?
	fi
fi

echo "JTAG seems to be working OK"
rm -f "$TEMP"
exit 0
