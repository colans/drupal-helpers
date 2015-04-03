#!/bin/bash

export SOLR_PATH=/opt/glassfish/solr4
cd /opt/glassfish/glassfish3

echo "Deleting all existing domains from Glassfish"
for domain in $(bin/asadmin -t list-domains |awk '{print $1}'); do bin/asadmin -t stop-domain $domain; bin/asadmin  delete-domain $domain; done
echo

echo "Creating Solr domain"
bin/asadmin -t create-domain --nopassword=true solr
echo

echo "Starting Solr domain"
bin/asadmin -t start-domain solr
echo

echo "Setting solr.solr.home property"
bin/asadmin -t create-system-properties --target server-config solr.solr.home=$SOLR_PATH
echo

echo "Adding slf/log4j jars to classpath"
bin/asadmin -t add-library --type common $SOLR_PATH/lib/*
echo

echo "Adding log4j.properties to JVM options"
bin/asadmin -t create-jvm-options --target server-config -Dlog4j.configuration="file\:///\${solr.solr.home}/lib/log4j.properties"
echo

echo "Adding keystore password to JVM options"
bin/asadmin -t create-jvm-options --target server-config -Djavax.net.ssl.keyStorePassword="changeit"
echo

echo "Adding truststore password to JVM options"
bin/asadmin -t create-jvm-options --target server-config -Djavax.net.ssl.trustStorePassword="changeit"
echo

echo "Deleting default http port 8080 listener"
bin/asadmin delete-http-listener http-listener-1
echo

echo "Creating http listener on port 8983 for solr"
bin/asadmin create-http-listener --default-virtual-server server --enabled=true --listeneraddress 0.0.0.0 --listenerport 8983 http-listener-1
echo

echo "Deploying Solr war"
bin/asadmin deploy --target server --name solr4.3 --enabled=true --contextroot=solr4 --force=true "$SOLR_PATH/solr.war"
echo

echo "Restarting domain"
bin/asadmin -t restart-domain
echo

echo "DONE\!"