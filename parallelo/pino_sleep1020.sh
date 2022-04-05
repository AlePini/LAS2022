#!/bin/bash

# Esercizio: si realizzi uno script che lancia i comandi sleep 10  e sleep 20 in parallelo,
# e che ogni 5 secondi scriva su STDOUT il loro stato (in esecuzione / terminato)

sleep 10 &
A=$!

sleep 20 &
B=$!

#echo $A $B

while sleep 5
do
    ps $A > /dev/null && echo $A running || echo $A terminated
    ps $B > /dev/null && echo $B running || echo $B terminated
    if !(ps $A || ps $B) > /dev/null; then break; fi
done
