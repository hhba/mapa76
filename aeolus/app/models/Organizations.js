
var Organization = require("./Organization");

module.exports = Backbone.Collection.extend({

  model: Organization,

  url: function(){
    return aeolus.rootURL + "/organizations"; 
  }

});