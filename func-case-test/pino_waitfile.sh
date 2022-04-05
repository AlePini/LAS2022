#!/bin/bash

# Funzioni, case, test

# Realizzare una funzione waitfile che accetti
	# un primo parametro obbligatorio = nome di comando
	# un secondo parametro obbligatorio = nome di file
	# un terzo parametro facoltativo 

# La funzione deve 
	# controllare che il valore di $1 sia uno di ls, rm, touch
	# eseguire il comando $1 con parametro $2 (basta lanciare $1 $2) in modi diversi a seconda di $3 come spiegato di seguito

# Usando case, discriminare tre possibilità:
	# $3 è "force" --> esecuzione immediata
	# $3 è un numero "N" di una cifra decimale --> se $2 non esiste, aspetta che eventualmente compaia, riprovando al massimo N volte con un'attesa di 1 secondo tra un tentativo e il successivo (usare sleep 1)
	# $3 è assente o altro valore --> come caso precedente, considerando un valore di default N=10


# this is needed to extend pattern matching, otherwise +([0-9])) wouldn't work
shopt -s extglob

# Check if first argument exists and is correct
array=(ls rm touch)
[[ ${array[*]} =~ $1 ]] || { echo "Not valid first argument, must be [ls|rm|touch]"; exit 1; }

[[ -z $2 ]] && { echo "Second argument cannot be empty"; exit 2; }

case "$3" in
    force|"0")
	# skip while with -1
	N=-1
	echo "subito"
	;;
    +([0-9]))
	N=$3
	echo "trying $3 times"
	;;
    *)
	# default case
	N=10
	echo "trying 10 times, as default"
	;;
esac

# while but check if condition is false
until [[ -e $2 || N -le 0 ]] 
do
    ((N--))
    sleep 1
done

# check if while timed out
[[ N -eq 0 ]] && { echo "Timeout!!"; exit 3; }

echo "executing '$1 $2'"
$1 $2
