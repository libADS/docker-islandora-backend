Docker Islandora Backend
================

Runs Fedora, Gseach and Solr inside Tomcat in a Docker container with configuration for Islandora. The goal is for this to function as a minimal, functional `backend` service for testing with Islandora.

Binary default versions:
-------------------------------

- Gsearch 2.6
- Fedora 3.7.0
- Solr 4.2.0

Using the Fedora container's default environment creates:

- a database called "fedora"
- a user called "fedora" with password "fedora"
- drupal filter is configured with `drupal` for db, user, password

These values can be overriden if preferred.

Overview
-------------

The applications will be accessible at:

```
http://localhost:8080/fedora
http://localhost:8080/gsearch
http://localhost:8080/solr
```

Passwords (defaults):

- fedoraAdmin: fedora
- fgsAdmin: fedora

Building a container
--------------------------

Get and build a MySQL container:

```
git clone https://github.com/tutumcloud/tutum-docker-mysql
cd tutum-docker-mysql
docker build -t tutum/mysql 5.5/
```

Download the jars:

```
./get_jars.sh
```

This greatly increases the speed of building (and particularly rebuilding) images.

Build:

```
./build.sh
```

Run (with script):

```
./run.sh # run mysql and fedora etc. in background
```

Run (manually):

```
# mysql
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql

# foreground
docker run -i -t -p 8080:8080 --name fedora --link mysql:db islandora/backend:latest
# background
docker run -d -p 8080:8080 --name fedora --link mysql:db islandora/backend:latest
# within container
docker run -i -t -p 8080:8080 --name fedora --link mysql:db islandora/backend:latest /bin/bash
./setup.sh &
```

Overriding:

```
docker run -i -t -p 8080:8080 --name fedora --link mysql:db -e "SOLR_PREFIX=apache-solr" -e "SOLR_VERSION=3.6.2" islandora/backend:latest /bin/bash
```

Running additional containers
---------------------------------------

Map internal 8080 to a different host port and create a distinct database.

```
docker run -i -t -p 8081:8080 --name fedora1 --link mysql:db -e "FEDORA_DB=fedora1" islandora/backend:latest # foreground
```

Test
------

Create an object:

```
# using boot2docker you will need to use ip address to container not localhost i.e. 192.168.59.103
curl -v -u fedoraAdmin:fedora -X POST http://localhost:8080/fedora/objects/months:1?label=January
curl -v -u fedoraAdmin:fedora -X POST http://localhost:8081/fedora/objects/months:12?label=December # 2nd container
```

Find in Solr as:

```
dc.title:january
```

---
