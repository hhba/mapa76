
var settings = require('./settings')();

module.exports = function(){
  
  window.aeolus = settings;

  require('./helpers/jQueryOverrides');

  window.aeolus.app = require('./AeolusApp');
  window.aeolus.app.start();

};