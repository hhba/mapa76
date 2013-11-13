/**
 * VIEW: Document Item List
 * 
 */

var template = require('./templates/documentItem.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  template: template,

  templateHelpers: function(){
    var baseUrl = aeolus.rootURL + "/documents/" + this.model.get("id");
    
    return {
      urls: {
        preview: baseUrl + "/comb",
        file: baseUrl + "/download",
        export: baseUrl + "/export"
      }
    };
  },

  ui: {
    selection: ".selection"
  },

  events: {
    "click .delete": "deleteDocument",
    "click .selection": "toggleSelectDocument"
  },

  modelEvents: {
    "change:selection": "render"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  deleteDocument: function(){
    this.model.destroy();
  },

  toggleSelectDocument: function(){
    var checked = this.ui.selection.is(":checked");
    this.model.set("selected", checked);
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});