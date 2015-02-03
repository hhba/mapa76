/**
 * VIEW: Document List (Project)
 *
 */

var
  template = require('./templates/documentList.hbs'),
  Document = require('./DocumentItem'),
  LoadingView = require("../Loading");

module.exports = Backbone.Marionette.CompositeView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  itemViewContainer: "ul.documents",
  itemView: Document,

  ui: {
    selectionAll: ".selection-all",
    sortTitle: ".sort-title",
    sortDate: ".sort-date",
    sortMenu: "#order-for",
    docsList: "ul.documents",
    backButton: ".back-bt",
    clearSearch: ".clear-search"
  },

  events: {
    "click .sort-title": "toggleSortTitle",
    "click .sort-date": "toggleSortDate",
    "click #order-for": "toggleSortMenu",
    "click .clear-search": "clearSearch",
    "change .selection-all": "toggleSelectAll"
  },

  collectionEvents: {
    'request': 'showLoading',
    'sync': 'hideLoading',

    "add": "scrollBottom",
    "searching": "updateCSSClass searching"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onDomRefresh: function(){
    this.showLoading();
  },

  toggleSelectAll: function() {
    if (this.ui.selectionAll.is(':checked')) {
      this.onCheck();
    } else {
      this.onUncheck();
    }
  },

  showLoading: function(){
    var loading = new LoadingView();
    loading.render();
    this.ui.docsList.append(loading.$el);
  },

  hideLoading: function(){
    this.ui.docsList.children(".loading").remove();
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  clearSearch: function(){
    this.ui.backButton.hide();
    this.collection.clearSearch();
  },

  searching: function(){
    this.ui.backButton.show();
  },

  toggleSortTitle: function(){
    var order = this.ui.sortTitle.hasClass("desc") ? "asc" : "desc";
    this.collection.changeSort("title", order);
    this.ui.sortTitle.toggleClass("asc").toggleClass("desc");
  },

  toggleSortDate: function(){
    var order = this.ui.sortDate.hasClass("desc") ? "asc" : "desc";
    this.collection.changeSort("created_at", order);
    this.ui.sortDate.toggleClass("asc").toggleClass("desc");
  },

  onCheck: function(){
    this.collection.toggleSelect(true);
  },

  onUncheck: function(){
    this.collection.toggleSelect(false);
  },

  toggleAll: function(selected){
    this.collection.toggleSelect(selected);
  },

  toggleSortMenu: function(e){
    this.ui.sortMenu.toggleClass('active');
    if (e){
      e.preventDefault();
      e.stopPropagation();
    }
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  updateCSSClass: function(){
    if (this.collection.isSearch){
      this.ui.docsList.addClass("search-result");
    }
    else {
      this.ui.docsList.removeClass("search-result");
    }
  },

  scrollBottom: function(){
    //TODO: send UL scroll to bottom to reflect the new documents added.
  }

});
