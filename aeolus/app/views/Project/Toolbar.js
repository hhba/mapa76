/**
 * VIEW: Toolbar
 * 
 */

var template = require('./templates/toolbar.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    multiOptions: ".multi"
  },

  events: {
    "click #delete": "removeDocuments"
  },

  modelEvents: {
    "change:counter": "render"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onDomRefresh: function(){
    if (this.model.get("counter").selected > 0){
      this.ui.multiOptions.show();
    }
    else {
      this.ui.multiOptions.hide(); 
    }
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  removeDocuments: function(){
    this.model.get('documents').destroySelecteds();
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});