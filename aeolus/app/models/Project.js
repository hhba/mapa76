
/*
 * A Group of Documents
 */

var Documents = require("./Documents");

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
    
    documents.on("change:selected remove", this.updateCounter.bind(this));

    documents.fetch({ reset: true });
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
  }

});