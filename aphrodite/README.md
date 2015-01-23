mapa76-webapp [![Build Status](https://travis-ci.org/hhba/mapa76-webapp.png)](https://travis-ci.org/hhba/mapa76-webapp)
=============


Dependencies
------------

  * Ruby 1.9.3+
  * MongoDB
  * ElasticSearch


Install
-------

### Ruby 1.9.3+ ###

We recommend [rvm](https://rvm.io/rvm/install/) for installing and managing the
Ruby interpreter and environment. Refer to the [installation
page](https://rvm.io/rvm/install/) for instructions on installing Ruby 1.9+.
with `rvm`.

### MongoDB ###

On Debian / Ubuntu machines, install from the package manager:

    # apt-get install mongodb-server

### ElasticSearch ###

You need Java 6 (or newer) to run ElasticSearch. If on Debian / Ubuntu, you can
install OpenJDK JRE from the package manager:

    # apt-get install openjdk-7-jre

Then, download and install the .deb package:

    $ wget https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.20.1.deb
    # dpkg -i elasticsearch-0.20.1.deb

There are alternative downloads [here](http://www.elasticsearch.org/download/).

### Gems ###

First, run `bundle install` to install all gem dependencies.

    $ bundle install


Usage
-----

To start the web application, from the cloned directory, run:

    $ rails server

Docker
------

If you are lazy and you don't want to deal with so much installation, you can run:

    docker run -d -p 27017:27017 -v /data/mongodb:/data/db --name mongodb dockerfile/mongodb
    docker run -d -p 9200:9200 -p 9300:9300 -v /data:/data --name elasticsearch dockerfile/elasticsearch /elasticsearch/bin/elasticsearch -Des.config=/data/elasticsearch.yml
    docker run -d -p 6379:6379 -v /data:/data --name redis dockerfile/redis

And you will have mongodb, elasticsearch and redis working on your computer, then you can run:

    docker build -t aphrodite .
    docker run -p 8080:8080 --rm --env-file=config.dat

Where `rails-env.conf` looks like:

    MANDRILL_USERNAME=mail@example.org
    MANDRILL_API_KEY=APIKEY
    NOTIFICATION_EMAIL=info@analice.me
    MONGO_DB=mapa76
    MONGO_URL=192.168.59.103:27017
    REDIS_DB=192.168.59.103:6379:0
    ELASTICSEARCH_URL=http://192.168.59.103:9200
