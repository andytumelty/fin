FROM ruby:2.2.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN mkdir /fin
WORKDIR /fin
ADD Gemfile /fin/Gemfile
ADD Gemfile.lock /fin/Gemfile.lock
RUN bundle install
ADD . /fin
