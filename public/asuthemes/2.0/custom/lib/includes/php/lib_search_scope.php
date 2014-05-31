          <!-- START SEARCH MODULE /asuthemes/2.0/includes/php/asu_search_scope.php -->
          <div id="asu_search_module">
              <!-- START GOOGLE SEARCH FORM -->
              <form action="http://search.asu.edu/search" method="get" name="gs">
                <label class="hidden" for="asu_search"><strong>Search</strong></label>
                <input type="text" name="q" size="32" value="Search" id="asu_search" class="asu_search_box" onfocus="if (this.defaultValue &amp;&amp; this.value == this.defaultValue) { this.value = ''; }" />
                <fieldset class="search_range">
                  <legend>Search Range:</legend>
                  <label for="range_a"><input type="radio" name="site" id="range_a" value="library_collection" checked="checked" />ASU Libraries Site</label>
                  <label for="range_b"><input type="radio" name="site" id="range_b" value="default_collection" />ASU</label>
                </fieldset>
                <input type="image" name="op" src="<?=$httpProtocol?>://www.asu.edu/asuthemes/2.0/images/asu_magglass_goldbg.gif" value="Search" alt="Search" title="search" class="asu_search_button" />
                <input name="sort" value="date:D:L:d1" type="hidden" />
                <input name="output" value="xml_no_dtd" type="hidden" />
                <input name="ie" value="UTF-8" type="hidden" />
                <input name="oe" value="UTF-8" type="hidden" />
                <input name="client" value="asu_frontend" type="hidden" />
                <input name="proxystylesheet" value="asu_frontend" type="hidden" />
              </form>
              <!-- END GOOGLE SEARCH FORM -->
          </div>
          <!-- END SEARCH MODULE -->
        
          <!-- CLEAR ALL FLOATS TO PROP OPEN THE HEADER -->
          <div class="clear">&nbsp;</div>
