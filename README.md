Drupal Helpers
==============

The tools in this project are primarily used for deployment and other devops
tasks essential for managing Drupal sites.

For a detailed article on them, please see [Drupal Helpers: Tools for devops and deployment](http://colans.net/blog/drupal-helpers-tools-devops-and-deployment).

Authoritative project (for creating issues, merge/pull requests and the wiki):
* GitLab: https://gitlab.com/colan/drupal-helpers

Mirror (issues, merge/pull requests and the wiki are disabled):
* GitHub: https://github.com/colans/drupal-helpers

Please be aware that each branch represents compatibility with a Drupal core version.  So the *master* branch contains code for the latest stable Drupal release.  For example, at the time of this writing, *master* works with Drupal 8.0.x while *drupal-7.x* works with Drupal 7.

The following items are included:

File | Description
--- | ---
[default.alias.drushrc.php](drush/default.alias.drushrc.php) | A standard Drush alias configuration, used as a parent by other site aliases.
[drush.ini](drush/drush.ini) | A standard drush.ini to be used everywhere for Drush configuration.
[backup-drupal-db](scripts/backup-drupal-db) | Backs up a Drupal site's database and deletes old backups independent of Drupal, meant to be run from Cron.
[deploy-drupal-code-dev](scripts/deploy-drupal-code-dev) | Deploys the latest developer code onto the development/integration site.
[deploy-drupal-code-prod](scripts/deploy-drupal-code-prod) | Deploys a Git-tagged version of the code onto the production site.
[deploy-drupal-code-qa](scripts/deploy-drupal-code-qa) | Deploys a Git-tagged version of the code onto the staging/QA site.
[deploy-solr-on-glassfish](scripts/deploy-solr-on-glassfish) | Deploys the Solr search engine onto the GlassFish application server.
[drupal-remake](scripts/drupal-remake) | Rebuilds a Drupal site using the site's most recent Drush makefile.
[resync-drupal-db-for-dev](scripts/resync-drupal-db-for-dev) | Refreshes any development site from a staging/QA or production site, setting everything for development and disabling things not useful for development.
