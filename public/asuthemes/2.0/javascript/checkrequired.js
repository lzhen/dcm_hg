//CVS:       $Id: checkrequired.js,v 1.1.1.1 2007/03/08 21:46:21 cvsdevel Exp $
//Title:     checkrequired.js
//Version:   1.01
//Copyright: Copyright (c) 2006
//Author:    REVIE
//Company:   Rhino Internet

/**
 * Utility which checks to verify that all required fields have been
 * filled in by the user, without requiring a round-trip to the server
 * before validating.  Checks the formhandler hidden configuration
 * parameter "required" to figure out which fields are to be checked.
 * <p>
 * To use, simply add the following to your <code>&lt;form&gt;</code> tag:
 * <pre>
 *   &lt;form ... onsubmit="return checkRequired(this);"&gt;
 * </pre>
 * <p>
 * And, this library supports the formhandler-specific "required_rules"
 * data validation rules, where the form designer can define the list
 * of regular expressions that each form input must match in order
 * to be accepted by the system.  For example, to verify that an
 * email field has an "@" sign, you would do:
 * <pre>
 *  &lt;input type="hidden" name="required_rules" value="email:\@" /&gt;
 * </pre>
 * For information on all the specific rules for this parameter, see
 * the formhandler CGI documentation ("required_rules" functionality added
 * in v1.27).
 * <p>
 * And finally, if the custom hidden parameter "change_required" is provided,
 * this provides the ability for the system to conditionally change
 * form requirements.  For example, the following:
 * <pre>
 *   &lt;input type="hidden" name="change_required"
 *                        value="email|street,city,state,zip" /&gt;
 * </pre>
 * requires that the user either enter an email address or mailing address
 * information.  Separate multiple checks with the semicolon (";").
 * This parameter is not a formhandler configuration item, so for now,
 * this javascript is the only one that recognizes this parameter.
 *
 * <p>
 * <b>Changelog:</b><pre>
 *  1.00  REVIE 2006/05/19  created.
 *  1.01  REVIE 2006/10/31  added "required_rules" checking.
 * </pre>
 *
 * @author  REVIE
 * @version 1.01
 * @since   formhandler.cgi 1.27
 */

/**
 * Main method which checks the specified form and verifies that the user
 * has filled in all required fields.  Returns <code>TRUE</code> if
 * the user has filled in all required fields, or displays an error
 * to the user if there are still fields that must be filled in.
 *
 * @param form the form object that contains the "required" configuration
 *        parameter which identifies the form fields to check.
 * @param debug if set to "true", then this turns on debugging and displays
 *        errors if having problems accessing specified form fields.
 * @return <code>TRUE</code> if all of the required fields are filled in
 *        (or no required fields specified), or displays an error to the
 *        user if there are required fields that still need to be filled out.
 */
function checkRequired(form, debug) {
   // find the actual form reference
   if ((!form || !form.required) && document.forms) {
      for (var j = 0; document.forms[j]; j++) {
         if (document.forms[j] && document.forms[j].required) {
            form = document.forms[j];
            break;
         }
      }
   }

   // see if the "required" configuration parameter is set..
   if (!form) {
      if (debug) {
         alert('Cannot find the form to check!');
      }
      return false;
   } else if (debug == null && form.debug) {
      debug = form.debug.value;
   }

   if (!form.required) {
      if (debug) {
         alert('No "required" parameter set to check!');
      }
   } else {
      // see if we are overriding the required fields parameter..
      if (form.change_required && form.change_required.value) {
         // first, adjust the "required fields" parameter before continuing
         var checks = form.change_required.value.split(";");
         for (var i = 0; i < checks.length; i++) {
            var check = checks[i].split("|");
            var pos = -1;
            var closest = -1; var lastmatches = 0;
            var ignore = new Array();
            for (var j = 0; j < check.length; j++) {
               var fields = check[j].split(",");
               if (fields.length > 0) {
                  var matches = 0;
                  for (var k = 0; k < fields.length; k++) {
                     ignore.push(fields[k]);
                     var item = eval('form.' + fields[k]);
                     if (item && item.value && item.value.length > 0) {
                        matches++;
                     }
                  }

                  if (matches > 0 && matches == fields.length) {
                     if (pos < 0) {
                        pos = j;
                     }
                  } else if (matches > lastmatches) {
                     closest = j;
                     lastmatches = matches;
                  }
               }
            }

            // if no exact match, use closest match (if any)
            if (pos < 0 && lastmatches >= 0) {
               pos = lastmatches;
            }

            // update required fields
            if (pos >= 0) {
               var fields = form.required.value.split(",");
               var required = new Array();
               for (var j = 0; j < fields.length; j++) {
                  var valid = true;
                  for (var k = 0; k < ignore.length && valid; k++) {
                     if (fields[j] == ignore[k]) {
                        valid = false;
                     }
                  }

                  if (valid) {
                     required.push(fields[j]);
                  }
               }

               required.push(check[pos].split(","));
               form.required.value = required.join(",");
            }
         }
      }

      // now, we can check required fields
      var fields = form.required.value.split(",");
      var missing = new Array();
      for (var j = 0; j < fields.length; j++) {
         var item = eval('form.' + fields[j]);
         if (!item) {
            if (debug) {
               alert('Cannot find form field "' + fields[j] + '"!');
               missing.push(fields[j]);
            }
         } else if (item.value == null || item.value.length == 0) {
            missing.push(fields[j]);
         }
      }

      // if errors, display to user
      if (missing.length > 0) {
         var msg = 'Please fill in the following fields before submitting:';
         for (var j = 0; j < missing.length; j++) {
            msg += "\n - " + pretty(missing[j]);
         }

         alert(msg);
         return false;
      }
   }

   // otherwise, check to see if there are any "required_rules"
   if (form.required_rules && form.required_rules.value) {
      var fields =
         form.required_rules.value.replace('\\|', '<<<<<').split('|');
      var missing = new Array();
      for (var i = 0; i < fields.length; i++) {
         var rules = fields[i].
            replace('<<<<<', '\\|').
            replace('\\:', '>>>>>').
            split(':');
         var input = rules[0].replace('>>>>>', ':');
         var regex = rules[1].replace('>>>>>', ':');
         var min = null;
         if (rules.length > 2) {
            min = rules[2];
         }

         var max = null;
         for (var j = 3; j < rules.length; j++) {
            if (max == null) {
               max = '';
            } else {
               max = ':';
            }

            max += rules[j].replace('>>>>>', ':');
         }

         // get the value to check
         var val = null;
         for (var j = 0; j < form.elements.length; j++) {
            if (form.elements[j] && form.elements[j].name &&
                form.elements[j].name == input) {
               val = form.elements[j].value;
            }
         }

         var valid = true;
         if (val == null) {
            if (debug) {
               alert('Cannot find the value for "' + input + '"!');
            }
         } else if (min != null && !min.match(/^\d+$/) &&
                    max != null && !max.match(/^\d+$/)) {
            // is "alternate" version for formatting reasons.  ignore
            if (debug) {
               alert('Formatting rule for "' + input + '".  Ignored.');
            }
         } else if (val.length == 0) {
            if (debug) {
               alert('No data provided for "' + input + '".  Regex skipped.');
            }
         } else if (regex != null && regex.length > 0) {
            // see if regex is actually for "opposite"
            var opposite = false;
            var result = regex.match(/^!(.*)$/);
            if (result != null) {
               regex = result[1];
               opposite = true;
            }

            // run regex
            try {
               var re = new RegExp(regex);
               re.ignoreCase = true;
               re.multiline = true;
               result = re.exec(val);

               valid = (result == null ? false : true);
               if (opposite) {
                  valid = (valid ? false : true);
               }
            } catch (e) {
               if (debug) {
                  alert('Exception for "' + regex + '":' + "\n" + e);
               }
            }
         } else if (debug) {
            alert('No regular expression provided for checking "' +
                  input + '".');
         }

         if (!valid) {
            missing.push(pretty(input) + ' provided appears to be invalid.');
         } else if (min != null && min.match(/^\d+$/) &&
                    val.length < parseInt(min)) {
            missing.push(pretty(input) + ' is too short.  It must be ' +
                         'at least ' + min + ' characters long.');
         } else if (max != null && max.match(/^\d+$/) &&
                    val.length < parseInt(max)) {
            missing.push(pretty(input) + ' is too long.  It cannot exceed ' +
                         max + ' characters.');
         }
      }

      // if errors, display to user
      if (missing.length > 0) {
         var msg = 'The following problems were found with your input:';
         for (var i = 0; i < missing.length; i++) {
            msg += "\n - " + missing[i];
         }

         alert(msg);
         return false;
      }
   }

   // everything turned out fine.  can submit the form.
   if (debug) {
      alert('Form data validated successfully.');
   }
   return true;
} // checkRequired

/**
 * "Pretty"-ifies the variable name to make it more presentable
 * to the user in an error message.
 *
 * @param val the name of the variable to make "pretty".
 * @return the more user-friendly version of the variable name.
 */
function pretty(val) {
   if (val == null) {
      val = '';
   }

   // perl format (convert underscores to spaces)
   val = val.replace(/_/g, ' ');
   // java format (mixed-case variable names)
   val = val.replace(/([a-z])([A-Z])/, "$1 $2");

   // capitalize val
   return val.toLowerCase().capitalize();
} // pretty

/**
 * Extend's javascript's handling of strings to be able to capitalize
 * variable names to make the error display easier to read.
 *
 * @return the capitalized version of the string.
 */
String.prototype.capitalize = function() {
   return this.replace(/\w+/g, function(a) {
      return a.charAt(0).toUpperCase() + a.substr(1).toLowerCase();
   });
};
