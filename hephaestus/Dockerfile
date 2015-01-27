FROM malev/hephaestus-base
MAINTAINER marcosvanetta@gmail.com

RUN git clone https://github.com/hhba/mapa76.git /app

WORKDIR /app/hephaestus
RUN bundle install --deployment --quiet --without development test

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV APP_ENV production

CMD bundle exec rake resque:work
