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

  search: function(query, id){
    var ids = this.getSelectedIds();
    var headers = {};
    
    if (ids.length > 0){
      headers[aeolus.headers.xDocumentIds] = ids.join(",");
    }

    $.ajax({
      url: this._buildSearchURL(id),
      data: $.param({ q: query }),
      headers: headers,
      context: this
    }).done(function(foundDocs){
      this.isSearch = true;

      if (foundDocs && foundDocs.length > 0 ){
        this.reset(foundDocs, { parse: true });
      }
      else {
        this.reset();
      }

      this.trigger("searching");
    });
  },

  clearSearch: function(){
    this.fetch({ reset: true });
    this.isSearch = false;
    this.trigger("clearSearch");
  },

  _buildSearchURL: function(id){
    if(typeof id === "undefined"){
      return this.url() + "/search";
    } else {
      return this.url() + "/" + id + "/search";
    }
  }

});