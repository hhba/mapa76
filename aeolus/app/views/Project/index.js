/**
 * VIEW: Document List (Project)
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
    selectionAll: ".selection-all",
    sortTitle: ".sort-title",
    sortDate: ".sort-date",
    sortMenu: "#order-for"
  },

  events: {
    "click .sort-title": "toggleSortTitle",
    "click .sort-date": "toggleSortDate",
    "click #order-for": "toggleSortMenu"
  },

  collectionEvents: {
    "add": "scrollBottom"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onDomRefresh: function(){
    this.ui.selectionAll
      .iCheck({
        checkboxClass: 'icheckbox_flat-grey left',
        radioClass: 'iradio_flat-grey left',
        increaseArea: '20%'
      })
      .on('ifChecked', this.onCheck.bind(this))
      .on('ifUnchecked', this.onUncheck.bind(this));
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

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

  scrollBottom: function(){
    //TODO: send UL scroll to bottom to reflect the new documents added.
  }

});