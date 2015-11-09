# set-square

*set-square* is a tool to streamline the building of Docker images,
allowing the use of simple placeholders within Dockerfiles.

The main idea was borrowed from [wking](https://github.com/wking/dockerfile)'s approach, and
later rewritten from scratch.

# Motivation

This tool allows building Docker images from Dockerfile templates.
It relies upon ```envsubst```, so fear not: it doesn't convert Dockerfiles
into Turing machines. It focuses exclusively on allow using variable
placeholders which get resolved *at build time*.

If you build your own images for third-party services such us Tomcat,
MariaDB, RabbitMQ, etc., and the only difference from the image's
point of view is the version of the package it bundles, then *set-square*
alleviates you from the hassle of constantly maintaining almost-identical
dockerfiles.

*set-square* uses [dry-wit](https://github.com/rydnr/dry-wit), and out-of-the-box
it supports default values for variables. The user can easily choose which
variables to override, and which don't.

# Installation

    git clone --recurse-submodules https://github.com/rydnr/set-square
    cd set-square
    git submodules init
    git submodules update

# Example

## PostgreSQL image

Let's say you want to define your own PostgreSQL image (for whatever reasons)
based on the official Dockerfile ([available in github](https://github.com/docker-library/docs/tree/master/postgres)).

    # vim:set ft=dockerfile:
    FROM debian:jessie
    
    # explicitly set user/group IDs
    RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres
    
    [..]

    ENV PG_MAJOR 9.3
    ENV PG_VERSION 9.3.10-1.pgdg80+1
    
    RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR \
        > /etc/apt/sources.list.d/pgdg.list
    
    RUN apt-get update \
    	&& apt-get install -y postgresql-common \
    	&& sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/...
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
to avoid modifying the Dockerfile every time it changes. For example:
  - *PG_MAJOR* and *PG_MINOR*,
  - The *Debian version* it's based on,
  - The *uid* and *gid* of the internal Postgres user account.

The Dockerfile you're thinking of would be the following:

    # vim:set ft=dockerfile:
    FROM debian:$DEBIAN_VERSION
    
    # explicitly set user/group IDs
    RUN groupadd -r postgres --gid=$POSTGRES_GID \
        && useradd -r -g postgres --uid=$POSTGRES_UID postgres

    [..]
    # ENV PG_MAJOR 9.3
    # ENV PG_VERSION 9.3.10-1.pgdg80+1
    
    RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR \
        > /etc/apt/sources.list.d/pgdg.list
    
    RUN apt-get update \
    	&& apt-get install -y postgresql-common \
    	&& sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/...
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

The differences are:
- ```PG_MAJOR``` and ```PG_MINOR``` are now Dockerfile variables, not environment variables
in the image itself. Of course, we could leave the original ```ENV``` steps if
we wanted to, but they are useless(*) and generate unnecessary cache layers.
- ```DEBIAN_VERSION```, ```POSTGRES_UID``` and ```POSTGRES_GID``` are now placeholders.

## Building the image

First, place this Dockerfile template as ```postgres/Dockerfile.template```.
Secondly, create a new settings file (```postgres/build-settings.sh```) for specifying the default value you will be using normally:

    defineEnvVar DEBIAN_VERSION "The Debian version" "jessie";
    defineEnvVar PG_MAJOR "The PostgreSQL major version" "9.3";
    defineEnvVar PG_VERSION "The complete PostgreSQL version" '${PG_MAJOR}.10-1.pgdg80+1';
    defineEnvVar POSTGRES_UID "The uid of the PostgreSQL system account" "999";
    defineEnvVar POSTGRES_GID "The gid of the PostgreSQL system account" '${POSTGRES_UID}';

The syntax of this minimal DSL is provided by *dry-wit*:

    defineEnvVar NAME DESCRIPTION DEFAULT_VALUE;

And can be overridden (in ```postgres/.build-settings.sh```) with

    overrideEnvVar NAME NEW_VALUE;

You can now run set-square:

    ./build.sh -vv postgres

*set-square* will just transform any file within that folder which ends in ```*.template```,
and then ask Docker to build the image.

You'll probably notice in the example above that some of the variables' values use double quotes,
while and some others use single quotes. If the values contain references to other variables,
they have to use single quotes. Otherwise the value gets resolved by Bash itself, and the referenced
variables won't be available and would me replaced by empty strings.

# Phusion-based images

You can review a number of Phusion-based images built Using *set-square* in
https://github.com/rydnr/set-square-phusion-images.

# Documentation

*set-square* is a [dry-wit](https://github.com/rydnr/dry-wit)-based Bash script.
It should be self-explanatory and easy to read (and customize or extend),
once you learn the basics. For a brief introduction to dry-wit, you can
review this 10-minute [slides](https://github.com/rydnr/dry-wit/raw/master/docs/overview.pdf).

In the [docs](https://github.com/rydnr/set-square/docs/) folder you can find some
slides describing both the tool and the motivation behind the
[images](https://github.com/rydnr/set-square-phusion-images) implemented using *set-square*.

(*) Even if they're used also at runtime, it's just a matter to rename the files using them
as ```.template```. Such files will end up using the correct values in
the resulting Docker image.
