FROM ubuntu:14.04
MAINTAINER scarlet9 <jimkoo9x@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN ln -s -f /bin/true /usr/bin/chfn

RUN sed -i 's/archive.ubuntu.com/mirrors.linode.com/g' /etc/apt/sources.list && \
      apt-get update && \
      apt-get install -y \
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

RUN mkdir -p /var/www/html /var/log/supervisor

RUN /usr/sbin/a2enmod rewrite

# Copy supervisor conf.
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy dump and import to DB.
COPY dump.sql /root/dump.sql
RUN /usr/bin/mysqld_safe & \
      sleep 5 && \
      /usr/bin/mysql -u root < /root/dump.sql && \
      /usr/bin/mysqladmin stop

COPY vhost.conf /etc/apache2/sites-available/000-default.conf

VOLUME /var/www /var/lib/mysql

EXPOSE 80

CMD ["/usr/bin/supervisord"]
