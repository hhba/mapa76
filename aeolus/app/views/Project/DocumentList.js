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
    selectionAll: ".selection-all",
    sortTitle: ".sort-title",
    sortDate: ".sort-date"
  },

  events: {
    "click .selection-all": "toggleAll",
    "click .sort-title": "toggleSortTitle",
    "click .sort-date": "toggleSortDate"
  },

  collectionEvents: {
    "add": "scrollBottom"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  /*
  Disabled iCheck cause blowup native events

  onDomRefresh: function(){
    this.ui.selectionAll.iCheck({
      checkboxClass: 'icheckbox_flat-grey left',
      radioClass: 'iradio_flat-grey left',
      increaseArea: '20%'
    });
  },
  */

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

  toggleAll: function(){
    var selected = this.ui.selectionAll.is(":checked");
    this.collection.toggleSelect(selected);
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  scrollBottom: function(){
    //TODO: send UL scroll to bottom to reflect the new documents added.
  }

});