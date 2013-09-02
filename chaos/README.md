# Mapa76::Core [![Build Status](https://secure.travis-ci.org/hhba/mapa76-core.png?branch=master)](https://travis-ci.org/hhba/mapa76-core) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/hhba/mapa76-core) #

Core models and libs of the [Mapa76 project](http://mapa76.info/) (in spanish).

This is used by the [webapp](https://github.com/hhba/mapa76-webapp) and the
[processing pipeline](https://github.com/hhba/mapa76).

## Testing ##

### Prerequisites ###

  * MongoDB server

### Running the tests ###

    $ bundle exec rake test

You can also use Guard for autotesting:

    $ bundle exec guard

Any changes made to the models or a lib will be detected by Guard and it will
run its associated test automatically.
