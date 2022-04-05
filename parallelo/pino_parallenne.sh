#!/bin/bash

# Esecizione parallela generalizzata

# Estendere l'esempio dell'esecuzione di due job in parallelo, sleep1020
# Realizzare uno script parallenne.sh che
    # lanci in parallelo tutti i comandi forniti come parametri
    # controlli ogni 5 secondi quali sono ancora in esecuzione, verificando che il PID corrisponda al nome del comando
    # scriva a ogni controllo sul file "log" lo stato dei processi 
    # termini quando tutti i processi in background sono terminati
    # garantisca la terminazione di tutti i processi in background se viene terminato dall'esterno il processo parallenne

test $# -lt 1 && { echo "Usage: parallenne [commands...]"; exit 1; }

LOGFILE="./parallenne.log"

# Launch every command passed and saving it's PID
for COMMAND in "$@"
do
    $COMMAND & PID[$!]="$COMMAND"
    echo "PID[$!] = $COMMAND"
done

handler()
{
    echo "Quitting..."
    # killing every process in PID
    for ID in ${!PID[@]}
    do
	    kill -INT $ID 2>/dev/null
    done
    exit 2
}

# setting handler
trap handler SIGINT

while sleep 5
do
    # if no process is running, then RUN=0 and exit
    RUN=0

    # check process status
    for ID in ${!PID[@]}
    do
        if ps $ID | grep "${PID[$ID]}" > /dev/null; then
            echo $ID running >> $LOGFILE
            RUN=1
        else	    
            echo $ID terminated >> $LOGFILE
            RUN=$RUN || 0
        fi
    done
    if [[ $RUN -eq 0 ]]; then echo "Finished!"; break; fi
done
