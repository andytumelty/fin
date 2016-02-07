#!/bin/bash
# cleans up stopped application containers specific to fin
# todo: currently uses current dir to determine project name: change this
# todo: add parameter to clean up containers based on given service name

base_dir="$(dirname $0)/.."
. $base_dir/scripts/vars.sh

service="fin"

docker-compose -f $compose_file -p $project rm -f "$service"

ids=$(docker ps -a -q -f name="$project_$service" -f status=exited)
count=$(wc -w <<< "$ids")
echo "Found $count containers"

if [ $count -gt 0 ]; then
  i=0
  while read id; do
    let i+=1
    echo "($i/$count) $(docker rm $id)"
  done <<< "$ids"
fi
