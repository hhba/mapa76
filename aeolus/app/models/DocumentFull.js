
var 
    People = require("./People")
  , Organizations = require("./Organizations")
  , Places = require("./Places")
  , Dates = require("./Dates")
  , DocumentPages = require("./DocumentPages");

module.exports = Backbone.Model.extend({
  
  defaults: {
    selected: {
      people: true,
      organizations: true,
      places: true,
      dates: true
    }
  },

  urlRoot: function(){
    return aeolus.rootURL + "/documents"; 
  },

  parse: function(response){
    response.counter = response.counters;
    return response;
  },

  loadPages: function(index, reset){

    if (!this.get("documentPages")){
      this.set("documentPages", new DocumentPages({
        id: this.get("id")
      }));
    }

    this.get("documentPages").fetch({
      xPages: [index, index+1, index+2],
      reset: reset || false
    });

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