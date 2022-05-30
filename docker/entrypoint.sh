#!/bin/bash
# FIXME WTF - mysql driver cannot handle host
export MYSQL_HOST=$(dig +short db)

echo "starting..." && \
envsubst \$MYSQL_HOST,\$MYSQL_PORT,\$MYSQL_USER,\$MYSQL_DB,\$MYSQL_PASSWORD < /root/frs/config.template > /root/frs/config.config && \

# TODO wait while no connect to mysql
sleep 30 && \
# write logs into docker
/root/frs/build/frs --frs-config /root/frs/config.config 2>>/proc/1/fd/1

