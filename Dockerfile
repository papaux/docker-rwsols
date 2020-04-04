FROM debian:10

MAINTAINER geoffrey.papaux@gmail.com

WORKDIR /root

ARG VERSION=2.0.2
ARG EXTRACTED_DIR=rwsols

# base install
RUN apt-get update &&\
    apt-get install -y wakeonlan apache2 php php7.3-curl libapache2-mod-php wget unzip &&\
    chmod u+s `which ping` &&\
    apt-get clean

# get source code
RUN wget -O rwsols.zip https://github.com/sciguy14/Remote-Wake-Sleep-On-LAN-Server/archive/$VERSION.zip &&\
    unzip rwsols.zip &&\
    mv Remote-Wake-Sleep-On-LAN-Server-$VERSION $EXTRACTED_DIR

# Encryption settings
RUN mkdir /etc/apache2/ssl &&\
    mv -f $EXTRACTED_DIR/ssl.conf /etc/apache2/mods-available/ssl.conf

# Apache2 setup
RUN a2enmod headers &&\
    mv -f $EXTRACTED_DIR/000-default.conf /etc/apache2/sites-available/000-default.conf &&\
#    sed -i.bak 's/:80/:2080/' /etc/apache2/sites-available/000-default.conf &&\
#    sed -i.bak 's/:443/:2000/' /etc/apache2/sites-available/000-default.conf &&\
    sed -i.bak "s/expose_php = On/expose_php = Off/g" /etc/php/7.3/apache2/php.ini &&\
    sed -i.bak "s/E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED/error_reporting = E_ERROR/g" /etc/php/7.3/apache2/php.ini &&\
    sed -i.bak "s/ServerSignature On/ServerSignature Off/g" /etc/apache2/conf-available/security.conf &&\
    sed -i.bak "s/ServerTokens OS/ServerTokens Prod/g" /etc/apache2/conf-available/security.conf

# Move website files to the server directory
RUN mv $EXTRACTED_DIR/* /var/www/html &&\
    mv $EXTRACTED_DIR/.htaccess /var/www/html &&\
    rm -rf Remote-Wake-Sleep-On-LAN-Server/ &&\
    rm -f /var/www/html/index.html &&\
    mv /var/www/html/config_sample.php /var/www/html/config.php

COPY ./docker-entrypoint.sh /

ENV WOL_PASSWORD default
ENV WOL_MAX_PING 10
ENV WOL_SLEEP_TIME 10
ENV WOL_COMPUTER_NAMES ordi1,ordi2
ENV WOL_COMPUTER_MACS 10:00:00:00:00:00,20:00:00:00:00:00
ENV WOL_COMPUTER_LOCAL_IPS 192.168.1.1,192.168.1.2

# while we are uing network in host mode, this has no effect.
# when finding how to run without host mode, we can actually revert to std ports
EXPOSE 80
EXPOSE 443

CMD ["/docker-entrypoint.sh"]
