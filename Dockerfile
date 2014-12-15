FROM ubuntu:14.04
MAINTAINER scarlet9 <jimkoo9x@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
      mysql-server \
      apache2 \
      apache2-mpm-prefork \
      apache2-utils \
      libapache2-mod-auth-mysql \
      libapache2-mod-php5 \
      php5-common \
      php5-mysql \
      php5-curl \
      php5-json \
      vsftpd \
      supervisor

RUN mkdir -p /var/www /var/log/supervisor

# Copy supervisor conf.
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy dump and import to DB.
COPY dump.sql /root/dump.sql
RUN /etc/init.d/mysql start && \
      /usr/bin/mysql -u root < /root/dump.sql && \
      /usr/bin/mysqladmin stop

VOLUME /var/www /var/lib/mysql

EXPOSE 80

CMD ["/usr/bin/supervisord"]
