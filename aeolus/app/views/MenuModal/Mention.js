/**
 * VIEW: A Document where a person has mentions
 * 
 */

var 
    template = require("./templates/mention.tpl");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  className: "clearfix",
  template: template,

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  onDomRefresh: function(){
    this.$el.on('click', this.toggleParagraphs.bind(this));
  },

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  toggleParagraphs: function(){
    
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------



});