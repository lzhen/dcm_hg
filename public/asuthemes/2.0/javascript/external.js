//CVS:       $Id: external.js,v 1.1.1.1 2007/03/08 21:46:21 cvsdevel Exp $
//Title:     external.js
//Version:   1.00
//Copyright: Copyright (c) 2006
//Author:    REVIE
//Company:   Rhino Internet

/**
 * Utility library which parses the DOM tree and points all anchor tags
 * within the tree and marked with a rel="external" tag to open in a
 * new window.  Created to provide XHTML-strict compatability.
 * <p>
 * Original version of functionality provided by
 * <a href="http://www.sitepoint.com/article/standards-compliant-world/"
 *    rel="external">SitePoint</a>.
 *
 * <p>
 * <b>Changelog:</b><pre>
 *  1.00  REVIE 2006/10/31  created.
 * </pre>
 *
 * @author  REVIE
 * @version 1.00
 */

// -----------------------------------------------
//
//  main methods
//

/**
 * Parses the DOM tree, and attempts to change all anchor tags that
 * have a 'rel="external"' tag associated to open in a new window.
 */
function externalLinks() {
   if (document.getElementsByTagName) {
      var anchors = document.getElementsByTagName('a');
      for (var i = 0; i < anchors.length; i++) {
         var anchor = anchors[i];
         if (anchor.getAttribute('href') &&
             anchor.getAttribute('rel') == 'external')
            anchor.target = '_blank';
      }
   }
} // externalLinks

// run the method on page load
if (window.onload != null) {
   var func = window.onload;
   window.onload = function() { func(); externalLinks(); };
} else {
   window.onload = externalLinks;
}
