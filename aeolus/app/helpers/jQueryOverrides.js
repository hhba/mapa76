/*
 * jQuery Global Overrides or new Features
 *
 */

// Adds the selector :icontains to use :contains but case-insensitive
jQuery.expr[":"].icontains = jQuery.expr.createPseudo(function (arg) {                                                                                                                                                                
    return function (elem) {                                                            
        return jQuery(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0;        
    };                                                                                  
});

// Set default ajaxOptions for authentication.
// If an authentication key is defined, it will be used for every ajax request.
if (aeolus.authKey){
  var opts = {
    headers: {}
  };

  opts.headers[aeolus.headers.authorization] = 'Token token="' + aeolus.authKey + '"';
  
  jQuery.ajaxSetup(opts);
}
