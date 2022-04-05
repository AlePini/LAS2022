#!/bin/bash -x

# estensione es 4. conversione e manipolazione del tempo con supporto a eliminazione di eventi dal calendario

FILEALLARMI=$(mktemp)
echo -n > "$FILEALLARMI"
cat calendario | while read DATA ORA DESCRIZIONE 
do
   SCADENZA=$(date +%s -d "$DATA $ORA") # conversione in secondi dal 1970-01-01 01:00
   GIORNOPRIMA=$(( SCADENZA - 24*60*60 ))
   ORAPRIMA=$(( SCADENZA - 60*60 ))
   echo "$GIORNOPRIMA $DATA $ORA $DESCRIZIONE" >> "$FILEALLARMI"
   echo "$ORAPRIMA $DATA $ORA $DESCRIZIONE" >> "$FILEALLARMI"
done

function syncAllarmCalendar(){
    REG="^.*("
    PROMREG="^("
    cat calendario | { while read DATA ORA DESCRIZIONE
    do
	    REG="$REG$DATA $ORA $DESCRIZIONE|"
	    PROMREG="$PROMREG$DESCRIZIONE scade il $DATA alle $ORA|"
    done
    REG="${REG::-1})$"
    PROMREG="${PROMREG::-1})$"
    
    if grep -Ev "$REG" "$FILEALLARMI"; then
	    GREP=$(grep -E "$REG" "$FILEALLARMI")
	    echo "$GREP" > $FILEALLARMI # leggi e scrivi su un file
	
	    GREP=$(grep -E "$PROMREG" ~/promemoria)
	    echo "$GREP" > ~/promemoria
    fi
    }
}

# ho necessità di far eseguire il controllo una e una sola volta ogni minuto, 
# una possibilità è ciclare più di frequente e controllare se il minuto cambia
# in questo modo compenso anche l'imprevedibilità dei tempi di esecuzione
# del corpo del ciclo (mentre se usassi sleep 60 potrei andare alla deriva)
NOW=0
while sleep 20 ; do
    [[ $(date +%M) -eq $NOW ]] && continue
    NOW=$(date +%M)

    syncAllarmCalendar

    # nota: i timestamp originali hanno la granularità del minuto, 
    # ma il tempo corrente considera i secondi, devo troncarli
    # trick, ma si può fare in altri modi: la divisione per 60 restituisce un intero...
    CURRENTMINUTE=$(( $(date +%s) / 60 * 60))

    # nota: ci possono essere zero, una o più righe col timestamp corrente
    # grep | while è il modo più semplice di gestirle, un'iterazione per ogni riga
    # incluso il caso di zero iterazioni nei minuti per cui non ci sono corrispondenze
    egrep "^$CURRENTMINUTE" "$FILEALLARMI" | while read TIMESTAMP DATA ORA DESCRIZIONE ; do
	  echo "$DESCRIZIONE scade il $DATA alle $ORA"
      done >> ~/promemoria
done
