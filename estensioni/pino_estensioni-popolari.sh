# pipeline di filtri

# Contare quanti file esistono con una certa estensione, 
# definita come la stringa posta dopo l'ultimo carattere "punto"
# presente nel nome del file, per tutte le estensioni trovate nei file 
# presenti nel direttorio corrente e nei sottodirettori. 
# Limitare l'output alle sole 5 estensioni più numerose.

ls -R / 2>/dev/null | egrep '\.[a-zA-Z0-9]+$' -o | sort | uniq -c | sort -nr | head -n 5
