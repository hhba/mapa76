var DocumentPage = require("./DocumentPage");

module.exports = Backbone.Collection.extend({

  model: DocumentPage,

  url: function(){
    return aeolus.rootURL + "/documents/" + this.id + "/pages"; 
  },

  comparator: function(page){
    return page.get("num");
  },

  initialize: function(models, options){
    this.id = options.id;
  }

});