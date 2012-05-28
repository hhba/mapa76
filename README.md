Mapa76
======

Main repository for [Mapa76 project](http://mapa76.info/) (in spanish).


Dependencies
------------

  * Ruby 1.9+
  * Bundler (`bundler` gem)
  * MongoDB server
  * Redis server
  * [Docsplit dependencies](http://documentcloud.github.com/docsplit/#installation)
  * FreeLing 3.0


Install
-------

### Ruby 1.9 ###

We recommend [rvm](https://rvm.io/rvm/install/) for installing and managing the
Ruby interpreter and environment. Refer to the [installation
page](https://rvm.io/rvm/install/) for instructions on installing Ruby 1.9+.
with `rvm`.

### MongoDB and Redis servers ###

On Debian / Ubuntu machines, install from the package manager:

    # apt-get install mongodb mongodb-server redis-server

### Gems ###

First, run `bundle install` to install all gem dependencies.

    $ bundle install

Create your MongoDB and Resque configuration files based on the sample files,
and modify the connection options to suit your needs:

    $ cp config/mongoid.yml.sample config/mongoid.yml
    $ cp config/resque.yml.sample config/resque.yml

If the servers will be running on the same machine as Mapa76, you don't need to
change anything.

### Docsplit ###

You should also install most of the
[dependencies](http://documentcloud.github.com/docsplit/#installation) listed
in Docsplit documentation.

### FreeLing ###

The NER module currently uses FreeLing, an open source suite of language
analyzers written in C++.

#### Download ####

This has been tested on *FreeLing 3.0a1* only. Because this is an alpha
release, there are no binary packages available. You can download the source
[here](http://devel.cpl.upc.edu/freeling/downloads/16) (114Mb~) and compile it.

#### Compile and Install ####

For compiling the source, you need the `build-essential`, `libboost` and
`libicu` libraries. On Debian / Ubuntu machines, you can run:

    # apt-get install build-essential libboost-dev libboost-filesystem-dev \
                      libboost-program-options-dev libboost-regex-dev \
                      libicu-dev

Then, just execute `./configure`, `make` and `make install` as usual.


Usage
-----

Start the Padrino server and visit [http://localhost:3000/](http://localhost:3000/)

    $ bundle exec padrino start

To start workers for document processing, you need to run at least one Resque
worker:

    $ QUEUE=* VERBOSE=1 bundle exec rake resque:work

you can run multiple workers with the `resque:workers` task:

    $ COUNT=2 QUEUE=* bundle exec rake resque:workers


Restart to 0
------------

To remove everything from the database and restart all to 0 just run:

    $ rake mi:drop && redis-cli FLUSHALL && rake anm:load


