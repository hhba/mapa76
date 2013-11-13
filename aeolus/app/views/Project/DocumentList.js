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
  itemView: Document

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

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