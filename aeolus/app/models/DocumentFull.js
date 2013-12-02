
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

    //TODO: Remove this when new API is built

    response.counter = {
      people: ctx.people.length,
      organizations: ctx.organizations.length,
      places: ctx.places.length,
      dates: ctx.dates.length
    };

/*
    response.people = new People(ctx.people);
    response.organizations = new Organizations(ctx.organizations);
    response.places = new Places(ctx.places);
    response.dates = new Dates(ctx.dates);
*/

    delete response.context_cache;
    return response;
  },

  //TODO: Merge this method with Project:getListByTypes
  getListByTypes: function(type){
    var collection;
      
    switch(type){
      case "people": 
        collection = new People(); 
        break;
      case "organizations": 
        collection = new Organizations(); 
        break;
      case "places": 
        collection = new Places(); 
        break;
      case "dates": 
        collection = new Dates(); 
        break;
    }

    //TODO: Use /documents/:id/people

    collection.fetch({ 
      reset: true, 
      xDocumentIds: [this.get("id")]
    });

    return collection;
  }

});