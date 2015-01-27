
/*
 * A Group of Documents
 */

var
    Documents = require("./Documents")
  , People = require("./People")
  , Organizations = require("./Organizations")
  , Places = require("./Places")
  , Dates = require("./Dates");

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
      .on("reset add remove change:selected", this.updateCounter.bind(this))
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
        counter[p] += doc.get("counters")[p];
      });
    });

    counter.online = this.get("documents").length;

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
        if (!self.get("documents").isSearch){
          self.get("documents").getStatus();
        }
        self.checkStatus();
      }, aeolus.poolingStatusTime);
    }
  },

  getListByTypes: function(type){
    var docIds = this.get("documents").getSelectedIds();

    if (this.menuCollection &&
      this.lastType === type &&
      this.lastDocIds === docIds.join(",")){

      return this.menuCollection;
    }

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

    collection.fetch({
      reset: true,
      xDocumentIds: docIds
    });

    this.menuCollection = collection;
    this.lastType = type;
    this.lastDocIds = docIds.join(",");

    return collection;
  }

});
