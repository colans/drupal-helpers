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

# Disable confirmation questions?  It's on by default.  Turning it off with "-y"
# is dangerous.  You've been warned!
#CONFIRMATION="-y"
CONFIRMATION=""

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

$ECHO "Saving a backup of the existing destination database..."
$DRUSH $DESTINATION sql-dump --create-db | $GZIP > ~/$DESTINATION.dump.mysql.gz

$ECHO "About to drop all tables in the destination database..."
$DRUSH $DESTINATION $CONFIRMATION sql-drop

$ECHO "Clear the source site's cache to speed syncing..."
$DRUSH $SOURCE cc all

$ECHO "Sync the source site's database to the destination..."
$DRUSH sql-sync --structure-tables-key=truncate --skip-tables-key=ignore $CONFIRMATION $SOURCE $DESTINATION

if [ -n "$MODULES_DISABLE" ]; then
  $ECHO "Disabling modules not needed on the development site..."
  $DRUSH $DESTINATION dis $CONFIRMATION $MODULES_DISABLE
fi

$ECHO "Enabling the destination's development modules..."
$DRUSH $DESTINATION en $CONFIRMATION devel syslog update

$ECHO "Disabling the destination's CSS & JavaScript caching..."
$DRUSH $DESTINATION vset preprocess_css 0
$DRUSH $DESTINATION vset preprocess_js 0

$ECHO "Set the destination's logging identity and facility..."
$DRUSH $DESTINATION vset syslog_identity drupal-$DB_IDENTITY
$DRUSH $DESTINATION vset syslog_facility $LOG_LOCAL0

$ECHO "Enable error reporting on the destination site..."
$DRUSH $DESTINATION php-eval "variable_set('error_level', ERROR_REPORTING_DISPLAY_ALL)"

$ECHO "Clearing the destination site's cache..."
$DRUSH $DESTINATION cc all

$ECHO "Updating the files directory..."
$DRUSH rsync $CONFIRMATION $SOURCE:%files $DESTINATION:%files
$CHGRP -R $USER_WEB $($DRUSH dd $DESTINATION:%files)

$ECHO "All done!"
$ECHO "End time: $($DATE +%T)"
