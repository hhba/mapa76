
var settings = require('./settings')();

module.exports = function(){
  
  window.aeolus = settings;

  var authKey = $("body").attr("data-user-auth");
  window.aeolus.authKey = authKey || "";

  require('./helpers/jQueryOverrides');
  require('./helpers/backboneOverrides');
  require('./helpers/handlebars');

  moment.lang("es");

  window.aeolus.startApp = require('./AeolusApp');
};