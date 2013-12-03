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

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    this.visualizer.show(new Visualizer({
      model: this.model
    }));
    
    this.pager.show(new Pager({
      model: this.model
    }));

    this.model.loadPages(1, true);

    this.content.show(new Content({
      model: this.model,
      collection: this.model.get("documentPages")
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