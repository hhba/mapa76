/**
 * VIEW: Document View
 * 
 */

var 
    template = require('./templates/layout.tpl')
  , Visualizer = require("./Visualizer")
  , Pager = require("./Pager")
  , DocumentInfo = require("./DocumentInfo")
  , Content = require("./Content");

module.exports = Backbone.Marionette.Layout.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  regions: {
    "documentInfo": ".header .documentInfo",
    "visualizer": ".header .visualizer",
    "pager": ".header .pager",
    "content": ".content-wrapper-doc"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    this.documentInfo.show(new DocumentInfo({
      model: this.model
    }));

    this.visualizer.show(new Visualizer({
      model: this.model
    }));
    
    this.pager.show(new Pager({
      model: this.model
    }));

    this.content.show(new Content({
      model: this.model,
      collection: this.model.get("documentPages")
    }));
    window.model = this.model;
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