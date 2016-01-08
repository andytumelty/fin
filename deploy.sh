#!/bin/sh
docker-compose build
# stop existing container? maybe just specify fin to rebuild app?
# how to manage data migration? ideally no need to constantly run db rebuild
docker-compose up -d
docker-compose run -e RAILS_ENV=production fin bundle exec rake db:migrate db:schema:load
docker-compose run -e RAILS_ENV=production fin bundle exec rake db:seed
