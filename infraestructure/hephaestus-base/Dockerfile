FROM malev/freeling
MAINTAINER marcosvanetta@gmail.com

RUN apt-get update
RUN apt-get install -qy git git-core build-essential
RUN apt-get install -qy zlib1g-dev libxml2-dev libxslt1-dev\
            graphicsmagick poppler-utils poppler-data ghostscript pdftk\
            libreoffice

WORKDIR /tmp
RUN wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
RUN tar -xzvf ruby-install-0.5.0.tar.gz
WORKDIR ruby-install-0.5.0/
RUN make install
RUN ruby-install ruby 2.1.2
RUN PATH=/opt/rubies/ruby-2.1.2/bin:$PATH gem install bundler
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV PATH /opt/rubies/ruby-2.1.2/bin:$PATH
