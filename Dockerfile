FROM ruby:2.2.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
# rails runs pg_dump on db:migrate, so need this installed
# see https://github.com/docker-library/rails/issues/13
RUN apt-get update && apt-get install -y postgresql-client --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN mkdir /fin
WORKDIR /fin
ADD Gemfile /fin/Gemfile
ADD Gemfile.lock /fin/Gemfile.lock
RUN bundle install
ADD . /fin
RUN RAILS_ENV=production bundle exec rake assets:precompile --trace
