
var DateModel = require("./Date");

module.exports = Backbone.Collection.extend({

  model: DateModel,

  url: function(){
    return aeolus.rootURL + "/dates"; 
  }

});