#!/bin/bash
#su postgres -c "/usr/lib/postgresql/12/bin/postgres -D /var/lib/postgresql/12/main -c config_file=/etc/postgresql/12/main/postgresql.conf"
pg_ctlcluster 12 main start

echo "[hit enter key to exit] or run 'docker stop <container>'"
read -p "Press enter key to stop"

pg_ctlcluster 12 main stop

echo "exited $0"
