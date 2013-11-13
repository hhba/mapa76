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

  events: {
    "click .delete": "deleteDocument"
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
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});