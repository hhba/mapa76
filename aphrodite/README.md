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

