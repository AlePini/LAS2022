#!/bin/bash

# Estensioni parametrico

# Modificare l'esercizio delle estensioni realizzando uno script estparam.sh che accetti sulla riga di comando
    # nome di una directory da esplorare
    # elenco di lunghezza arbitraria di stringhe
# Lo script deve contare quanti file esistono nel sottoalbero definito dalla directory passata come primo parametro,
# che abbiano estensione uguale a una delle stringhe specificate coi parametri successivi.
# ./estparam /etc conf inc

if [ $# -lt 2 ]; then
    echo "Usage: estparam [dir] [extensions...]"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "First parm must be a valid directory"
    exit 1
fi


# save first param
DIR="$1"
shift

# REG="\.(ext|ext|ext)$"
REG="\.("
for ESTENSIONE in "$@"
do
    REG="$REG$ESTENSIONE|"
done
# delete last "or" in the regex and append ")$"
REG="${REG::-1})$"

find "$DIR" -type f | egrep "$REG" -o | sort | uniq -c

