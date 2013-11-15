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

