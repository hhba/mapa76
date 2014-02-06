
var 
    People = require("./People")
  , Organizations = require("./Organizations")
  , Places = require("./Places")
  , Dates = require("./Dates")
  , DocumentPages = require("./DocumentPages")
  , Documents = require("./Documents");

module.exports = Backbone.Model.extend({
  
  defaults: {
    selected: {
      people: true,
      organizations: true,
      places: true,
      dates: true
    },
    currentPage: 1
  },

  urlRoot: function(){
    return aeolus.rootURL + "/documents"; 
  },

  parse: function(response){
    response.counter = response.counters;
    
    response.documentPages = new DocumentPages([], {
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
      pages = _.range(index - hRange, index + hRange);
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
      if (page === 0){
        return false;
      }

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
      self.set("currentPage", index);
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
  },

  search: function(query, done){ 

    //creates a Collection of Documents with this doc as an item
    var docs = new Documents([{
      id: this.get("id"),
      selected: true
    }]);

    docs.on("add", function(doc){
      done(doc);
    });

    /* FOR TEST */
    var Document = require("./Document");
    var doc = new Document({
        "id":"524d6cb3d8eba363ff000013",
        "title":"Alderete, Julia (2010.12.09).doc",
        "counters":{"people":0,"organizations":14,"places":16,"dates":2},
        "highlight":{"3":[" haya estado presente en ese lugar?\n<em>Alderete</em>: No, la verdad es que no sé."],"1":["TESTIMONIO DE <em>ALDERETE</em> JULIA FRANCISCA (A)\nO: Sra. ¿me puede decir su nombre completo, por favor","?\nA: <em>Alderete</em>, Julia Francisca.\nO: Aclaraciones, advertencias y penalidades. ¿presta juramento o"," padre y de su madre.\nA: Mi papá,  Bartolomé <em>Alderete</em>  y mi mamá, Petrona Isabel Alvarenga.\nO: ¿Cuál es"," días, Julia <em>Alderete</em>. Mencionó que era enfermera jubilada.\n¿Desde cuándo trabajaba como enfermera y"],"title":["<em>Alderete</em>, Julia (2010.12.09).doc"]}
      }, { parse: true });

    done(doc);
    /* END TEST */

    // call search for the collection getting the same result 
    // as Project view but for only this doc.
    docs.search(query);
  },

  clearSearch: function(){
    this.isSearch = false;
    this.trigger("clearSearch");
  }

});