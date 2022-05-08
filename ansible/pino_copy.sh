#!/bin/bash

/usr/bin/tar --files-from /etc/save.list -cf "bck.$(/usr/bin/date -I).tgz"
