#!/bin/bash

export HOMEPATH=/home/deploy
export PATH="$HOMEPATH/.rbenv/shims:$PATH"
export APP_ENV=production
cd $HOMEPATH/apps/mapa76.info/hephaestus/current && bundle exec rake monit:start

