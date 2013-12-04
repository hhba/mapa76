
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
    
    response.documentPages = new DocumentPages({
      id: response.id
    });

    return response;
  },

  moveToPage: function(index){
    if (index < 1){
      return;
    }

    var pages = [];
    var range = aeolus.pagesRange;
    var total = this.get("pages");
    var hRange = Math.ceil(range/2);

    if (index > 0 && index < hRange){
      pages = _.range(1, hRange+2);
    }
    else if (index >= total){
      var ps = total - hRange;
      index = total;

      if (ps < 0){
        ps = hRange;
      }

      pages = _.range(ps, total+1);
    }
    else {
      pages = _.range(index - hRange, index + hRange + 1);
    }

    var pagesToLoad = this.getNeededPages(pages);

    if (pagesToLoad.length > 0){
      this.loadPages(index, pagesToLoad);
    }
    else {
      this.set("currentPage", index);
    } 
  },

  //Get pages which are not on the collection by an array of numbers
  getNeededPages: function(pages){
    return _.filter(pages, function(page){
      var found = this.get("documentPages").where({ "num": page });
      return found.length === 0;
    }, this);
  },

  loadPages: function(index, pages){

    var self = this;

    this.get("documentPages").fetch({
      xPages: pages,
      remove: false
    }).done(function(){
      self.get("documentPages").sort().trigger("reset");
      self.set("currentPage", "index");
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