/**
 * VIEW: Document Collection of mentions for a person
 * 
 */

var 
    template = require('./templates/mentions.hbs')
  , Mention = require("./Mention");

module.exports = Backbone.Marionette.CompositeView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  className: "view-more-list",
  itemViewContainer: ".mentions",
  itemView: Mention,

  events: {
    "click .more-list-close": "close"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  initialize: function(options){
    this.hideClose = (options && options.hideClose) || false;
    this.newClassNames = (options && options.newClassNames) || "";
  },

  onRender: function(){
    if (this.newClassNames){
      this.$el
        .removeClass("view-more-list")
        .addClass(this.newClassNames);
    }
  },

  serializeData: function(){  
    return _.extend({
      hideClose: this.hideClose
    }, ((this.model && this.model.toJSON()) || {}));
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