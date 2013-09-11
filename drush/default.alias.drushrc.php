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
          'cache_block',
          'cache_bootstrap',
          'cache_commerce_cybersource_taxes',
          'cache_commerce_shipping_rates',
          'cache_content',
          'cache_entity_comment',
          'cache_entity_commerce_product',
          'cache_entity_file',
          'cache_entity_node',
          'cache_entity_taxonomy_term',
          'cache_entity_taxonomy_vocabulary',
          'cache_entity_user',
          'cache_field',
          'cache_filter',
          'cache_form',
          'cache_htmlpurifier',
          'cache_image',
          'cache_location',
          'cache_luceneapi',
          'cache_menu',
          'cache_metatag',
          'cache_page',
          'cache_path',
          'devel_queries',
          'cache_rules',
          'cache_token',
          'cache_update',
          'cache_views',
          'cache_views_data',
          'devel_queries',
          'devel_times',
          'history',
          'search_index',
          'search_dataset',
          'sessions',
          'watchdog',
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

