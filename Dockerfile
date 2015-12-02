FROM phusion/baseimage:latest

RUN add-apt-repository ppa:vbernat/haproxy-1.5
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install haproxy

# These directories seem to be required
RUN mkdir -p /run/haproxy
RUN mkdir -p /var/lib/haproxy

ENV HAPROXY_CONFIG /usr/local/etc/haproxy/haproxy.cfg

# Copy the stuff
COPY errors /etc/haproxy/errors
COPY haproxy.cfg $HAPROXY_CONFIG
COPY haproxy_helper.rb /sbin/haproxy_helper

RUN mkdir /etc/service/haproxy
ADD haproxy.runit /etc/service/haproxy/run

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*