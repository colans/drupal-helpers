Drupal Helpers
==============

The tools in this project are primarily used for deployment and other devops
tasks essential for managing Drupal sites.

Authoritative project (for creating issues, merge/pull requests and the wiki):
* GitLab: https://gitlab.com/colan/drupal-helpers

Mirror (issues, merge/pull requests and the wiki are disabled):
* GitHub: https://github.com/colans/drupal-helpers

At the time of this writing, the following items are included:

File | Description
--- | ---
drush/default.alias.drushrc.php | A standard Drush alias configuration, used as a parent by other site aliases.
drush/drush.ini | A standard drush.ini to be used everywhere for Drush configuration.
scripts/backup-drupal-db | Backs up a Drupal site's database and deletes old backups independent of Drupal, meant to be run from Cron.
scripts/deploy-drupal-code-dev | Deploys the latest developer code onto the development/integration site.
scripts/deploy-drupal-code-prod | Deploys a Git-tagged version of the code onto the production site.
scripts/deploy-drupal-code-qa | Deploys a Git-tagged version of the code onto the staging/QA site.
scripts/deploy-solr-on-glassfish.sh | Deploys the Solr search engine onto the GlassFish application server.
drupal-remake.sh | Rebuilds a Drupal site using the site's most recent Drush makefile.
scripts/resync-drupal-db-for-dev.sh | Refreshes any development site from a staging/QA or production site, setting everything for development and disabling things not useful for development.
