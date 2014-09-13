#!/bin/bash

docker run -d -p 8080:8080 --name fedora --link mysql:db islandora/backend:latest
echo "Islandora backend requires ~ 2 minutes to initialize ..."

