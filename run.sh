#!/bin/bash

# assumes not running currently
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql
# pause long enough for db to become available - may need to up value
sleep 10
docker run -d -p 8080:8080 --name fedora --link mysql:db islandora/backend:latest
echo "Islandora backend requires ~ 2 minutes to initialize ..."

