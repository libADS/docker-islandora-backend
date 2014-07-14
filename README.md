Docker Islandora Backend
================

Runs Fedora, Gseach and Solr inside Tomcat in a Docker container with configuration for Islandora.

Binary default versions:
-------------------------------

- Gsearch 2.6
- Fedora 3.7.0
- Solr 4.2.0

Requirements
------------------

The container requires access to a linked MySQL database aliased as **db** exposing **3306**. 

**Example**

```
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql
# note "as is" this command is NOT persisting data between container restarts
```

_Give the container 5+ seconds to initialize_

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

Get, build and run a MySQL container:

```
git clone https://github.com/tutumcloud/tutum-docker-mysql
docker build -t tutum/mysql .
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql
```

Download the jars:

```
./get_jars.sh
```

This greatly increases the speed of building (and particularly rebuilding) images.

Build:

```
docker build -t dts/fedora:latest .
```

Run:

```
docker run -i -t -p 8080:8080 --name fedora --link mysql:db dts/fedora:latest # foreground
docker run -d -p 8080:8080 --name fedora --link mysql:db dts/fedora:latest # background
```

Run from within the container:

```
docker run -i -t -p 8080:8080 --name fedora --link mysql:db dts/fedora:latest /bin/bash
./setup.sh &
```

Overriding:

```
docker run -i -t -p 8080:8080 --name fedora --link mysql:db -e "SOLR_PREFIX=apache-solr" -e "SOLR_VERSION=3.6.2" dts/fedora:latest /bin/bash
```

Running with provided script:
--------------------------------------

Requires MySQL container.

```
./build_and_run.sh # start MySQL, build and run in background
```

Running additional containers
---------------------------------------

Map internal 8080 to a different host port and create a distinct database.

```
docker run -i -t -p 8081:8080 --name fedora --link mysql:db -e "FEDORA_DB=fedora1" dts/fedora:latest # foreground
```

Test
------

Create an object:

```
curl -v -u fedoraAdmin:fedora -X POST http://localhost:8080/fedora/objects/months:1?label=January
curl -v -u fedoraAdmin:fedora -X POST http://localhost:8081/fedora/objects/months:12?label=December # 2nd container
```

Find in Solr as:

```
dc.title:january
```

---
