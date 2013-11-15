
var Person = require("./Person");

module.exports = Backbone.Collection.extend({

  model: Person,

  url: function(){
    return aeolus.rootURL + "/people"; 
  },

  initialize: function(options){
    this.docs = options.docs;
  },

  fetch: function(options) {
    if (!options.headers) {
      options.headers = {};
    }
    
    options.headers['X-IDS'] = this.docs.join(",");
    return Backbone.Collection.prototype.fetch.call(this, options);
  }

});