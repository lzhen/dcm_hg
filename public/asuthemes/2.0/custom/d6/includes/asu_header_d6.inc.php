   <div id="asu_gold_hdr">
	<?php include($_SERVER['DOCUMENT_ROOT'] . $GLOBALS['base_path']  . path_to_theme() . '/custom_logo.php'); ?>
      
	<?php include('/afs/asu.edu/www/asuthemes/2.0/includes/html/asu_universal_nav.shtml'); ?>

      <div id="asu_login_search">
		<?=$header_nav?>

		<div id="asu_search_module">
		
<?php # if (!empty($search_box)) { ?>
<?php if(module_exists('scoped_search')) { ?>
	<?php print $search_box; ?>
<?php } else { ?>
<!-- START GOOGLE SEARCH FORM -->
<form action="http://search.asu.edu/search" method="get" name="gs">
	<label class="hidden" for="asu_search"><strong>Search</strong></label>
	<input type="text" name="q" size="32" value="Search" id="asu_search" class="asu_search_box" onfocus="if (this.defaultValue && this.value == this.defaultValue) { this.value = ''; }" />
	<input type="image" name="op" src="<?=$httpProtocol?>://www.asu.edu/asuthemes/2.0/images/asu_magglass_goldbg.gif" value="Search" alt="Search" title="search" class="asu_search_button" />
	<input name="sort" value="date:D:L:d1" type="hidden" />
	<input name="output" value="xml_no_dtd" type="hidden" />
	<input name="ie" value="UTF-8" type="hidden" />
	<input name="oe" value="UTF-8" type="hidden" />
	<input name="client" value="asu_frontend" type="hidden" />
	<input name="proxystylesheet" value="asu_frontend" type="hidden" />
</form>
<!-- END GOOGLE SEARCH FORM -->
<?php } ?>
			
		</div><!-- /#asu_search_module -->
        
          <div class="clear">&nbsp;</div>
      </div><!-- end login search module -->
   </div><!-- end gold header-->  