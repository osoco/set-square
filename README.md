# set-square

*set-square* is a tool to streamline the building of Docker images,
allowing the use of simple placeholders within Dockerfiles.

The main idea was borrowed from wking's tool, and was adapted to be
as simple to use as possible.

# Installation


    git clone --recurse-submodules https://github.com/rydnr/set-square
    cd set-square
    git submodules init
    git submodules update

# Usage

Implement your image's dockerfile with no imposed restrictions.
For example, let's say you want to implement your own PostgreSQL image,
based on the official Dockerfile (available in github: https://github.com/docker-library/docs/tree/master/postgres).

    # vim:set ft=dockerfile:
    FROM debian:jessie
    
    # explicitly set user/group IDs
    RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres
    
    # grab gosu for easy step-down from root
    RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
    RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists    /* \
    	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    	&& gpg --verify /usr/local/bin/gosu.asc \
    	&& rm /usr/local/bin/gosu.asc \
    	&& chmod +x /usr/local/bin/gosu \
    	&& apt-get purge -y --auto-remove ca-certificates wget

    # make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
    RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
    ENV LANG en_US.utf8
    
    RUN mkdir /docker-entrypoint-initdb.d
    
    RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
    
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
  - PG_MAJOR and PG_MINOR,
  - The Debian version it's based on,
  - The uid and gid of the internal Postgres user.

The Dockerfile you'd really want would be the following:

    # vim:set ft=dockerfile:
    FROM debian:${DEBIAN_VERSION}
    
    # explicitly set user/group IDs
    RUN groupadd -r postgres --gid=${POSTGRES_GID} && useradd -r -g postgres --uid=${POSTGRES_UID} postgres
    
    # grab gosu for easy step-down from root
    RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
    RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists    /* \
    	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    	&& gpg --verify /usr/local/bin/gosu.asc \
    	&& rm /usr/local/bin/gosu.asc \
    	&& chmod +x /usr/local/bin/gosu \
    	&& apt-get purge -y --auto-remove ca-certificates wget

    # make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
    RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
    	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
    ENV LANG en_US.utf8
    
    RUN mkdir /docker-entrypoint-initdb.d
    
    RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
    
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
    
    ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH
    ENV PGDATA /var/lib/postgresql/data
    VOLUME /var/lib/postgresql/data
    
    COPY docker-entrypoint.sh /
    
    ENTRYPOINT ["/docker-entrypoint.sh"]
    
    EXPOSE 5432
    CMD ["postgres"]

First, place this Dockerfile template as {{{postgres/Dockerfile.template}}}.
Secondly, create a new settings file ({{{postgres/build-settings.sh}}}) for specifying the default value you will be using normally:

    defineEnvVar PG_MAJOR "The PostgreSQL major version" "9.3";
    defineEnvVar GP_VERSION "The complete PostgreSQL version" '${PG_MAJOR}.10-1.pgdg80+1';

You can now run set-square:

    ./build.sh -vv postgres

set-square will just transform any file within that folder which ends in {{{.template}}},
and then ask Docker to build the image.
