FROM malev/aphrodite-base
MAINTAINER marcosvanetta@gmail.com

RUN git clone https://github.com/hhba/mapa76.git /app

WORKDIR /app/aeolus

RUN npm install
RUN cp config.json.example config.json
RUN grunt dist
RUN rm -f /app/aphrodite/app/assets/javascripts/aeolus/*.js
RUN cp /app/aeolus/dist/js/*.js /app/aphrodite/app/assets/javascripts/aeolus/

WORKDIR /app/aphrodite
RUN bundle install --deployment --quiet --without development test

ENV RAILS_ENV production
RUN rake assets:precompile:all

EXPOSE 8080
CMD unicorn
