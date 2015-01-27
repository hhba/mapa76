FROM ruby:2.1.5
MAINTAINER marcosvanetta@gmail.com

RUN apt-get update -q
RUN apt-get install -y nodejs npm git git-core
RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN npm config set registry http://registry.npmjs.org
RUN npm install -g grunt-cli
