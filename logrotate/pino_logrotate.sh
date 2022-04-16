#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "You must run this script as root"
    exit 1
fi

if tty 1>/dev/null 2>&1 ; then
    echo "è un tty"

    TMP=$(mktemp)

    # configuro syslog   
    echo "local1.warning\t/var/log/my.log" > $TMP

    sudo cp $TMP /etc/rsyslog.d/logrotate.conf

    COMMAND="$(realpath $0)"
    PERIOD="0 23 * * *"
    crontab -l | grep -Fv "$CRONCOMMAND" > $TMP
    echo "$PERIOD $CRONCOMMAND" >> $TMP

    crontab $TMP

    rm -f $TMP
else
    echo "non è un tty"
    ls -r /var/log | grep -E '^my\.log\.[0-9]+\.bz2$' | while read FILE; do
	N=$(echo $FILE | cut -f3 -d . -)
	mv /var/log/my.log.$N.bz2 /var/log/my.log.$(($N + 1)).bz2p
    done
    
    mv /var/log/my.log /var/my.log.1
    bzip2 /var/log/my.log

    systemctl restart rsyslog
fi
