#!/bin/sh
#############################################################################
# Filename:
#   drupal-resync
#
# Purpose:
#   Resynchronize a Drupal development site from Staging, Production, etc.
#
# Usage:
#   drupal-resync <SOURCE_DRUSH_ALIAS> <DESTINATION_DRUSH_ALIAS> [<MODULES_DISABLE>]
#
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
#   * The Drupal administrator role (with all permissions) is "administrator".
#
# Enhancements:
#   * If you'd like to see database synchronization progress, install the Pipe
#     Viewer utility.  See https://drupal.org/project/drush_sql_sync_pipe for
#     details.
#
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
SUDO=/usr/bin/sudo
CHOWN=/bin/chown

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

# Set variables with defaults and arguments.
SOURCE=$1
DESTINATION=$2

# Set some modules to disable.
MODULES_ACQUIA="acquia_spi acquia_agent"
MODULES_ADVAGG="advagg advagg_js_compress advagg_mod advagg_css_compress advagg_css_cdn advagg_js_cdn advagg_bundler"
MODULES_DISABLE="backup_migrate performance entitycache overlay toolbar $MODULES_ACQUIA $MODULES_ADVAGG $3"

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

$ECHO "Sync the source site's database to the destination..."
# Always download and use Drush SQL Sync Pipe instead of Drush's standard
# sql-sync command.  It's more efficient, skips cache data by default, and
# actually works on Pantheon sites.
#
# The "--dump" command would be useful for local caching, but it's currently
# broken.  See https://drupal.org/node/2286697 for details.
$DRUSH dl drush_sql_sync_pipe --destination=$HOME/.drush -y
$DRUSH sql-sync-pipe --progress --sanitize $CONFIRMATION $SOURCE $DESTINATION

$ECHO "Rebuild the registry in case file locations have changed..."
$DRUSH dl -y registry_rebuild
$DRUSH $DESTINATION registry-rebuild

$ECHO "Updating the database schema..."
$DRUSH $DESTINATION updatedb -y

$ECHO "Revert all features to those in the code..."
# We need the cache-clear for https://drupal.org/node/1822278.
$DRUSH $DESTINATION cc all
$DRUSH $DESTINATION features-revert-all -y

$ECHO "Disabling modules not meant for development..."
$DRUSH $DESTINATION dis -y $MODULES_DISABLE

$ECHO "Enabling extra modules for development..."
$DRUSH $DESTINATION en -y devel syslog update admin_menu

$ECHO "Disabling the destination's CSS & JavaScript caching..."
$DRUSH $DESTINATION vset preprocess_css 0
$DRUSH $DESTINATION vset preprocess_js 0

$ECHO "Set the destination's logging identity & facility..."
$DRUSH $DESTINATION vset syslog_identity drupal-$DB_IDENTITY
$DRUSH $DESTINATION vset syslog_facility $LOG_LOCAL0

$ECHO "Set the destination's temporary & files directories..."
$DRUSH $DESTINATION php-eval "variable_set('file_temporary_path', '/tmp')"
$DRUSH $DESTINATION php-eval "variable_set('file_public_path', 'sites/default/files')"

$ECHO "Enable error reporting on the destination site..."
$DRUSH $DESTINATION php-eval "variable_set('error_level', ERROR_REPORTING_DISPLAY_ALL)"

$ECHO "Disable user-initiated cron runs..."
$DRUSH $DESTINATION php-eval "variable_set('cron_safe_threshold', '0')"

$ECHO "Clearing the destination site's cache..."
$DRUSH $DESTINATION cc all

$ECHO "Updating the files directory..."
# Transfer files ownership back to the current user for the rsync.
$SUDO $CHOWN -R $USER $($DRUSH dd $DESTINATION:%files)
$DRUSH rsync $CONFIRMATION $SOURCE:%files $DESTINATION:%files
# And then set it back to the Web user.
$SUDO $CHOWN -R $USER_WEB $($DRUSH dd $DESTINATION:%files)

$ECHO "Run any periodic tasks that should be run..."
$DRUSH $DESTINATION cron

$ECHO "Creating an administrator user with your username..."
$DRUSH $DESTINATION user-create $USER --mail="$USER@example.com" --password="letmein"
$DRUSH $DESTINATION user-add-role administrator --name=$USER

$ECHO "All done!"
$ECHO "End time: $($DATE +%T)"
