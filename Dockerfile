FROM debian:10-slim

MAINTAINER geoffrey.papaux@gmail.com

WORKDIR /root

ARG VERSION=2.0.2
ARG EXTRACTED_DIR=rwsols

# base install
RUN apt-get update &&\
    apt-get install -y iputils-ping wakeonlan apache2 php php7.3-curl libapache2-mod-php wget unzip &&\
    chmod u+s `which ping` &&\
    apt-get clean

# get source code
RUN wget -O rwsols.zip https://github.com/sciguy14/Remote-Wake-Sleep-On-LAN-Server/archive/$VERSION.zip &&\
    unzip rwsols.zip &&\
    mv Remote-Wake-Sleep-On-LAN-Server-$VERSION $EXTRACTED_DIR &&\
    rm rwsols.zip

# Encryption settings
RUN mkdir /etc/apache2/ssl &&\
    mv -f $EXTRACTED_DIR/ssl.conf /etc/apache2/mods-available/ssl.conf

# Apache2 setup
RUN a2enmod headers &&\
    mv -f $EXTRACTED_DIR/000-default.conf /etc/apache2/sites-available/000-default.conf &&\
    sed -i "s/expose_php = On/expose_php = Off/g" /etc/php/7.3/apache2/php.ini &&\
    sed -i "s/E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED/error_reporting = E_ERROR/g" /etc/php/7.3/apache2/php.ini &&\
    sed -i "s/ServerSignature On/ServerSignature Off/g" /etc/apache2/conf-available/security.conf &&\
    sed -i "s/ServerTokens OS/ServerTokens Prod/g" /etc/apache2/conf-available/security.conf

# Move website files to the server directory and clean up
RUN mv $EXTRACTED_DIR/* /var/www/html &&\
    mv $EXTRACTED_DIR/.htaccess /var/www/html &&\
    rm -rf $EXTRACTED_DIR &&\
    rm -f /var/www/html/index.html &&\
    mv /var/www/html/config_sample.php /var/www/html/config.php

COPY ./docker-entrypoint.sh /

# password is "default"
ENV WOL_PASSWORD_HASH 37a8eec1ce19687d132fe29051dca629d164e2c4958ba141d5f4133a33f0688f
ENV WOL_MAX_PING 10
ENV WOL_SLEEP_TIME 10
ENV WOL_COMPUTER_NAMES ordi1,ordi2
ENV WOL_COMPUTER_MACS 10:00:00:00:00:00,20:00:00:00:00:00
ENV WOL_COMPUTER_LOCAL_IPS 192.168.1.1,192.168.1.2
ENV WOL_HTTPS_PORT 2000
ENV WOL_HTTP_PORT 2001

# Since we are uing network in host mode, this has no effect.
# Find a way to run in bridge mode and this can then be restored.
#EXPOSE 80
#EXPOSE 443

CMD ["/docker-entrypoint.sh"]
