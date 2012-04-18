Mapa76
======

Main repository for [Mapa76 project](http://mapa76.info/) (in spanish).


Dependencies
------------

  * Ruby 1.9+
  * Bundler (`bundler` gem)
  * MongoDB server
  * FreeLing 3.0


Install
-------

First, run `bundle install` to install all gem dependencies.

    $ bundle install

Create your MongoDB configuration file based on the sample file, and modify the
connection options to suit your needs:

    $ cp config/mongoid.yml.sample config/mongoid.yml


### FreeLing ###

The NER module currently uses FreeLing, an open source suite of language
analyzers written in C++.

#### Download ####

This has been tested on *FreeLing 3.0a1* only. Because this is an alpha
release, there are no binary packages available. You can download the source
[here](http://devel.cpl.upc.edu/freeling/downloads/16) (114Mb~) and compile it.

#### Compile and Install ####

For compiling the source, you need the `libboost` and `libicu` libraries. On
Debian / Ubuntu machines, you can run:

    # apt-get install libboost-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev libicu-dev

Then, just execute `./configure`, `make` and `make install` as usual.


Usage
-----

Start the Padrino server and visit [http://localhost:3000/](http://localhost:3000/)

    $ bundle exec padrino start

