
var settings = require('./settings')();

module.exports = function(){

  window.aeolus = settings;

  window.aeolus.app = require('./AeolusApp');
  window.aeolus.app.start();

};