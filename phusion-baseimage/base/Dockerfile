# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.9.14

MAINTAINER rydnr "docker@acm-sl.org"

RUN apt-get update

RUN cd /bin && rm -f /bin/sh && ln -s /bin/bash sh

CMD ["/sbin/my_init"]