FROM haproxy:1.5

# Install Ruby
RUN apt-get -y update
RUN apt-get -y --force-yes install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev wget
WORKDIR /tmp
RUN wget http://cache.ruby-lang.org/pub/ruby/ruby-2.2.3.tar.gz
RUN tar -xvzf ruby-2.2.3.tar.gz
WORKDIR /tmp/ruby-2.2.3
RUN ./configure --prefix=/usr/local
RUN make
RUN make install
WORKDIR /root

# Add haproxy user and group
RUN groupadd haproxy
RUN useradd -g haproxy haproxy

# These directories seem to be required
RUN mkdir -p /run/haproxy
RUN mkdir -p /var/lib/haproxy

ENV HAPROXY_CONFIG /usr/local/etc/haproxy/haproxy.cfg

# Copy the stuff
COPY errors /etc/haproxy/errors
COPY haproxy.cfg $HAPROXY_CONFIG
COPY haproxy_helper.rb /sbin/haproxy_helper
