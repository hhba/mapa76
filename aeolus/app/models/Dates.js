
var DateModel = require("./Date");

module.exports = Backbone.Collection.extend({

  model: DateModel,

  url: function(){
    return aeolus.rootURL + "/date_entities"; 
  },

  changeSort: function(prop, order) {
    order = typeof order !== 'undefined' ? order : 'asc';
    order = order === "asc" ? -1 : 1;

    this.comparator = function(a, b){
      if(a.get(prop) > b.get(prop)) { return -order; }
      if(a.get(prop) < b.get(prop)) { return order; }
      return 0;
    };

    this.sort().trigger('reset');
  }

});