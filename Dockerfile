# /!\ Note: This file is ignored until the `build: .` step in docker-compose.yml.
# /!\ Note:  The bundle version number is explicity set else bundle fails during our
# /!\ Note: later step "docker-compose up" with:
# /!\ Note:   web_1  | bundler: failed to load command: rails (/usr/local/bundle/bin/rails)
# /!\ Note:   web_1  | Bundler::GemNotFound: Could not find gem 'pg' in any of the gem sources listed in your Gemfile.

FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /myapp
WORKDIR /myapp
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler -v 1.11.2
RUN bundle _1.11.2_ install
ADD . /myapp
