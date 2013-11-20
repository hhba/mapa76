var Document = require("./Document");

module.exports = Backbone.Collection.extend({

  model: Document,

  url: function(){
    return aeolus.rootURL + "/documents"; 
  },

  changeSort: function(prop, order){
    order = order === "asc" ? -1 : 1;

    this.comparator = function(docA, docB){
      if (docA.get(prop) > docB.get(prop)) { return -order; }
      if (docB.get(prop) > docA.get(prop)) { return order; }
      return 0;
    }; 

    this.sort().trigger("reset");
  },

  toggleSelect: function(selected){
    this.each(function(doc){
      doc.set("selected", selected); 
    });

    this.trigger("reset");
  },

  getStatus: function(){
    $.ajax({
      url: this.url() + "/status",
      cache: false,
      context: this
    }).done(function(docs){
      this.set(docs, { remove: false });
      this.trigger("reset");
    });
  },

  getSelectedIds: function(){
    var selecteds = this.where({ selected: true });

    return selecteds.map(function(doc){
      return doc.get("id");
    });

  },

  destroySelecteds: function(){
    var ids = this.getSelectedIds();
    
    var headers = {};
    headers[aeolus.headers.xDocumentIds] = ids.join(",");

    $.ajax({
      url: this.url(),
      type: "DELETE",
      headers: headers,
      context: this
    }).done(function(){

      var toRemove = [];
      
      _.each(ids, function(id){
        toRemove.push(this.get(id));
      }, this);

      this.remove(toRemove);
    });
  },

  search: function(query){
    var ids = this.getSelectedIds();
    var headers = {};
    
    if (ids.length > 0){
      headers[aeolus.headers.xDocumentIds] = ids.join(",");
    }

    $.ajax({
      url: this.url() + "/search",
      data: $.param({ q: query }),
      headers: headers,
      context: this
    }).done(function(foundDocs){
      this.reset(foundDocs, { parse: true });
    });
  },

  clearSearch: function(){
    this.fetch({ reset: true });
  }

});