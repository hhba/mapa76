
var Person = require("./Person");

module.exports = Backbone.Collection.extend({

  model: Person,

  url: function(){
    return aeolus.rootURL + "/people"; 
  },

});