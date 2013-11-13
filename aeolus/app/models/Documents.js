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
  }

});