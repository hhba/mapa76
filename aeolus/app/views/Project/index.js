
/*
 * Layout for Documents Section
 * 
 */

var 
  template = require("./templates/documents.tpl"),
  Toolbar = require("./Toolbar"),
  Menu = require("./Menu"),
  DocumentList = require("./DocumentList");
  
module.exports = Backbone.Marionette.Layout.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  regions: {
    toolbar: ".toolbar",
    content: ".content",
    menu: ".menu"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------
  
  onRender: function(){
    this.toolbar.show(new Toolbar());

    this.content.show(new DocumentList({
      collection: this.model.get('documents')
    }));

    this.menu.show(new Menu({
      collection: this.model.get('documents')
    }));
  }

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});
