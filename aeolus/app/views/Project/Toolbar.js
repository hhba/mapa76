/**
 * VIEW: Toolbar
 * 
 */

var 
    template = require("./templates/toolbar.tpl")
  , DocumentNew = require("./DocumentNew")
  /*, DocumentSearch = require("../../models/DocumentSearch")*/;

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  className: "nav-bar-submenu",

  ui: {
    multiOptions: ".multi",
    subMenu: ".sub-menu",
    searchBox: "#search",
    clearSearch: ".clear-search"
  },

  events: {
    "keyup #search": "onSearchKeyup",
    "click .clear-search": "clearSearch",

    "click #upload": "showNewDocument",
    "click #delete": "removeDocuments"
  },

  modelEvents: {
    "change:counter": "updateCounter"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onDomRefresh: function(){
    this.updateCounter();
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  removeDocuments: function(){
    this.model.get('documents').destroySelecteds();
  },

  showNewDocument: function(){
    var newDocForm = new DocumentNew();
    newDocForm.render();
    this.ui.subMenu.empty().append(newDocForm.$el);
  },

  onSearchKeyup: function(e){
    var key = e.keyCode || e.which;
    if (key === 13){
      this.searchDocuments();
    }
  },

  clearSearch: function(){
    this.ui.searchBox.val("");
    this.ui.clearSearch.hide();
    this.model.get('documents').clearSearch();
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  updateCounter: function(){
    if (this.model.get("counter").selected > 0){
      this.ui.multiOptions.show();
    }
    else {
      this.ui.multiOptions.hide(); 
    }
  },

  searchDocuments: function(){
    var query = this.ui.searchBox.val();
    if (query){
      this.ui.clearSearch.show();
      this.model.get('documents').search(query);
    }
  }

});