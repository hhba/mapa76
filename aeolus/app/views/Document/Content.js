/**
 * VIEW: Document List of Pages View
 * 
 */

var 
  template = require('./templates/content.tpl'),
  Page = require('./Page');

module.exports = Backbone.Marionette.CompositeView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  itemViewContainer: "ul.pages",
  itemView: Page

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