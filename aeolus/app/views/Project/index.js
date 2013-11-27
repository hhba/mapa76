
/*
 * Layout for Documents Section
 * 
 */

var 
  template = require("./templates/project.tpl"),
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
    content: ".box-content",
    menu: ".vertical-toolbar"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------
  
  onRender: function(){
    this.toolbar.show(new Toolbar({
      model: this.model
    }));

    this.content.show(new DocumentList({
      collection: this.model.get('documents')
    }));

    this.menu.show(new Menu({
      model: this.model,
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
