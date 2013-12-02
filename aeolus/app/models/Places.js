
var Place = require("./Place");

module.exports = Backbone.Collection.extend({

  model: Place,

  url: function(){
    return aeolus.rootURL + "/places"; 
  }

});