//CVS:       $Id: menu.js,v 1.1 2007/03/22 17:54:55 cvsdevel Exp $
//Title:     menu.js
//Version:   1.01
//Copyright: Copyright (c) 2007
//Author:    REVIE
//Company:   Rhino Internet

/**
 * Handles the functionality for a "tree"-view of navigational menu items.
 * Requires that there be a menu list of navigational items in a <ul>
 * list tree, properly nested.
 *
 * <p>
 * <b>Changelog:</b><pre>
 *  1.00  REVIE 2007/01/15  created.
 *  1.01  REVIE 2007/01/25  better URL matching for selected nav.
 * </pre>
 *
 * @author  REVIE
 * @version 1.01
 */

// -----------------------------------------------
//
//  configuration
//

/** Name of the element where the menu navigation is located. */
var cssMenuId = 'asu_nav';

/** Name of class to use for "closed" menu elements. */
var cssMenuClosed = 'closed';
/** Name of the class to set "opened" menu elements to. */
var cssMenuOpened = 'opened';
/** Name of the class to set default selected menu elements to. */
var cssMenuSelected = 'selected';

/**
 * Set to "true" if wanting to close previously-opened elements when
 * opening a new navigational area ("false" means user can have as
 * many open elements as desired).
 */
var cssMenuOnlyOne = true;

// -----------------------------------------------
//
//  variables
//

/** The currently opened navigational element. */
var cssMenuActive = null;

// -----------------------------------------------
//
//  main methods
//

/**
 * Recursively checks an element, and builds the javascript onstate handlers
 * for each nav element.
 *
 * @param menuId if defined, the ID of the element in the DOM tree to
 *        scan for navigational elements.
 */
function initMenu(menuId) {
   if (!menuId) {
      menuId = cssMenuId;
   }

   if (menuId && document.getElementById) {
      traverseMenu(document.getElementById(menuId));
   }
} // initMenu

/**
 * Recursive function which traverses the provided element and
 * sets the appropriate handlers for each navigational element found.
 * <p>
 * Bitmap set follows the following format:
 * <ul>
 * <li>"1": element is a node (unset means element is a leaf).</li>
 * <li>"2": element contains the active node.</li>
 * <li>"4": element is the active anchor node.</li>
 * </ul>
 * 
 * @param elem the element to recursively scan for menu items to
 *        add event handlers to.
 * @return a bitmap defining if the item is a navigational element.
 */
function traverseMenu(elem) {
   var props = 0;

   if (!elem) {
      return props;
   }

   if (elem.childNodes) {
      for (var i = 0; i < elem.childNodes.length; i++) {
         var child = elem.childNodes[i];
         props |= traverseMenu(child);
      }
   }

   var name = elem.tagName;
   if (name) {
      switch (name.toLowerCase()) {
         case 'ul':
            // beginning of a possible nav section
            props |= 1;
            elem.onclick = ignoreMenu;
            break;

         case 'li':
            // navigational element item?
            if (props & 1) {
               // add onclick handler
               elem.onclick = openCloseMenu;
               if (props & 6) {
                  addClassToMenu(elem, cssMenuOpened);
                  addClassToMenu(elem, cssMenuSelected);
               } else {
                  addClassToMenu(elem, cssMenuClosed);
               }
            }

            if (props & 4) {
               addClassToMenu(elem, cssMenuSelected);
               if (props & 1) {
                  cssMenuActive = elem;
               }

               props |= 2; // make sure parents are opened
               props &= 3; // clear "end-point" selection
            }
            break;

         case 'a':
            props |= isSameURL(location.href, elem.getAttribute('href'));
            break;
      }
   }

   return props;
} // traverseMenu

/**
 * Checks to see if the two URLs are the same (or URL <code>a</code>
 * is a sub-page of URL <code>b</code>).
 *
 * @param url1 the master URL where we are located at (typically
 *        <code>location.href</code>).
 * @param url2 the URL of the navigational element to compare with.
 * @return <code>2</code> if the user is on a sub-page of <code>url2</code>,
 *       <code>4</code> if <code>url1</code> equals <code>url2</code>, or
 *       <code>0</code> if the two URLs do not match.
 */
function isSameURL(url1, url2) {
   // handle "placeholder" links as "no match"
   var rval = 0;
   if (url2.match(/\#$/)) {
      return rval;
   }

   // compare query string parameters (which can be in any order)
   var result = url2.match(/\?(.*)$/);
   if (result != null) {
      var result2 = url1.match(/\?(.*)$/);
      if (result2 == null) {
         // page does not include have query string parameters
         return rval;
      } else {
         var params = result[1].split(/[&;]/);
         var orig = result2[1].split(/[&;]/);
         var found = true;

         for (var i = 0; i < params.length && found; i++) {
            if (params[i]) {
               found = false;
               for (var j = 0; j < orig.length && !found; j++) {
                  if (orig[j] && orig[j] == params[i]) {
                     found = true;
                  }
               }
            }
         }

         if (!found) {
            // not all parameters found in page url.  pages do not match
            return rval;
         }
      }
   }

   // clean first url (url of page we're on)
   var seps = new Array('?', '#', '/index.');
   for (var i in seps) {
      if (url1.lastIndexOf(seps[i]) >= 0) {
         url1 = url1.substring(0, url1.lastIndexOf(seps[i]));
      }
   }

   // clean second url (navigation url)
   for (var i in seps) {
      if (url2.lastIndexOf(seps[i]) >= 0) {
         url2 = url2.substring(0, url2.lastIndexOf(seps[i]));
      }
   }
   if (!url2.match(/^\w+:\//)) {
      if (!url2.match(/^\//)) {
         url2 = url1.substring(0, url1.lastIndexOf('/')) + '/' + url2;
      } else {
         result = url1.match(/^(\w+:\/+[^\/]+)(\/|$)/);
         if (result != null) {
            url2 = result[1] + url2;
         }
      }
   }
   
   result = url2.match(/^(\w+:\/+[^\/]+\/)(.*)$/);
   if (result != null) {
      url2 = '/' + result[2];
      while (url2.match(/\/\/+/)) {            // double slashes
         url2 = url2.replace(/\/\/+/, '/');
      }
      while (url2.match(/\/\.\//)) {           // "./"
         url2 = url2.replace(/\/\.\//, '/');
      }
      while (url2.match(/\/[^\/]+\/\.\.\//)) { // "../"
         url2 = url2.replace(/\/[^\/]+\/\.\.\//, '/');
      }
      while (url2.match(/\/\.\.?\//)) {        // cleanup
         url2 = url2.replace(/\/\.\.?\//, '/');
      }
      if (url2.indexOf('/') == 0) {
         url2 = url2.substring(1);
      }
      url2 = result[1] + url2;
   }

   // walk through URL tree
   // first, say it matches if on a sub-page under the nav element
   a = url1.split(/[?\/]/);
   b = url2.split(/[?\/]/);
   for (var i = a.length - 1, j = b.length - 1;
        i >= 0 && j >= 0 && rval >= 0; i--) {
      while (i > 0 && !a[i]) { i--; }
      while (j > 0 && !b[j]) { j--; }

      // two portions of url should match on subnav point
      if (i >= 0 && j >= 0 && a[i] == b[j]) {
         if (j > 1 && !rval) {
            rval |= 2;
         }
      } else if (rval) {
         rval = -1;
      }

      if (rval) {
         j--;
      }
   }

   if (rval < 0) {
      rval = 0;
   }

   // if urls are equal, then we are on that page
   if (url1 == url2) {
      rval |= 4;
   }

   //alert(rval + ' = ' + i + ': ' + a[i] + ', ' + j + ': ' + b[j] + '\n' +
   //      'a: ' + a + '\nb: ' + b);
   return rval;
} // isSameURL

/**
 * Sees if a menu element contains a specified class name.
 *
 * @param elem the element to see if the class is assigned to it.
 * @param className the class name to query for.
 * @return <code>TRUE</code> if the class is associated with the specified
 *        menu element <code>elem</code>, <code>FALSE</code> otherwise.
 */
function isClassInMenu(elem, className) {
   if (elem && className && elem.className) {
      var names = elem.className.split(/\s+/);
      for (var i = 0; i < names.length; i++) {
         if (names[i] && names[i] == className) {
            return true;
         }
      }
   }

   // if here, no match found
   return false;
} // isClassInMenu

/**
 * Adds a class name to an element, if the class was not already assigned.
 *
 * @param elem the element to add the class to (or remove from).
 * @param className the class name to add to the element.
 */
function addClassToMenu(elem, className) {
   if (elem && className && !isClassInMenu(elem, className)) {
      elem.className =
         (elem.className ? elem.className + ' ' : '') + className;
   }
} // addClassToMenu

/**
 * Removes a selected stylesheet class from the selected element.
 *
 * @param elem the navigational element to remove the class from.
 * @param className the name of the class to remove.
 */
function removeClassFromMenu(elem, className) {
   if (elem && elem.className && className) {
      var found = false;
      var names = elem.className.split(/\s+/);
      var classstr = '';
      for (var i = 0; i < names.length; i++) {
         if (names[i]) {
            if (names[i] == className) {
               found = true;
            } else {
               classstr += (classstr ? ' ' : '') + names[i];
            }
         }
      }

      if (found) {
         elem.className = classstr;
      }
   }
} // removeClassFromMenu

/**
 * Event click handler which opens (or closes) the menu object.
 *
 * @param e the event handle that executed this action.
 */
function openCloseMenu(e) {
   // make sure "click" is on this element only and not some other element
   e = e || window.Event || window.event;
   // stop event propagation
   if (e.stopPropagation) {
      e.stopPropagation();
   } else {
      e.cancelBubble = true;
   }

   var elem = null;
   if (e) {
      elem = 
         (e.currentTarget ? e.currentTarget :
          e.target ? e.target :
          e.srcElement ? e.srcElement : null);
   }
   if (!elem) {
      elem = this;
   }

   // make sure user is clicking on "open/close" target rather than any
   // sub-elements that might be around
   if (e && elem && elem.childNodes) {
      // get (x, y) coordinates and width/height
      var cpos = getCursorPos(e);
      var mpos = getMenuPos(elem);
      var ul = null;
      var href = null;

      for (var i = 0; i < elem.childNodes.length; i++) {
         var child = elem.childNodes[i];
         if (!ul && child && child.tagName &&
             child.tagName.toLowerCase() == 'ul') {
            ul = child;
         } else if (!href && child && child.tagName &&
                    child.tagName.toLowerCase() == 'a') {
            href = child;
         }
      }

      if (elem && href) {
         var apos = getMenuPos(href);
         var url = href.getAttribute('href');

         if ((cpos.x >= apos.x && cpos.x <= (apos.x + apos.width)) &&
             (cpos.y >= apos.y && cpos.y <= (apos.y + apos.height))) {
            // user clicked on nav.  doesn't want to open menu
            return true;
         }
      }

      if (elem && ul && isClassInMenu(elem, cssMenuOpened)) {
         var apos = getMenuPos(ul);
         if (cpos.y >= apos.y) {
            // click appears to be within sub-level "ul" area.  ignore.
            //alert('Cursor: ' + cpos.x + ',' + cpos.y + '\n' +
            //      'Element "' + elem.tagName + '": ' +
            //      mpos.x + ',' + mpos.y +
            //      ' (' + mpos.width + 'x' + mpos.height + ')\n' +
            //      'Element "' + ul.tagName + '": ' +
            //      apos.x + ',' + apos.y +
            //      ' (' + apos.width + 'x' + apos.height + ')');
            elem = false;
         }
      }
   }

   if (elem && elem.childNodes) {
      // now, see if this element is opened or closed
      if (isClassInMenu(elem, cssMenuOpened)) {
         closeMenu(elem);
      } else {
         openMenu(elem);
      }
   }

   return true;
} // openCloseMenu

/**
 * Attempts to find the exact (x,y) coordinates for the current cursor
 * position, based on the event provided.
 *
 * @param e the event that describes the cursor position.
 * @return the reference to the coordinates of the cursor, or (-1,-1) if
 *        the position could not be determined.
 */
function getCursorPos(e) {
   var pos = new Object();
   if (e) {
      pos.x = e.pageX;
      pos.y = e.pageY;

      if (!pos.x && 0 !== pos.x) {
         pos.x = e.clientX || 0;
         pos.y = e.clientY || 0;

         var ua = (navigator && navigator.userAgent ?
                   navigator.userAgent.toLowerCase() : null);
         if (ua && ua.indexOf('opera') == -1 && ua.indexOf('msie') != -1) {
            if (document.documentElement &&
                (document.documentElement.scrollTop ||
                 document.documentElement.scrollLeft)) {
               pos.x += document.documentElement.scrollLeft || 0;
               pos.y += document.documentElement.scrollTop || 0;
            } else if (document.body) {
               pos.x += document.body.scrollLeft || 0;
               pos.y += document.body.scrollTop || 0;
            }
         }
      }

      return pos;
   } else {
      pos.x = -1;
      pos.y = -1;
   }

   return pos;
} // getCursorPos

/**
 * Returns the positional information for the selected navigational
 * element.
 *
 * @param elem the element to locate the positional information for.
 * @return the object defining the position of the selected element
 *        on the page.
 */
function getMenuPos(elem) {
   var pos = new Object();

   // get (x,y) positional information about element
   pos.x = pos.y = 0;
   var obj = elem;
   do {
      pos.x += obj.offsetLeft || 0;
      pos.y += obj.offsetTop || 0;
   } while (obj = obj.offsetParent);

   // Safari has problems with positioning of tables
   // Get the location of an element above the table and calculate.
   if (navigator.userAgent.toLowerCase().indexOf('safari') != -1 &&
       elem.parentNode) {
      obj = elem;
      while ((obj = obj.parentNode) && obj.tagName &&
             obj.tagName.toLowerCase() != 'table') { ; }
      if (obj && obj.tagName && obj.tagName.toLowerCase() == 'table' &&
          obj.parentNode) {
         var parent = obj.parentNode;
         var found = null;
         for (var i = 0; !found && i < parent.childNodes.length; i++) {
            var child = parent.childNodes[i];
            if (child && child == obj) {
               for (var j = i - 1; !found && j >= 0; j--) {
                  if (parent.childNodes[j].tagName) {
                     found = parent.childNodes[j];
                  }
               }

               if (found) {
                  var tpos = getMenuPos(found);
                  pos.y += tpos.y +
                     (tpos.height ? parseInt(tpos.height) : 0);
               } else if (parent != elem) {
                  var tpos = getMenuPos(parent);
                  pos.x += tpos.x;
                  pos.y += tpos.y;
               }

               found = true;
            }
         }
      }
   }

   // element width and height (for bounding box purposes)
   if (elem.offsetWidth) {
      pos.width = parseInt(elem.offsetWidth);
   }
   if (elem.offsetHeight) {
      pos.height = parseInt(elem.offsetHeight);
   }

   //alert('"' + elem.tagName + '": ' + pos.x + ',' + pos.y +
   //      ' (' + pos.width + ' x ' + pos.height + ')');
   return pos;
} // getMenuPos

/**
 * Sets the attributes to open a specific menu element, and verifies
 * that any previously opened navigational elements are closed.
 *
 * @param elem the menu element to open.
 */
function openMenu(elem) {
   // close any previously opened menus
   if (cssMenuActive && cssMenuOnlyOne && cssMenuActive != elem &&
       !isNavInMenu(cssMenuActive, elem)) {
      while (cssMenuActive && !isNavInMenu(cssMenuActive, elem)) {
         closeMenu(cssMenuActive);
      }
   }

   // make sure all child menus are closed
   if (cssMenuOnlyOne) {
      closeSubMenu(elem);
   }

   // make sure this menu and all parent menus are opened
   for (var parent = elem; parent && parent.tagName &&
           parent.tagName.toLowerCase() == 'li';
        parent = (parent.parentNode ? parent.parentNode.parentNode : null)) {
      removeClassFromMenu(parent, cssMenuClosed);
      addClassToMenu(parent, cssMenuOpened);
   }

   // register opened menu
   cssMenuActive = elem;
} // openMenu

/**
 * Sets the attributes to close a specific menu element.
 *
 * @param elem the menu element to close.
 */
function closeMenu(elem) {
   // make sure "opened" flag is not set
   removeClassFromMenu(elem, cssMenuOpened);
   // now, set "closed" flag
   addClassToMenu(elem, cssMenuClosed);

   // now, set "open" state to element parent
   var parent = null;
   if (elem.parentNode && elem.parentNode.parentNode &&
       elem.parentNode.parentNode.tagName &&
       elem.parentNode.parentNode.tagName.toLowerCase() == 'li') {
      parent = elem.parentNode.parentNode;
   }

   // update "opened" menu status
   if (cssMenuOnlyOne && cssMenuActive) {
      // closing parent must also close children
      while  (cssMenuActive && elem != cssMenuActive && elem != parent) {
         removeClassFromMenu(cssMenuActive, cssMenuOpened);
         addClassToMenu(cssMenuActive, cssMenuClosed);

         if (cssMenuActive.parentNode && cssMenuActive.parentNode.parentNode &&
             cssMenuActive.parentNode.parentNode.tagName &&
             cssMenuActive.parentNode.parentNode.tagName.toLowerCase()=='li') {
            cssMenuActive = cssMenuActive.parentNode.parentNode;
         } else {
            cssMenuActive = null;
         }
      }

      // make sure all child menus are also closed
      closeSubMenu(elem);
   }

   // set the remaining open nav element
   cssMenuActive = parent;

   // make sure parent elements remain open
   while (parent) {
      removeClassFromMenu(parent, cssMenuClosed);
      addClassToMenu(parent, cssMenuOpened);
      parent =
         (parent.parentNode && parent.parentNode.parentNode &&
          parent.parentNode.parentNode.tagName &&
          parent.parentNode.parentNode.tagName.toLowerCase() == 'li' ?
          parent.parentNode.parentNode : null);
   }
} // closeMenu

/**
 * Recursively closes all children of the selected navigational element.
 *
 * @param elem the navigational element to close all children for.
 * @return <code>TRUE</code> if the element does have sub-navigational
 *        elements that are to be closed.
 */
function closeSubMenu(elem) {
   var submenu = false;
   if (elem && elem.childNodes) {
      for (var i = 0; i < elem.childNodes.length; i++) {
         var child = elem.childNodes[i];
         if (child && child.tagName && child.childNodes) {
            // close all children of this element
            var hasSub = closeSubMenu(child);

            switch (child.tagName.toLowerCase()) {
               case 'ul':
                  submenu = true;
                  break;

               case 'li':
                  if (hasSub) {
                     // found navigational element to close
                     submenu = true;
                     removeClassFromMenu(child, cssMenuOpened);
                     addClassToMenu(child, cssMenuClosed);
                  }
                  break;
            }
         }
      }
   }

   return submenu;
} // closeSubMenu

/**
 * Event click handler which tells the browser to ignore any
 * mouse clicks.  Useful for navigation elements that have no sub-nav.
 *
 * @param e the event handle that executed this action.
 */
function ignoreMenu(e) {
   // make sure "click" is on this element only and not some other element
   e = e || window.Event || window.event;
   if (e.stopPropagation) {
      e.stopPropagation();
   } else {
      e.cancelBubble = true;
   }

   return true;
} // ignoreMenu

/**
 * Recursive function which checks to see if an <code>elem</code> is
 * a member of <code>list</code>
 *
 * @param list the list of navigational elements to search.
 * @param elem the element (needle) to find in the haystack.
 * @return <code>TRUE</code> if the element is found in the list,
 *        <code>FALSE</code> if not.
 */
function isNavInMenu(list, elem) {
   var isChild = false;
   if (!list || !elem) {
      return false;
   } else if (elem == list) {
      return true;
   } else if (list.childNodes) {
      for (var i = 0; i < list.childNodes.length; i++) {
         var child = list.childNodes[i];
         if (child && (elem == child || isNavInMenu(child, elem))) {
            return true;
         }
      }
   }

   return false;
} // isNavInMenu

// run the method on page load
if (window.onload != null) {
   var func = window.onload;
   window.onload = function() { initMenu(cssMenuId); func(); };
} else {
   window.onload = function() { initMenu(cssMenuId); }
}
