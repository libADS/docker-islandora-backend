#!/bin/bash

export JRE_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export JAVA_OPTS="-Xms1024m -Xmx1024m -XX:NewSize=256m -XX:MaxNewSize=356m -XX:PermSize=256m -XX:MaxPermSize=356m  -Djavax.net.ssl.trustStore=/opt/truststore -Djavax.net.ssl.trustStorePassword=tomcat"
export CATALINA_BASE=/var/lib/tomcat7
export CATALINA_HOME=/usr/share/tomcat7
export FEDORA_HOME=/opt/fedora
export PATH=$FEDORA_HOME/server/bin:$JAVA_HOME/bin:$PATH

# MOVE SOLR INTO PLACE
cp /solr-$SOLR_VERSION/$SOLR_PREFIX-$SOLR_VERSION/dist/$SOLR_PREFIX-$SOLR_VERSION.war /opt/solr/solr.war
cp -R /solr-$SOLR_VERSION/$SOLR_PREFIX-$SOLR_VERSION/example/solr/* /opt/data/solr
mkdir -p /solr-$SOLR_VERSION/$SOLR_PREFIX-$SOLR_VERSION//contrib/iso639/lib
cp /solr-iso639-filter-4.2.0.jar /solr-$SOLR_VERSION/$SOLR_PREFIX-$SOLR_VERSION/contrib/iso639/lib/solr-iso639-filter-4.2.0.jar
# making backwards compatible with 3.6.2 will require some additional configuration

# SETUP DATABASE
mysql --host=$DB_PORT_3306_TCP_ADDR --port=3306 --user=$ADMIN --password=$ADMIN_PASSWORD -e "CREATE DATABASE $FEDORA_DB default character set utf8;"
mysql --host=$DB_PORT_3306_TCP_ADDR --port=3306 --user=$ADMIN --password=$ADMIN_PASSWORD -e "grant all on $FEDORA_DB.* to '$FEDORA_USER'@'%' identified by '$FEDORA_PASSWORD';"

sed -i "s/!MYSQL_HOST!/$DB_PORT_3306_TCP_ADDR/g" /install.properties
sed -i "s/!FEDORA_DB!/$FEDORA_DB/g" /install.properties
sed -i "s/!FEDORA_USER!/$FEDORA_USER/g" /install.properties
sed -i "s/!FEDORA_PASSWORD!/$FEDORA_PASSWORD/g" /install.properties

sed -i "s/!FEDORA_PASSWORD!/$FEDORA_PASSWORD/g" /fgsconfig-basic-for-islandora.properties
sed -i "s/!FEDORA_PASSWORD!/$FEDORA_PASSWORD/g" /fedora-users.xml

sed -i "s/!MYSQL_HOST!/$DB_PORT_3306_TCP_ADDR/g" /filter-drupal.xml
sed -i "s/!DRUPAL_DB!/$DRUPAL_DB/g" /filter-drupal.xml
sed -i "s/!DRUPAL_USER!/$DRUPAL_USER/g" /filter-drupal.xml
sed -i "s/!DRUPAL_PASSWORD!/$DRUPAL_PASSWORD/g" /filter-drupal.xml

# INSTALL FEDORA USING install.properties
java -jar /fcrepo-installer-3.7.0.jar install.properties
git clone https://github.com/Islandora/islandora-xacml-policies.git $FEDORA_HOME/data/fedora-xacml-policies/repository-policies/islandora

chown -R tomcat7:tomcat7 /opt/solr
chown -R tomcat7:tomcat7 /opt/data
chown -R tomcat7:tomcat7 $FEDORA_HOME
chown -R tomcat7:tomcat7 $CATALINA_BASE
chown -R tomcat7:tomcat7 /etc/tomcat7/Catalina/localhost

# NOW IT GETS UGLY ...
$CATALINA_HOME/bin/catalina.sh run & # set running and give some time to explode stuff
sleep 60

# localhost only makes me sad ...
rm $FEDORA_HOME/data/fedora-xacml-policies/repository-policies/default/deny-*
cp /fedora-users.xml $FEDORA_HOME/server/config/fedora-users.xml

# config for gsearch ...
cp /fgsconfig-basic-for-islandora.properties $CATALINA_BASE/webapps/gsearch/FgsConfig/fgsconfig-basic-for-islandora.properties
cd $CATALINA_BASE/webapps/gsearch/FgsConfig && ant -f fgsconfig-basic.xml -Dlocal.FEDORA_HOME=$FEDORA_HOME -propertyfile fgsconfig-basic-for-islandora.properties

git clone $ISL_TRANSFORMS $CATALINA_BASE/webapps/gsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms
cp /slurp_all_MODS_to_solr.xslt $CATALINA_BASE/webapps/gsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms/slurp_all_MODS_to_solr.xslt
cp /capture_collection_heirarchy.xsl $CATALINA_BASE/webapps/gsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/islandora_transforms/capture_collection_heirarchy.xsl
cp /foxmlToSolr.xslt $CATALINA_BASE/webapps/gsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/foxmlToSolr.xslt

cp /gsearch_extensions-0.1.0.jar $CATALINA_BASE/webapps/gsearch/WEB-INF/lib
cp /gsearch_extensions-0.1.0-jar-with-dependencies.jar $CATALINA_BASE/webapps/gsearch/WEB-INF/lib

# config for solr
# cp $CATALINA_BASE/webapps/gsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/conf/schema-4.2.0-for-fgs-2.6.xml /opt/data/solr/collection1/conf/schema.xml
cp /schema-$SOLR_VERSION.xml /opt/data/solr/collection1/conf/schema.xml
cp /solrconfig-$SOLR_VERSION.xml /opt/data/solr/collection1/conf/solrconfig.xml

# copy the drupal filter into place
cp /fcrepo-drupalauthfilter-3.7.0.jar $CATALINA_BASE/webapps/fedora/WEB-INF/lib
cp /jaas.conf $FEDORA_HOME/server/config/jaas.conf
cp /filter-drupal.xml $FEDORA_HOME/server/config/filter-drupal.xml

# brute reset permissions
chown -R tomcat7:tomcat7 /opt/solr
chown -R tomcat7:tomcat7 /opt/data
chown -R tomcat7:tomcat7 $FEDORA_HOME
chown -R tomcat7:tomcat7 $CATALINA_BASE
chown -R tomcat7:tomcat7 /etc/tomcat7/Catalina/localhost

$CATALINA_HOME/bin/catalina.sh stop # ask nicely first
sleep 5
pkill -f java # HACK! ensure it's not running
sleep 10

$CATALINA_HOME/bin/catalina.sh run # put the pieces back together again ...
