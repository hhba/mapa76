/**
 * VIEW: Toolbar
 * 
 */

var 
    template = require("./templates/toolbar.tpl")
  , DocumentNew = require("./DocumentNew");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    multiOptions: ".multi",
    subMenu: ".sub-menu"
  },

  events: {
    "click #upload": "showNewDocument",
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
  },

  showNewDocument: function(){
    var newDocForm = new DocumentNew();
    newDocForm.render();
    this.ui.subMenu.empty().append(newDocForm.$el);
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});