#!/bin/bash

SSL_DIR=./ssl

mkdir -p $SSL_DIR

openssl genrsa -out $SSL_DIR/wol.key 2048
openssl req -new -key $SSL_DIR/wol.key -out $SSL_DIR/wol.csr
openssl x509 -req -days 10 -in $SSL_DIR/wol.csr -signkey $SSL_DIR/wol.key -out $SSL_DIR/wol.crt

