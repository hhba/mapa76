
var Mentions = require("./Mentions");

module.exports = Backbone.Model.extend({

  defaults: {
    mentions: 0
  },

  parse: function(response){
    if (response.hasOwnProperty("mentioned_in")){
      response.mentioned_in = new Mentions(response.mentioned_in);
    }

    return response;
  }

});