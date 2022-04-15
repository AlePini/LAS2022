#!/bin/bash
# Se il carico del sistema è inferiore ad una soglia specificata 
# come primo parametro dello script, lancia il comando specificato
# come secondo parametro.
# Altrimenti, con at, rischedula il test dopo 2 minuti, e procede
# così finchè non riesce a lanciare il comando.

THIS=$(realpath $0)
MAX_TENTATIVI=1
SOGLIA_CARICO=5

while getopts 'n:s:' OPTION; do
    case $OPTION in
	n) MAX_TENTATIVI="$OPTARG"
	    ;;
	s) SOGLIA_CARICO="$OPTARG"
	    ;; 
	?) printf "Usage: %s: [-a] [-b value] args\n" $(basename $0) >&2
	    exit 2
	    ;;
    esac
done
shift $(($OPTIND - 1))

# $1 deve essere eseguibile, file standard e con path assoluto 
# per evitare problemi con l'environment di atd
if ! [[ -x "$1" && -f "$1" && "$1" =~ ^/ ]] ; then
	echo "$1" non è un eseguibile con path assoluto
	exit 1
fi

# ipotesi semplificativa: solo la parte intera del carico a 1 minuto
# per farlo, devo sapere qual è il delimitatore dei decimali 
# in accordo alla localizzazione attiva: man locale
LOAD=$(uptime | awk -F 'average: ' '{ print $2 }' | cut -f1 -d$(locale decimal_point))
if [[ $LOAD -lt "$SOGLIA_CARICO" ]] ; then
	shift
	eval "$@"
elif [[ $MAX_TENTATIVI -gt 0 ]]; then
    echo $THIS -n $(($MAX_TENTATIVI - 1)) -s $SOGLIA_CARICO "$@" | at now +2 minutes
else
    echo "No more try"
    exit 1
fi
