/**
 * VIEW: Document View
 * 
 */

var 
    template = require('./templates/layout.tpl')
  , Visualizer = require("./Visualizer")
  , Pager = require("./Pager")
  , Content = require("./Content");

module.exports = Backbone.Marionette.Layout.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  regions: {
    "visualizer": ".header .visualizer",
    "pager": ".header .pager",
    "content": ".content"
  },

  modelEvents: {
    "change": "render"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    this.visualizer.show(new Visualizer());
    
    this.pager.show(new Pager({
      model: this.model
    }));

    this.content.show(new Content({
      model: this.model,
      collection: this.model.get("documentPages")
    }));

    this.model.loadPages(1);
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