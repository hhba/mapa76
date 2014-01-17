/**
 * VIEW: Loading
 * Loading view useful to be displayed while fetching collections.
 */
 
var template = require('./templates/loading.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  tagName: "div",
  className: "loading",
  template: template,

  onRender: function(){
    window.aeolus.app.spinner.spin(this.$el[0]);
  }

});