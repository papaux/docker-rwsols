#!/bin/bash

PATH_APACHE_SSL=/etc/apache2/ssl
CONFIG_FILE=/var/www/html/config.php

if [ -d "$PATH_APACHE_SSL" ] && [ -f "$PATH_APACHE_SSL/wol.crt" ] ; then
  a2enmod ssl
  sed -i 's/USE_HTTPS = false;/USE_HTTPS = true;/' $CONFIG_FILE
fi

sed -i "s/APPROVED_HASH = .*/APPROVED_HASH = \"$WOL_PASSWORD_HASH\";/" $CONFIG_FILE

# add double quotes in comma separated list
WOL_COMPUTER_NAMES=$(sed 's/[^,]*/"&"/g' <<< $WOL_COMPUTER_NAMES)
WOL_COMPUTER_MACS=$(sed 's/[^,]*/"&"/g' <<< $WOL_COMPUTER_MACS)
WOL_COMPUTER_LOCAL_IPS=$(sed 's/[^,]*/"&"/g' <<< $WOL_COMPUTER_LOCAL_IPS)

# set settings in config files
sed -i "s/MAX_PINGS = .*/MAX_PINGS = $WOL_MAX_PING;/" $CONFIG_FILE
sed -i "s/SLEEP_TIME = .*/SLEEP_TIME = $WOL_SLEEP_TIME;/" $CONFIG_FILE
sed -i "s/COMPUTER_NAME = .*/COMPUTER_NAME = array($WOL_COMPUTER_NAMES);/" $CONFIG_FILE
sed -i "s/COMPUTER_MAC = .*/COMPUTER_MAC = array($WOL_COMPUTER_MACS);/" $CONFIG_FILE
sed -i "s/COMPUTER_LOCAL_IP = .*/COMPUTER_LOCAL_IP = array($WOL_COMPUTER_LOCAL_IPS);/" $CONFIG_FILE

# set defined HTTP(S) ports in the apache configuration.
sed -i "s/:80/:$WOL_HTTP_PORT/g" /etc/apache2/sites-available/000-default.conf
sed -i "s/:443/:$WOL_HTTPS_PORT/g" /etc/apache2/sites-available/000-default.conf
sed -i "s/:443/:$WOL_HTTPS_PORT/g" /etc/apache2/sites-available/default-ssl.conf
sed -i "s/443/$WOL_HTTPS_PORT/g" /etc/apache2/ports.conf
sed -i "s/80/$WOL_HTTP_PORT/g" /etc/apache2/ports.conf

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
