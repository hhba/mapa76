
/*
 * Layout for Documents Section
 * 
 */

var 
  template = require("./templates/documents.tpl"),
  Toolbar = require("./Toolbar"),
  Menu = require("./Menu"),
  DocumentList = require("./DocumentList"),
  Documents = require('../../models/Documents');
  
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
  
  initialize: function(){
    this.collection = new Documents();
  },

  onRender: function(){
    this.toolbar.show(new Toolbar());

    this.content.show(new DocumentList({
      collection: this.collection
    }));

    this.menu.show(new Menu({
      collection: this.collection
    }));

    this.collection.fetch({
      reset: true
    });
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
