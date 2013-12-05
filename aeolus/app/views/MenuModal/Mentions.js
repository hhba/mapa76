/**
 * VIEW: Document Collection of mentions for a person
 * 
 */

var 
    template = require('./templates/mentions.tpl')
  , Mention = require("./Mention");

module.exports = Backbone.Marionette.CompositeView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  itemViewContainer: ".mentions",
  itemView: Mention,

  events: {
    "click .more-list-close": "close"
  }

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