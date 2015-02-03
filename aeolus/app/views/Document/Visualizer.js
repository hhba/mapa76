
/**
 * VIEW: Visualizer
 * 
 */

var 
    template = require('./templates/visualizer.hbs');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  tagName: 'ul',
  className: 'eye-list clearfix',

  ui: {
    people: ".people",
    organizations: ".organizations",
    places: ".places",
    dates: ".dates"
  },

  events:{
    "click input[type=checkbox]": "updateSelected"
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

  updateSelected: function(){
    this.model.set("selected", {
      people: this.ui.people.is(":checked"),
      organizations: this.ui.organizations.is(":checked"),
      places: this.ui.places.is(":checked"),
      dates: this.ui.dates.is(":checked")
    });
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});