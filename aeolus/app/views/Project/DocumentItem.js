/**
 * VIEW: Document Item List
 * 
 */

var 
    template = require('./templates/documentItem.tpl')
  , DocumentHighlights = require("./DocumentHighlights");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  template: template,

  templateHelpers: function(){
    var baseUrl = aeolus.baseRoot + "/documents/" + this.model.get("id");
    
    return {
      urls: {
        preview: baseUrl + "/comb",
        file: baseUrl + "/download",
        export: baseUrl + "/export"
      }
    };
  },

  ui: {
    selection: ".selection",
    highlights: ".highlights"
  },

  events: {
    "click .delete": "deleteDocument",
    "click .flag": "flagDocument",
    "click .selection": "toggleSelectDocument"
  },

  modelEvents: {
    "change:selection": "render"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    var sums = this.model.get("highlights");
    
    if (sums && sums.length > 0){
      var highlights = new DocumentHighlights({
        model: this.model,
        collection: sums
      });

      highlights.render();

      this.ui.highlights.empty().append(highlights.$el);
    }
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  deleteDocument: function(){
    this.model.destroy();
  },

  flagDocument: function(){
    this.model.flag();
  },

  toggleSelectDocument: function(){
    var checked = this.ui.selection.is(":checked");
    this.model.set("selected", checked);
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});