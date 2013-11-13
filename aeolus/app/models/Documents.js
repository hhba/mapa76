var Document = require("./Document");

module.exports = Backbone.Collection.extend({

  model: Document,

  url: function(){
    return aeolus.rootURL + "/documents"; 
  }

});