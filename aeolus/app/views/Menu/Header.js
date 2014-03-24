/**
 * VIEW: Header menu
 * 
 */

var template = require('./templates/header.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    searchBox: ".search-box"
  },

  events: {
    "keyup .search-box": "filter",
    "click .sort-name": "sortByName",
    "click .sort-mentions": "sortByMentions"
  },

  templateHelpers: function(){
    var $projectData = $('body').data();
    return {
      projectName: $projectData.name
    };
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

  filter: function(){
    this.trigger("filter", this.ui.searchBox.val());
  },

  sortByName: function(e){
    var target = $(e.target),
        order = this._getOrder(target);
    this.trigger("changeSort", {by: 'name', order: order});
    target.toggleClass("asc").toggleClass("desc");
  },

  sortByMentions: function(e){
    var target = $(e.target),
        order = this._getOrder(target);
    this.trigger("changeSort", {by: 'mentions', order: order});
    target.toggleClass("asc").toggleClass("desc");
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  _getOrder: function(target){
    return (target.hasClass("asc") ? "asc" : "desc");
  }
});