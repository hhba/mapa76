
var People = require("./People");

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

    delete response.context_cache;
    return response;
  },

  getListByTypes: function(type){
    return this.get(type);
  }
  
});