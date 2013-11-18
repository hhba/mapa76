var Document = require("./Document");

module.exports = Backbone.Collection.extend({

  model: Document,

  url: function(){
    return aeolus.rootURL + "/documents"; 
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

      this.each(function(doc){
        doc.unset("percentage");
      });

      this.set(docs);
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
  }

});