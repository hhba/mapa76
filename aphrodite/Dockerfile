FROM ruby:2.1.5
MAINTAINER marcosvanetta@gmail.com

RUN apt-get update -q
RUN apt-get install -y nodejs npm git git-core
RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN git clone https://github.com/hhba/mapa76.git /app
RUN npm config set registry http://registry.npmjs.org
RUN npm install -g grunt-cli

WORKDIR /app/aeolus

RUN npm install
RUN grunt prod
RUN cp /app/aeolus/dist/js/*.js /app/aphrodite/app/assets/javascripts/aeolus/

WORKDIR /app/aphrodite
RUN bundle install --deployment --quiet --without development test

ENV RAILS_ENV production
RUN rake assets:precompile:all

EXPOSE 8080
CMD unicorn
