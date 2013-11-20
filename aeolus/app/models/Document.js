
var DocumentHighlights = require("./DocumentHighlights");

module.exports = Backbone.Model.extend({
 
  defaults: {
    title: "Untitle",
    description: "None",

    people: 0,
    dates: 0,
    organizations: 0,
    places: 0,

    selected: false
  },

  parse: function(response){
    if (response.hasOwnProperty("highlight")){
      response.highlights = new DocumentHighlights(response.highlight, { parse: true });
    }
    return response;
  },

  flag: function(){
    $.ajax({
      url: this.url() + "/flag",
      type: "POST",
      cache: false,
      context: this
    }).done();
  }

});