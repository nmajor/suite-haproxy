FROM debian:wheezy

RUN apt-get update && apt-get install -y libssl1.0.0 libpcre3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV HAPROXY_MAJOR 1.6
ENV HAPROXY_VERSION 1.6.2
ENV HAPROXY_MD5 d0ebd3d123191a8136e2e5eb8aaff039

# see http://sources.debian.net/src/haproxy/1.5.8-1/debian/rules/ for some helpful navigation of the possible "make" arguments
RUN buildDeps='curl gcc libc6-dev libpcre3-dev libssl-dev make' \
  && set -x \
  && apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
  && curl -SL "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" -o haproxy.tar.gz \
  && echo "${HAPROXY_MD5}  haproxy.tar.gz" | md5sum -c \
  && mkdir -p /usr/src/haproxy \
  && tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
  && rm haproxy.tar.gz \
  && make -C /usr/src/haproxy \
    TARGET=linux2628 \
    USE_PCRE=1 PCREDIR= \
    USE_OPENSSL=1 \
    USE_ZLIB=1 \
    all \
    install-bin \
  && mkdir -p /usr/local/etc/haproxy \
  && cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
  && rm -rf /usr/src/haproxy \
  && apt-get purge -y --auto-remove $buildDeps

# Install Ruby
RUN apt-get -y update
RUN apt-get -y --force-yes install build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev wget vim iptables curl procps
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
COPY haproxy.init /etc/init.d/haproxy
