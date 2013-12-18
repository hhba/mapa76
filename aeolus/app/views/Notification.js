/*
 * VIEW: Notification
 */

var template = require('./templates/notification.tpl');

module.exports = Backbone.Marionette.Notification.extend({
  tagName: 'div',
  classname: 'notification',
  template: template,

  initialize: function(options){
    this.options = options;
    if(!options.klass) {
      this.options.klass = 'success';
    }
  },

  serializeData: function(){
    return {
      message: this.options.message,
      klass: this.options.klass
    };
  }
});
