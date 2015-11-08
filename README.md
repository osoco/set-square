# set-square

*set-square* is a tool to streamline the building of Docker images,
allowing the use of simple placeholders within Dockerfiles.

The main idea was borrowed from wking's tool, and was adapted to be
as simple to use as possible.

# Motivation

This tool allows building Docker images from Dockerfile templates.
It relies upon ```envsubst```, so fear not: it doesn't convert Dockerfiles
into Turing machines. It focuses exclusively on allow using variable
placeholders which get resolved *at build time*.

If you build your own images for third-party services such us Tomcat,
MariaDB, RabbitMQ, etc., and the only difference from the image's
point of view is the version of the package it bundles, then *set-square*
alleviates you from the hassle of maintaining the different dockerfiles.

*set-square* uses [dry-wit](https://github.com/rydnr/dry-wit), so it
supports default values for variables. The user can easily choose which
variables to override, and which don't.

# Installation

    git clone --recurse-submodules https://github.com/rydnr/set-square
    cd set-square
    git submodules init
    git submodules update

# Example

Let's say you want to implement your own PostgreSQL image,
based on the official Dockerfile ([available in github](https://github.com/docker-library/docs/tree/master/postgres).

    # vim:set ft=dockerfile:
    FROM debian:jessie
    
    # explicitly set user/group IDs
    RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres
    
    [..]

    ENV PG_MAJOR 9.3
    ENV PG_VERSION 9.3.10-1.pgdg80+1
    
    RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list
    
    RUN apt-get update \
    	&& apt-get install -y postgresql-common \
    	&& sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
    	&& apt-get install -y \
    		postgresql-$PG_MAJOR=$PG_VERSION \
    		postgresql-contrib-$PG_MAJOR=$PG_VERSION \
    	&& rm -rf /var/lib/apt/lists/*
    
    RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
    
    ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
    ENV PGDATA /var/lib/postgresql/data
    VOLUME /var/lib/postgresql/data
    
    COPY docker-entrypoint.sh /
    
    ENTRYPOINT ["/docker-entrypoint.sh"]
    
    EXPOSE 5432
    CMD ["postgres"]

However, you'd notice you'd like to specify certain information only when building the image,
not hard-coding it in the Dockerfile. For example:
  - *PG_MAJOR* and *PG_MINOR*,
  - The *Debian version* it's based on,
  - The *uid* and *gid* of the internal Postgres user account.

The Dockerfile you'd really want would be the following:

    # vim:set ft=dockerfile:
    FROM debian:${DEBIAN_VERSION}
    
    # explicitly set user/group IDs
    RUN groupadd -r postgres --gid=${POSTGRES_GID} && useradd -r -g postgres --uid=${POSTGRES_UID} postgres

    [..]
    # ENV PG_MAJOR 9.3
    # ENV PG_VERSION 9.3.10-1.pgdg80+1
    
    RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' ${PG_MAJOR} > /etc/apt/sources.list.d/pgdg.list
    
    RUN apt-get update \
    	&& apt-get install -y postgresql-common \
    	&& sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf \
    	&& apt-get install -y \
    		postgresql-${PG_MAJOR}=${PG_VERSION} \
    		postgresql-contrib-${PG_MAJOR}=${PG_VERSION} \
    	&& rm -rf /var/lib/apt/lists/*
    
    RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
    
    ENV PATH /usr/lib/postgresql/{}$PG_MAJOR/bin:$PATH
    ENV PGDATA /var/lib/postgresql/data
    VOLUME /var/lib/postgresql/data
    
    COPY docker-entrypoint.sh /
    
    ENTRYPOINT ["/docker-entrypoint.sh"]
    
    EXPOSE 5432
    CMD ["postgres"]

First, place this Dockerfile template as ```postgres/Dockerfile.template```.
Secondly, create a new settings file (```postgres/build-settings.sh```) for specifying the default value you will be using normally:

    defineEnvVar DEBIAN_VERSION "The Debian version" "jessie";
    defineEnvVar PG_MAJOR "The PostgreSQL major version" "9.3";
    defineEnvVar GP_VERSION "The complete PostgreSQL version" '${PG_MAJOR}.10-1.pgdg80+1';

You can now run set-square:

    ./build.sh -vv postgres

set-square will just transform any file within that folder which ends in *.template*,
and then ask Docker to build the image.

# Phusion-based images

You can review a number of Phusion-based images built Using *set-square* in
https://github.com/rydnr/set-square-phusion-images.

# Documentation

*set-square* is a [https://github.com/rydnr/dry-wit](dry-wit)-based Bash script.
It should be self-explanatory and easy to read (and customize or extend).

It the [https://github.com/rydnr/set-square/docs/](docs) folder there're some
slides describing both the tool and the motivation behind the
[https://github.com/rydnr/set-square-phusion-images](images) implemented using *set-square*.
