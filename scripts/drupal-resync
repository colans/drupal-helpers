#!/bin/sh
#############################################################################
# Filename:
#   drupal-resync
# Purpose:
#   Resynchronize a Drupal development site from Staging, Production, etc.
# Usage:
#   drupal-resync <SOURCE_DRUSH_ALIAS> <DESTINATION_DRUSH_ALIAS> [<MODULES_DISABLE>]
# Parameters:
#   <SOURCE_DRUSH_ALIAS>:      The site from which to copy the database. Required.
#   <DESTINATION_DRUSH_ALIAS>: The site to which the database should be copied. Required.
#   <MODULES_DISABLE>:         A list of space-separated modules to disable. Optional.
# Assumptions:
#   * The command paths below are correct.
#   * The web user below is correct.
#   * Drush in installed.
#   * Drush aliases with "files" locations are set up.
#   * Devel is installed.
#   * The logging channel ID is as below on the target machine.
#   * Rsync defaults are set appropriately in your Drush aliases.
# Author:
#   Colan Schwartz - http://colans.net/
# Licence:
#   GPLv3
#############################################################################

# Set command paths.
DRUSH=/usr/bin/drush
GZIP=/bin/gzip
CUT=/usr/bin/cut
GREP=/bin/grep
ECHO=/bin/echo
DATE=/bin/date
CHGRP=/bin/chgrp

# Set the web user.
USER_WEB=www-data

# Set the logging channel.
LOG_LOCAL0=128

# Make sure that the parameters are specified.
if [ -z "$2" ]; then
  $ECHO "Usage: drupal-resync <source-drush-alias> <dest-drush-alias> [<modules-to-disable>]"
  return 1
fi

# Set variables from arguments.
SOURCE=$1
DESTINATION=$2
MODULES_DISABLE=$3

$ECHO "Start time: $($DATE +%T)"

# Set targets.
DB_DEST=$($DRUSH $DESTINATION status | $GREP "Database name" | $CUT -f2 -d:)
DB_IDENTITY=$($ECHO $DESTINATION | $CUT -f2 -d@)

$ECHO "Clear the existing DB's cache to save disk space..."
$DRUSH $DESTINATION cc all

$ECHO "Saving a backup of the existing database..."
$DRUSH $DESTINATION sql-dump --create-db | $GZIP > ~/$DESTINATION.dump.mysql.gz

$ECHO "Clear it..."
$DRUSH $DESTINATION sql-drop

$ECHO "Clear the source's cache to speed syncing..."
$DRUSH $SOURCE cc all

$ECHO "Sync the source DB to the destination..."
$DRUSH sql-sync --structure-tables-key=truncate --skip-tables-key=ignore $SOURCE $DESTINATION

if [ -n "$MODULES_DISABLE" ]; then
  $ECHO "Disabling modules not needed for development..."
  $DRUSH $DESTINATION dis $MODULES_DISABLE
fi

$ECHO "Enabling modules for development..."
$DRUSH $DESTINATION en devel syslog update

$ECHO "Set the logging identity and facility..."
$DRUSH $DESTINATION vset syslog_identity drupal-$DB_IDENTITY
$DRUSH $DESTINATION vset syslog_facility $LOG_LOCAL0

$ECHO "Turn on error reporting..."
$DRUSH $DESTINATION php-eval "variable_set('error_level', ERROR_REPORTING_DISPLAY_ALL)"

$ECHO "Clearing the cache on the destination..."
$DRUSH $DESTINATION cc all

$ECHO "Updating the files directory..."
$DRUSH rsync $SOURCE:%files $DESTINATION:%files
$CHGRP -R $USER_WEB $($DRUSH dd $DESTINATION:%files)

$ECHO "All done!"
$ECHO "End time: $($DATE +%T)"
