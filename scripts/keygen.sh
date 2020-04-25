#!/usr/bin/env bash

# Some notes on generating ssl keys for https:
# openssl req -newkey rsa:2048 -new -nodes -keyout key.pem -out csr.pem -days XXX
# openssl x509 -req -days 365 -in csr.pem -signkey key.pem -out server.crt
function keygen() {
  openssl req -newkey rsa:2048 -new -nodes -keyout key.pem -out csr.pem -days XXX
  openssl x509 -req -days 365 -in csr.pem -signkey key.pem -out server.crt
}

keygen
