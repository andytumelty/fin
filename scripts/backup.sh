#!/bin/bash
base_dir="$(dirname $0)/.."
. $base_dir/scripts/vars.sh

db="fin"
u="fin"
pw="fin"

cid="$(docker-compose -p $project -f $compose_file ps -q db)"
cip="$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $cid)"

filename=fin_db_$(date +%FT%H-%M-%S).sql

echo "$cip:5432:$db:$u:$pw" > ~/.pgpass
chmod 600 ~/.pgpass

# don't move to backups right away: check if there's already a backup of the
# same content to prevent Dropbox picking up a create & immediate delete
pg_dump -U $u -h $cip $db > $base_dir/$filename

hash=$(md5sum $base_dir/$filename | cut -d ' ' -f 1)
count=$(grep -c "$hash" <<<"$(md5sum $base_dir/backups/*)")

if [[ $count -eq 0 ]]; then
  mv $base_dir/$filename $base_dir/backups/$filename
else
  echo "Like backup already exists, removing"
  rm $base_dir/$filename
fi
