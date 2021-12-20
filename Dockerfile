FROM ubuntu:18.04
MAINTAINER Guillaume Salva <guillaume@holbertonschool.com>

RUN apt-get update
RUN apt-get -y upgrade
# curl/wget/git
RUN apt-get install -y curl wget git tar
# vim/emacs
RUN apt-get install -y vim emacs
# C
RUN apt-get install -y build-essential gcc

# Set the locale
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Node 12
RUN curl -sl https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get update && apt-get install -y nodejs

# MongoDB
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.2.list
RUN apt-get update
RUN mkdir -p /data/db
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles
RUN apt-get install -y tzdata
RUN apt-get install -y mongodb-org
ADD init.d-mongod /etc/init.d/mongod
RUN chmod u+x /etc/init.d/mongod

# Install redis server and the redis client
RUN apt-get -y install redis-server

RUN sed -i "s/bind .*/bind 127.0.0.1/g" /etc/redis/redis.conf

RUN mkdir /tmp/node_packages
COPY package.json /tmp/node_packages/package.json
RUN cd /tmp/node_packages && npm install

# Man
RUN apt-get -y install man manpages-dev manpages-posix-dev
RUN yes | unminimize

# SSH
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config
RUN sed -ri 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN sed -i 's/# set bell-style none/set bell-style none/g' /etc/inputrc

ADD run.sh /tmp/run.sh
RUN chmod u+x /tmp/run.sh

# start run!
CMD ["./tmp/run.sh"]
