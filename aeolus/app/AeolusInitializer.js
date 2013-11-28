
var settings = require('./settings')();

module.exports = function(){
  
  window.aeolus = settings;

  require('./helpers/jQueryOverrides');
  require('./helpers/backboneOverrides');
  require('./helpers/handlebars');

  moment.lang("es");

  window.aeolus.startApp = require('./AeolusApp');
};