
var 
    People = require("./People")
  , Organizations = require("./Organizations")
  , Places = require("./Places")
  , Dates = require("./Dates");

module.exports = Backbone.Model.extend({
  
  urlRoot: function(){
    return aeolus.rootURL + "/documents"; 
  },

  parse: function(response){
    var ctx = response.context_cache;

    response.counter = {
      people: ctx.people.length,
      organizations: ctx.organizations.length,
      places: ctx.places.length,
      dates: ctx.dates.length
    };

    response.people = new People(ctx.people);
    response.organizations = new Organizations(ctx.organizations);
    response.places = new Places(ctx.places);
    response.dates = new Dates(ctx.dates);

    delete response.context_cache;
    return response;
  },

  getListByTypes: function(type){
    return this.get(type);
  }
  
});