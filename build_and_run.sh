#!/bin/bash

# assumes not running currently
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql
sleep 5

docker build -t markcooper/fedora:latest .
docker run -d -p 8080:8080 --link mysql:db markcooper/fedora:latest
