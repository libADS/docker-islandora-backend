#!/bin/bash

FEDORA=fcrepo-installer-3.7.0.jar
GSEARCH=fedoragsearch-2.6.zip
DRUPAL_FILTER=fcrepo-drupalauthfilter-3.7.0.jar

wget -P bin/ -N http://downloads.sourceforge.net/project/fedora-commons/fedora/3.7.0/$FEDORA
wget -P bin/ -N http://downloads.sourceforge.net/fedora-commons/$GSEARCH
wget -P bin/ -N https://archive.apache.org/dist/lucene/solr/4.2.0/solr-4.2.0.tgz
wget -P bin/ -N https://github.com/Islandora/islandora_drupal_filter/releases/download/v7.1.3/$DRUPAL_FILTER

wget -P bin/ -N https://raw.github.com/ryersonlibrary/islandora/master/jars/solr-iso639-filter-4.2.0-r20131208.jar
wget -P bin/ -N https://raw.github.com/ryersonlibrary/islandora/master/jars/gsearch_extensions-0.1.0.jar
wget -P bin/ -N https://raw.github.com/ryersonlibrary/islandora/master/jars/gsearch_extensions-0.1.0-jar-with-dependencies.jar
