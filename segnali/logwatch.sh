#!/bin/bash -x

report () {
	echo $(date) osservate $TOT nuove righe
	TOT=0
}

test $# -lt 1 && { echo "Usage: parallenne file";	exit 1; }
test -f "$1" || { echo "Not valid file"; exit 2; }

# il problema principale è che command | builtin crea una subshell per la builtin
# -> shell_processi.pdf 21/32
# tanto vale esplicitare la subshell e spostarci tutto il codice che gestisce handler

TOT=0
tail -n +0 -f "$1" | (
	echo $BASHPID > /tmp/logwatch.pid
	trap report USR1
	while read R ; do
		TOT=$(( $TOT + 1 ))
	done
)
