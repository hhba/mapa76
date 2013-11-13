/**
 * VIEW: Document List
 * 
 */

var 
  template = require('./templates/documentList.tpl'),
  Document = require('./DocumentItem');

module.exports = Backbone.Marionette.CompositeView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  itemViewContainer: "ul.documents",
  itemView: Document,

  ui: {
    selectionAll: ".selection-all"
  },

  events: {
    "click .selection-all": "toggleAll"
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

  toggleAll: function(){
    var selected = this.ui.selectionAll.is(":checked");
    this.collection.toggleSelect(selected);
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});