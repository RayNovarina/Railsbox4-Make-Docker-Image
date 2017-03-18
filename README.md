# Railsbox4-Make-Docker-Image: March 17, 2017

# Based on Docker Tutorial "Compose and Rails" at: https://docs.docker.com/compose/rails/

1) Before starting, you’ll need to have Docker Compose installed.

Define the project
Start by setting up the four files you’ll need to build the app.

2) First, since your app is going to run inside a Docker container containing
all of its dependencies, you’ll need to define exactly what needs to be included
in the container. This is done using a file called Dockerfile.

.../railsbox4/Dockerfile:
``
    FROM ruby:2.3.3
    RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
    RUN mkdir /myapp
    WORKDIR /myapp
    ADD Gemfile /myapp/Gemfile
    ADD Gemfile.lock /myapp/Gemfile.lock
    RUN gem install bundler -v 1.11.2
    RUN bundle _1.11.2_ install
    ADD . /myapp
``
NOTE: The bundle version number is explicity set else bundle fails during our
later step "docker-compose up" with:
  web_1  | bundler: failed to load command: rails (/usr/local/bundle/bin/rails)
  web_1  | Bundler::GemNotFound: Could not find gem 'pg' in any of the gem sources listed in your Gemfile.

Soooo..... per https://discuss.circleci.com/t/bundler-fails-to-find-appropriate-version-despite-installing-appropriate-version-earlier-in-the-build/280
and
https://makandracards.com/makandra/9741-run-specific-version-of-bundler
use an old/different bundle version.

That’ll put your application code inside an image that will build a container
with Ruby, Bundler and all your dependencies inside it. For more information on
how to write Dockerfiles, see the Docker user guide and the Dockerfile reference.

3) Next, create a bootstrap Gemfile which just loads Rails. It’ll be overwritten
in a moment by rails new.
.../railsbox4/Gemfile:
``
    source 'https://rubygems.org'
    gem 'rails', '5.0.0.1'
``
You’ll need an empty Gemfile.lock in order to build our Dockerfile.
.../railsbox4/Gemfile.lock:
``

``

4) Finally, docker-compose.yml is where the magic happens. This file describes
the services that comprise your app (a database and a web app), how to get each
one’s Docker image (the database just runs on a pre-made PostgreSQL image, and
the web app is built from the current directory), and the configuration needed
to link them together and expose the web app’s port.

NOTE: The bundle version number is explicity set else bundle fails later.
.../railsbox4/docker-compose.yml:
``
    version: '2'
    services:
      db:
        image: postgres
      web:
        build: .
        command: bundle _1.11.2_ exec rails s -p 3000 -b '0.0.0.0'
        volumes:
          - .:/myapp
        ports:
          - "3000:3000"
        depends_on:
          - db
``

5) Build the project

With those four files in place, you can now generate the Rails skeleton app
using docker-compose run:

  $ docker-compose run web rails new . --force --database=postgresql --skip-bundle

First, Compose will build the image for the web service using the Dockerfile.
Then it’ll run rails new inside a new container, using that image. Once it’s
done, you should have generated a fresh app.

6) See what we ended up with:

  .../railsbox4/$ ls -l
  total 56
  -rw-r--r--   1 user  staff   215 Feb 13 23:33 Dockerfile
  -rw-r--r--   1 user  staff  1480 Feb 13 23:43 Gemfile
  -rw-r--r--   1 user  staff  2535 Feb 13 23:43 Gemfile.lock
  -rw-r--r--   1 root  root   478 Feb 13 23:43 README.rdoc
  -rw-r--r--   1 root  root   249 Feb 13 23:43 Rakefile
  drwxr-xr-x   8 root  root   272 Feb 13 23:43 app
  drwxr-xr-x   6 root  root   204 Feb 13 23:43 bin
  drwxr-xr-x  11 root  root   374 Feb 13 23:43 config
  -rw-r--r--   1 root  root   153 Feb 13 23:43 config.ru
  drwxr-xr-x   3 root  root   102 Feb 13 23:43 db
  -rw-r--r--   1 user  staff   161 Feb 13 23:35 docker-compose.yml
  drwxr-xr-x   4 root  root   136 Feb 13 23:43 lib
  drwxr-xr-x   3 root  root   102 Feb 13 23:43 log
  drwxr-xr-x   7 root  root   238 Feb 13 23:43 public
  drwxr-xr-x   9 root  root   306 Feb 13 23:43 test
  drwxr-xr-x   3 root  root   102 Feb 13 23:43 tmp
  drwxr-xr-x   3 root  root   102 Feb 13 23:43 vendor

.../railsbox4/$ docker images


.../railsbox4/$ docker-compose ps
