/**
 * HELPER: Handlebars Template Helpers
 * 
 */

var Handlebars = require("hbsfy/runtime");

Handlebars.registerHelper('timeAgo', function(date) {
  if (date && moment(date).isValid()) {
    return moment(date).fromNow();
  }

  return "-";
});

Handlebars.registerHelper('formatDate', function(date) {
  if (date && moment(date).isValid()) {
    return moment(date).format("DD/MM/YYYY");
  } 
  
  return "-";
});

Handlebars.registerHelper('formatDateText', function(date) {
  if (date && moment(date).isValid()) {
    return moment(date).format("LL");
  } 
  
  return "";
});

Handlebars.registerHelper('formatDateTextAndTime', function(date) {
  if (date && moment(date).isValid()) {
    return moment(date).format("LLL");
  } 
  
  return "";
});

Handlebars.registerHelper('cutText', function(text, size) {
  if (text.length > size){
    return text.substring(0, size) + "...";
  }

  return text;
});
