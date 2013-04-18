<?php
$aliases['default'] = array(
  'command-specific' => array(
    'sql-sync' => array(
      'simulate'         => '0',
      'structure-tables' => array(
        'truncate' => array(
          'accesslog',
          'cache',
          'cache_apachesolr',
          'cache_filter',
          'cache_menu',
          'cache_page',
          'cache_block',
          'cache_content',
          'cache_form',
          'cache_htmlpurifier',
          'cache_location',
          'cache_luceneapi',
          'cache_rules',
          'cache_update',
          'cache_views',
          'cache_views_data',
          'devel_queries',
          'devel_times',
          'history',
          'sessions',
        ),
      ),
      'skip-tables' => array(
        'ignore' => array(
          /******************************************************************
           * Custom ignores
           ******************************************************************/
          // Don't move Webform data around; it's unnecessary and will
          // overwrite Production.
          // 'webform_submissions',
          // 'webform_submitted_data',
        ),
      ),
    ),
    'download' => array(
      'simulate'    => '0',
      'destination' => 'sites/all/modules',
    ),
    'rsync' => array(
      'simulate' => '0',
      'mode'     => 'rlptDz',
    ),
  ),
);
?>

