Mapa76
======

This proyect is composed of three applications:

  * [Hephaestus](http://en.wikipedia.org/wiki/Hephaestus): Workers and background tasks
  * [Aphrodite](http://en.wikipedia.org/wiki/Aphrodite): Web application
  * [Chaos](http://en.wikipedia.org/wiki/Chaos): Core models and libs
  * [Aeolus](http://en.wikipedia.org/wiki/Aeolus): JS app

## General dependencies

  * Ruby 2.1.2
  * Bundler (`bundler` gem)
  * Nokogiri dependencies
  * MongoDB server
  * Redis server
  * elasticsearch
  * Node.js
  * Docsplit
  * FreeLing 3.1
  * Poppler 0.20+

### Ruby 2.1.2 ###

It's highly recommended that you install a Ruby version manager as [RVM](http://rvm.io/) or [Rbenv](https://github.com/sstephenson/rbenv).

    $ \curl -sSL https://get.rvm.io | bash -s stable --ruby
    $ source ~/.bashrc
    $ rvm install ruby-2.1.2
    $ rvm use 2.1.2 --default

We recommend [rvm](https://rvm.io/rvm/install/) for installing and managing the
Ruby interpreter and environment. Refer to the [installation
page](https://rvm.io/rvm/install/) for instructions on installing Ruby 2.1.2
with `rvm`.

### Nokogiri dependencies ###

    # apt-get install libxslt-dev libxml2-dev

### MongoDB and Redis servers ###

On Debian / Ubuntu machines, install from the package manager:

    # apt-get install mongodb mongodb-server redis-server

### ElasticSearch ###

You need Java 6 (or newer) to run ElasticSearch. If on Debian / Ubuntu, you can
install OpenJDK JRE from the package manager:

    # apt-get install openjdk-7-jre

Then, download and install the .deb package:

    $ wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb
    # dpkg -i elasticsearch-1.3.2.deb

Keep in mind that elasticsearch produces a large amount of logs, so it's a good idea to setup a logrotate for this tool. Also, elasticsearch needs to keep lots of files open simultaneously so you'll probably need to run this (for the elasticsearch runner user):

    $ ulimint -n 32000

For more information about this issue, please [read](http://www.elasticsearch.org/tutorials/too-many-open-files/).

There are alternative downloads [here](http://www.elasticsearch.org/download/).

### Install Node.js ###

    $ curl https://raw.github.com/creationix/nvm/v0.3.0/install.sh | sh
    $ source ~/.bashrc
    $ nvm install 0.10
    $ nvm alias default 0.10

### Docsplit (dependencies) ###

Install Docsplit dependencies

    # apt-get install -y graphicsmagick poppler-utils poppler-data ghostscript pdftk libreoffice

Detailed [dependencies](http://documentcloud.github.com/docsplit/#installation) listed
in Docsplit documentation.

### Poppler ###

Download the tarball of [Poppler 0.20.1](http://poppler.freedesktop.org/poppler-0.20.1.tar.gz) and extract it somewhere, like `/usr/local/src`.

Run `apt-get build-dep poppler-utils` to make sure you have all of its
dependencies.  Then, just execute `./configure`, `make` and `make install` as
usual.

### FreeLing ###

The NER module currently uses FreeLing, an open source suite of language
analyzers written in C++.

#### Download ####

This has been tested on *FreeLing 3.1*. You can download the source [here](http://devel.cpl.upc.edu/freeling/downloads/32) (147Mb~) and compile it. If you are a happy Ubuntu user, check out [this](http://devel.cpl.upc.edu/freeling/downloads?order=time&desc=1) link. You will be able to find *.deb* easily to use files.

#### Compile and Install ####

For compiling the source, you need the `build-essential`, `libboost` and
`libicu` libraries. On Debian / Ubuntu machines, you can run:

    # apt-get install build-essential libboost-dev libboost-filesystem-dev \
                      libboost-program-options-dev libboost-regex-dev \
                      libicu-dev

Then, just execute `./configure`, `make` and `make install` as usual.

## Clone the repository

    # apt-get install git
    $ git clone git@github.com:hhba/mapa76.git

### Gems ###

First, run `bundle install` to install all gem dependencies.

    $ cd mapa76
    $ cd aphrodite
    $ bundle install
    $ cd ../hephaestus
    $ bundle install
    $ cd ../aeolus


### Setup your config files ###

Both, **aphrodite** and **hephaestus** are ruby applications and each one of them has their own configuration files. They live in `./config` and they have `.yml` extensions. You need to adjust them to your workstation needs. For easy setup, just rename `*.yml.sample` to `*.yml`.

If the servers will be running on the same machine as Mapa76, you don't need to
change anything.

### Install Aeoluos dependencies

Just follow the instructions [here](https://github.com/hhba/mapa76/blob/master/aeolus/README.md).

## Up and Running

You will need to run the aeolus file watcher:

    $ cd aeolus
    $ grunt w

Fire Rails app:

    $ cd aphrodite
    $ rails s

To start workers for document processing, you need to run at least one Resque
worker:

    $ cd hephaestus
    $ QUEUE=* bundle exec rake resque:work

you can run multiple workers with the `resque:workers` task:

    $ COUNT=2 QUEUE=* bundle exec rake resque:workers

And you also need to `freeling` as a server. The `.sh` file only works in OSX, but it shouldn't be hard to make it work on Ubuntu:

    $ cd hephaestus
    $ sh ./start-freeling.sh

## TODO

* Split workers from web app.
* Upgrade to Rails 4.
