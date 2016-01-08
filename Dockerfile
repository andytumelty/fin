FROM ruby:2.2.0
RUN apt-get -qqy update && \
    apt-get -qqy install build-essential libpq-dev nodejs
# rails runs pg_dump on db:migrate, so need this installed
# see https://github.com/docker-library/rails/issues/13
RUN apt-get -qqy update && \
    apt-get -qqy install postgresql-client --no-install-recommends
# for amex headless
RUN apt-get -qqy update && \
    apt-get -qqy install xvfb iceweasel
RUN rm -rf /var/lib/apt/lists/*
RUN mkdir /fin
WORKDIR /fin
ADD Gemfile /fin/Gemfile
ADD Gemfile.lock /fin/Gemfile.lock
RUN bundle install
ADD . /fin
RUN RAILS_ENV=production bundle exec rake assets:precompile --trace
