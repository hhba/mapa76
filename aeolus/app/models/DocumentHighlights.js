
var DocumentHighlight = require("./DocumentHighlight");

module.exports = Backbone.Collection.extend({

  model: DocumentHighlight,

  parse: function(response){
    var translated = [];

    _.each(response, function(value, key){
      
      translated.push({
        page: parseInt(key, 10),
        lines: value
      });
    });

    return translated;
  }

});