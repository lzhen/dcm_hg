 <!-- START GOLD HEADER-->
   <div id="asu_gold_hdr">
	<?php include($_SERVER['DOCUMENT_ROOT'] . $GLOBALS['base_path']  . path_to_theme() . '/custom_logo.php'); ?>
      
	<?php include('/afs/asu.edu/www/asuthemes/2.0/includes/html/asu_universal_nav.shtml'); ?>
	
      <!-- START LOGIN SEARCH MODULE /asuthemes/2.0/includes/html/asu_login_search_module.shtml -->
      <div id="asu_login_search">
  	 <?php include('/afs/asu.edu/www/asuthemes/2.0/includes/php/asu_search.php'); ?>
      </div>
      <!-- end login search module -->
   </div>
   <!-- end gold header-->      

	<!-- START OPTIONAL SECONDARY NAV BAR -->
	<?php if ($secondary_links): ?>
	<div id="secondary" class="clear-block">
	  <?php print theme('menu_links', $secondary_links); ?>
	</div>
	<?php endif; ?>
	<!-- end optional secondary nav bar -->
	

