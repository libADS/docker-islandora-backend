FROM ubuntu:latest

ENV ADMIN admin
ENV ADMIN_PASSWORD admin
ENV FEDORA_DB fedora
ENV FEDORA_USER fedora
ENV FEDORA_PASSWORD fedora
ENV DRUPAL_DB drupal
ENV DRUPAL_USER drupal
ENV DRUPAL_PASSWORD drupal
ENV SOLR_PREFIX solr
ENV SOLR_VERSION 4.2.0
ENV ISL_TRANSFORMS https://github.com/lyrasis/islandora_transforms

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends openjdk-7-jdk
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ant git mysql-client tomcat7 tomcat7-admin unzip

ADD configuration/tomcat/tomcat-users.xml /etc/tomcat7/tomcat-users.xml
RUN mkdir /var/lib/tomcat7/temp

# FEDORA
RUN mkdir -p /opt/fedora
ADD bin/fcrepo-installer-3.7.0.jar /fcrepo-installer-3.7.0.jar
ADD configuration/fedora/install.properties /install.properties
RUN jar xf /fcrepo-installer-3.7.0.jar resources/truststore
RUN cp resources/truststore /opt

# GSEARCH
RUN mkdir -p /opt/gsearch
ADD bin/gsearch_extensions-0.1.0.jar /gsearch_extensions-0.1.0.jar
ADD bin/gsearch_extensions-0.1.0-jar-with-dependencies.jar /gsearch_extensions-0.1.0-jar-with-dependencies.jar
ADD configuration/gsearch/fedora-users.xml /fedora-users.xml
ADD configuration/gsearch/fgsconfig-basic-for-islandora.properties /fgsconfig-basic-for-islandora.properties
ADD configuration/gsearch/foxmlToSolr.xslt /foxmlToSolr.xslt
ADD configuration/gsearch/slurp_all_MODS_to_solr.xslt /slurp_all_MODS_to_solr.xslt
ADD bin/fedoragsearch-2.6.zip /fedoragsearch-2.6.zip
RUN unzip fedoragsearch-2.6.zip
RUN cp /fedoragsearch-2.6/fedoragsearch.war /var/lib/tomcat7/webapps/gsearch.war

# SOLR
RUN mkdir -p /opt/solr
RUN mkdir -p /opt/data/solr
ADD bin/solr-4.2.0.tgz /solr-4.2.0
ADD bin/solr-iso639-filter-4.2.0-r20131208.jar /solr-iso639-filter-4.2.0.jar
ADD configuration/solr/schema-4.2.0.xml /schema-4.2.0.xml
ADD configuration/solr/solrconfig-4.2.0.xml /solrconfig-4.2.0.xml
ADD configuration/solr/solr-context.xml /solr-context.xml
RUN cp /solr-context.xml /var/lib/tomcat7/conf/Catalina/localhost/solr.xml

# DRUPAL FILTER
ADD bin/fcrepo-drupalauthfilter-3.7.0.jar /fcrepo-drupalauthfilter-3.7.0.jar
ADD configuration/drupal-filter/jaas.conf /jaas.conf
ADD configuration/drupal-filter/filter-drupal.xml /filter-drupal.xml

# SETUP
RUN chown root:tomcat7 /etc/tomcat7/tomcat-users.xml
RUN chown -R tomcat7:tomcat7 /var/lib/tomcat7

RUN chown -R tomcat7:tomcat7 /opt/fedora
RUN chown -R tomcat7:tomcat7 /opt/gsearch
RUN chown -R tomcat7:tomcat7 /opt/solr
RUN chown -R tomcat7:tomcat7 /opt/data/solr

ADD setup.sh /setup.sh
RUN chmod u+x /setup.sh

EXPOSE 8080

CMD ["/setup.sh"]
