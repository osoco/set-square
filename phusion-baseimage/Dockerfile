FROM phusion/baseimage:0.9.13
MAINTAINER Jose San Leandro <jose.sanleandro@ventura24.es>

RUN apt-get update
# From https://www.digitalocean.com/community/tutorials/how-to-install-java-on-ubuntu-with-apt-get
RUN apt-get install -y python-software-properties
RUN yes | add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN yes | apt-get install -y oracle-java7-installer

# Install JCE
RUN wget -nv --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie;gpw_e24=http://edelivery.oracle.com" http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip -O /opt/UnlimitedJCEPolicyJDK7.zip
RUN cd /opt && jar xvf UnlimitedJCEPolicyJDK7.zip && cp UnlimitedJCEPolicy/*.jar /usr/lib/jvm/java-7-oracle/jre/lib/security/ && rm -rf UnlimitedJCEPolicy* 

RUN cd /bin && rm -f /bin/sh && ln -s /bin/bash sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
