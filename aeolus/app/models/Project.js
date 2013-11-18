
/*
 * A Group of Documents
 */

var 
    Documents = require("./Documents")
  , People = require("./People");

module.exports = Backbone.Model.extend({

  defaults: {
    counter: {
      online: 0,
      selected: 0,
      people: 0,
      organizations: 0,
      places: 0,
      dates: 0
    }
  },

  initialize: function(){
    var documents = new Documents();
    this.set("documents", documents);
    
    documents
      .on("change:selected remove", this.updateCounter.bind(this))
      .fetch({ reset: true })
      .done(this.checkStatus.bind(this));
  },

  updateCounter: function(){
    this.resetCounter();

    var 
      counter = this.get("counter"),
      props = ["people", "organizations", "places", "dates"];

    var selecteds = this.get("documents").where({ selected: true });
    
    _.each(selecteds, function(doc){
      counter.selected++;

      _.each(props, function(p){
        counter[p] += doc.get(p);
      });
    });

    this
      .set("counter", counter)
      .trigger("change:counter");
  },

  resetCounter: function(){
    this.set("counter", {
      online: 0,
      selected: 0,
      people: 0,
      organizations: 0,
      places: 0,
      dates: 0
    });
  },

  checkStatus: function(){
    if (aeolus.poolingStatusTime){
      window.clearTimeout(this.timer);

      var self = this;
      
      this.timer = window.setTimeout(function(){
        self.get("documents").getStatus();
        self.checkStatus();
      }, aeolus.poolingStatusTime);
    }
  },

  getListByTypes: function(type){
    var collection;
      
    switch(type){
      case "people": 
        collection = new People(); 
        break;
    }

    collection.fetch({ 
      reset: true, 
      xDocumentIds: this.get("documents").getSelectedIds()
    });

    return collection;
  }

});