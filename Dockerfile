FROM phusion/baseimage:latest

RUN apt-get update
RUN apt-get -y install haproxy
RUN sed -i "s/ENABLED=0/ENABLED=1/" /etc/default/haproxy

# Install Ruby
RUN apt-get -y --force-yes install gcc make
WORKDIR /tmp
RUN curl -O http://cache.ruby-lang.org/pub/ruby/ruby-2.2.3.tar.gz
RUN tar -xvzf ruby-2.2.3.tar.gz
WORKDIR /tmp/ruby-2.2.3
RUN ./configure --prefix=/usr/local
RUN make
RUN make install
WORKDIR /root

# These directories seem to be required
RUN mkdir -p /run/haproxy
RUN mkdir -p /var/lib/haproxy

ENV HAPROXY_CONFIG /etc/haproxy/haproxy.cfg

# Copy the stuff
COPY errors /etc/haproxy/errors
RUN rm $HAPROXY_CONFIG
COPY haproxy.cfg $HAPROXY_CONFIG
COPY haproxy_helper.rb /sbin/haproxy_helper

RUN mkdir /etc/service/haproxy

RUN (crontab -l 2>/dev/null; echo "* * * * * haproxy_helper refresh_config") | crontab -
RUN (crontab -l 2>/dev/null; echo "*/5 * * * * haproxy_helper deregister_nodes") | crontab -

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*