#!/bin/bash
project="fin"
compose_file="web/docker-compose.yml"

db="fin"
u="fin"
pw="fin"

cid="$(docker-compose -p $project -f $compose_file ps -q db)"
cip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $cid)"

echo "$cip:5432:$db:$u:$pw" > ~/.pgpass
chmod 600 ~/.pgpass

pg_dump -F c -U $u -h $cip $db > backups/fin_db_$(date +%FT%H-%M-%S).psql
