#!/bin/sh
#############################################################################
# Filename: drupal-remake
# Purpose: Rebuild a Drupal site using the most recent Drush makefile.
# Author: Colan Schwartz
# Licence: GPLv3
#############################################################################

# Make sure that a branch was specified.
if [ -z "$1" ]; then
  echo "Usage: drupal-remake <drush-site-alias>"
  return 1
fi

echo "Start time: $(date +%T)"

# Set command paths.
CHMOD=/bin/chmod
CHOWN=/bin/chown
DRUSH=/usr/bin/drush
GIT=/usr/bin/git
SUDO=/usr/bin/sudo
GZIP=/bin/gzip
RM=/bin/rm
LN=/bin/ln
CP=/bin/cp

# Set targets.
SITE_ALIAS=$1
# This is producing:
# "cannot create /tmp/example.dump.mysql.gz: Directory nonexistent"
#SITE_DUMP=$(drush dd $SITE_ALIAS:%dump).gz
SITE_DUMP=/tmp/$1.dump.mysql.gz
SITE_TREE=$(drush dd $SITE_ALIAS)
SITE_MAKEFILE=example.make # Make this a script argument.
# All sites under sites/ separated by spaces.
SITES="default"
REMOTE=origin # Make this a script argument.
BRANCH=master # Make this a script argument.

# Take the site off-line.
echo "Taking the site off-line..."
$DRUSH $SITE_ALIAS -y variable-set site_offline 1

# Save the database somewhere in case the database updates go awry.
echo "Saving a backup of the existing database..."
$DRUSH $SITE_ALIAS sql-dump --create-db | $GZIP > $SITE_DUMP

# Go to the Git-controlled site directory.
cd $SITE_TREE/..

# Update the repository with new branches and tags.
$GIT fetch --prune --all

# Pull in the latest updates.
echo "Fetching and merging updates..."
$GIT pull $REMOTE $BRANCH

# Toss the existing Drupal file structure.
echo "Deleting existing Drupal tree structure..."
sudo $RM -rf $SITE_TREE

# Rebuild it using the makefile.
echo "Rebuilding Drupal tree structure with Drush make..."
$DRUSH make --concurrency=1 makefiles/$SITE_MAKEFILE $SITE_TREE

# Injecting sites into tree.
echo "Injecting sites into tree..."
cd $SITE_TREE/../sites
$CP -a $SITES ../drupal/sites

# Set appropriate permissions.
# TODO: Remove dependency on https://www.drupal.org/node/990812#comment-6395326.
echo "Set appropriate permissions..."
$SUDO $DRUSH $SITE_ALIAS perms $USER $USER www-data

# Update the database schema.
echo "Updating the database schema..."
$DRUSH $SITE_ALIAS updatedb

# Put the main development site back on-line.
echo "Putting the site back on-line..."
$DRUSH $SITE_ALIAS -y variable-set site_offline 0

# Clear the cache.
echo "Clearing the cache..."
$DRUSH $SITE_ALIAS cache-clear all

echo "All done!"
echo "End time: $(date +%T)"
