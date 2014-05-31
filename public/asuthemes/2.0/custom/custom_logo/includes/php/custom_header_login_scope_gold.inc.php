 <!-- START GOLD HEADER-->
   <div id="asu_gold_hdr">
	<?php include($_SERVER['DOCUMENT_ROOT'] . $GLOBALS['base_path']  . path_to_theme() . '/custom_logo.php'); ?>
      
	<?php include('/afs/asu.edu/www/asuthemes/2.0/includes/html/asu_universal_nav.shtml'); ?>
	
      <!-- START LOGIN SEARCH MODULE -->
      <div id="asu_login_search">
        <!-- START USER LOGIN MODULE -->
        <ul id="asu_login_module">
			<?php 
			global $user; 
			if ($user->uid) {
			print "<li class='first'>" . $user->name . "</li>";
			} 
			?>
			<li class="last">
			<?php
			if ($user->uid) {
			  print l(t('SIGN OUT'), 'logout');
			} else {
			  print l(t('SIGN IN'), 'user', array(), 'destination='.$_REQUEST['q']);
			}
			?>
			</li>
        </ul>
        <!-- end user login module -->

  	 <?php include('/afs/asu.edu/www/asuthemes/2.0/custom/clas/includes/php/clas_search_scope.php'); ?>
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
	
