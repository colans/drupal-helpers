#!/bin/bash
#############################################################################
# Purpose:
#   Deploys the Apache Solr application onto the GlassFish application server.
#
# Usage:
#   deploy-solr-on-glassfish <glassfish-dir> <solr-dir> <password>
#
# Arguments:
#   <glassfish-dir>
#     The directory where GlassFish is installed.
#   <solr-dir>
#     The directory where Solr is installed.
#   <password>
#     The new password to be used for accessing GlassFish's
#     administration via the Web or command-line interface (CLI).
#
# Requirements:
#   1) GlassFish must be installed to a directory somewhere on the local system.
#   2) Solr must be installed to directory "solr-X.Y.Z" somewhere on the local
#      system, where X.Y.Z is the Solr version.
#############################################################################

## Configuration section START ##############################################

# Set command paths.
ECHO=/bin/echo
CD=/usr/bin/cd
AWK=/usr/bin/awk
BASENAME=$(which basename)

## Configuration section END ################################################

# Stop executing the script if any command fails.
# See http://stackoverflow.com/a/4346420/442022 for details.
set -e
set -o pipefail

# Make sure that the parameters are specified.
if [[ -z $3 ]] || [[ ! -d $1 ]] || [[ ! -d $2 ]]; then
  $ECHO "Usage: $0 <glassfish-dir> <solr-dir> <password>"
  exit 1
fi

# Set command line options.
PATH_GLASSFISH=$1
PATH_SOLR=$2
PASSWORD=$3
ASADMIN=$PATH_GLASSFISH/bin/asadmin
PATH_WAR=$PATH_SOLR/dist/$($BASENAME $PATH_SOLR).war

echo "Deleting all existing domains from Glassfish..."
for domain in $($ASADMIN -t list-domains | $AWK '{print $1}'); do
  $ASADMIN -t stop-domain $domain
  $ASADMIN  delete-domain $domain
done
echo

echo "Creating Solr domain..."
$ASADMIN -t create-domain --nopassword=true solr
echo

echo "Starting Solr domain..."
$ASADMIN -t start-domain solr
echo

echo "Setting solr.solr.home property..."
$ASADMIN -t create-system-properties --target server-config solr.solr.home=$PATH_SOLR
echo

echo "Adding slf/log4j jars to classpath..."
$ASADMIN -t add-library --type common $PATH_SOLR/dist/solrj-lib/*
echo

echo "Adding log4j.properties to JVM options..."
$ASADMIN -t create-jvm-options --target server-config -Dlog4j.configuration="file\:///\${solr.solr.home}/example/cloud-scripts/log4j.properties"
echo

echo "Adding keystore password to JVM options..."
$ASADMIN -t create-jvm-options --target server-config -Djavax.net.ssl.keyStorePassword="$PASSWORD"
echo

echo "Adding truststore password to JVM options..."
$ASADMIN -t create-jvm-options --target server-config -Djavax.net.ssl.trustStorePassword="$PASSWORD"
echo

echo "Deleting default http port 8080 listener..."
$ASADMIN delete-http-listener http-listener-1
echo

echo "Creating http listener on port 8983 for solr..."
$ASADMIN create-http-listener --default-virtual-server server --enabled=true --listeneraddress 0.0.0.0 --listenerport 8983 http-listener-1
echo

echo "Deploying Solr WAR file..."
$ASADMIN deploy --target server --name solr4.3 --enabled=true --contextroot=solr4 --force=true "$PATH_WAR"
echo

echo "Restarting domain..."
$ASADMIN -t restart-domain
echo

echo "DONE!"
