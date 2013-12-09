/**
 * VIEW: Document Summary
 * 
 */

var template = require('./templates/documentHighlight.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  className: "clearfix",
  template: template,

  templateHelpers: function(){
    var baseUrl = aeolus.baseRoot + "/documents/" + this.docId;
    
    return {
      pageURL: baseUrl + "/comb"
    };
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  initialize: function(options){
    this.docId = options.documentId;
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