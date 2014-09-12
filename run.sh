#!/bin/bash

# assumes not running currently
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql
sleep 5
docker run -d -p 8080:8080 --name fedora --link mysql:db islandora/backend:latest
