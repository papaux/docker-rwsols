#!/bin/bash

echo "This will generate the proper hash (sha256) for your password."
echo "Once you get the hash, copy it into the docker-compose.yml file."
echo

read -p 'Your password: ' PASS

HASH=$(echo -n "$PASS" | sha256sum | head -c 64)

echo
echo "Your password hash: $HASH"
