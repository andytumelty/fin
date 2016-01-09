#!/bin/bash
# docker-compose.yml specifies build, but building here means the image can be
# cached before future stop and remove steps later
project="fin"
compose_file="web/docker-compose.yml"
docker-compose -p $project -f $compose_file build 
docker-compose -p $project -f $compose_file stop fin 
docker-compose -p $project -f $compose_file rm -f fin
docker-compose -p $project -f $compose_file up -d --no-recreate
i=0
while [[ -z "$(docker-compose -f $compose_file -p $project ps db | grep Up)" && $i -lt 5 ]]; do
  sleep 1
  let i+=1
done
if [[ -z "$(docker-compose -f $compose_file -p $project ps db | grep Up)" ]]; then
  >&2 echo "ERROR: db not up after waiting for 5 seconds"
  exit 2
fi
docker-compose -p $project -f $compose_file run -e RAILS_ENV=production fin bundle exec rake db:migrate db:schema:load
docker-compose -p $project -f $compose_file run -e RAILS_ENV=production fin bundle exec rake db:seed
$(dirname $0)/clean-containers.sh
