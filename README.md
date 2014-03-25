Mapa76
======

This proyect is composed of three applications:
  * [Hephaestus](http://en.wikipedia.org/wiki/Hephaestus): Workers and background tasks
  * [Aphrodite](http://en.wikipedia.org/wiki/Aphrodite): Web application
  * [Chaos](http://en.wikipedia.org/wiki/Chaos): Core models and libs
  * [Aeolus](http://en.wikipedia.org/wiki/Aeolus): JS app

Dependencies
------------

  * Ruby 1.9.3
  * Bundler (`bundler` gem)
  * MongoDB server
  * Redis server
  * [Docsplit dependencies](http://documentcloud.github.com/docsplit/#installation)
  * FreeLing 3.0
  * Poppler 0.20+

Install: Hephaestus
-------------------

### Ruby 1.9.3 ###

    
    $ \curl -sSL https://get.rvm.io | bash -s stable --ruby
    $ source ~/.bashrc
    $ rvm install ruby-1.9.3
    $ rvm use 1.9.3 --default

We recommend [rvm](https://rvm.io/rvm/install/) for installing and managing the
Ruby interpreter and environment. Refer to the [installation
page](https://rvm.io/rvm/install/) for instructions on installing Ruby 1.9.3
with `rvm`.

### MongoDB and Redis servers ###

On Debian / Ubuntu machines, install from the package manager:

    # apt-get install mongodb mongodb-server redis-server

### Clone the repository

    # apt-get install git
    $ git clone git@github.com:hhba/mapa76.git

### Gems ###

First, run `bundle install` to install all gem dependencies.

    $ cd mapa76
    $ cd aphrodite
    $ bundle install


### Setup your config files ###

Create your MongoDB and Resque configuration files based on the sample files,
and modify the connection options to suit your needs:

    $ cp config/mongoid.yml.sample config/mongoid.yml
    $ cp config/resque.yml.sample config/resque.yml
    $ cp config/elasticsearch.yml.sample config/elasticsearch.yml
    $ cp config/application.yml.sample config/application.yml

If the servers will be running on the same machine as Mapa76, you don't need to
change anything.

### Install Node.js ###

    $ curl https://raw.github.com/creationix/nvm/v0.3.0/install.sh | sh
    $ source ~/.bashrc
    $ nvm install 0.10
    $ nvm alias default 0.10
    
### Test web engine ###
    $ rails s

### Docsplit ###

You should also install most of the
[dependencies](http://documentcloud.github.com/docsplit/#installation) listed
in Docsplit documentation.

### Poppler ###

Download the tarball of [Poppler
0.20.1](http://poppler.freedesktop.org/poppler-0.20.1.tar.gz) and extract it
somewhere, like `/usr/local/src`.

Run `apt-get build-dep poppler-utils` to make sure you have all of its
dependencies.  Then, just execute `./configure`, `make` and `make install` as
usual.

### FreeLing ###

The NER module currently uses FreeLing, an open source suite of language
analyzers written in C++.

#### Download ####

This has been tested on *FreeLing 3.0a1* only. Because this is an alpha
release, there are no binary packages available. You can download the source
[here](http://devel.cpl.upc.edu/freeling/downloads/16) (114Mb~) and compile it.
If you are a happy Ubuntu user, check out [this](http://devel.cpl.upc.edu/freeling/downloads?order=time&desc=1)
link. You will be able to find *.deb* easily to use files.

#### Compile and Install ####

For compiling the source, you need the `build-essential`, `libboost` and
`libicu` libraries. On Debian / Ubuntu machines, you can run:

    # apt-get install build-essential libboost-dev libboost-filesystem-dev \
                      libboost-program-options-dev libboost-regex-dev \
                      libicu-dev

Then, just execute `./configure`, `make` and `make install` as usual.

Usage: Hephaestus
-----------------

To start workers for document processing, you need to run at least one Resque
worker:

    $ QUEUE=* bundle exec rake resque:work

you can run multiple workers with the `resque:workers` task:

    $ COUNT=2 QUEUE=* bundle exec rake resque:workers

Install: Aphrodite
------------------

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

Keep in mind that elasticsearch produces a large amount of logs, so it's a good idea to setup a logrotate for this tool. Also, elasticsearch needs to keep lots of files open simultaneously so you'll probably need to run this (for the elasticsearch runner user):

    $ ulimint -n 32000

For more information about this issue, please [read](http://www.elasticsearch.org/tutorials/too-many-open-files/).

There are alternative downloads [here](http://www.elasticsearch.org/download/).

### Gems ###

First, run `bundle install` to install all gem dependencies.

    $ bundle install
