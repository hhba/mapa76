
var MentionedEntity = require("./MentionedEntity");

module.exports = MentionedEntity.extend({

  urlRoot: function(){
    return aeolus.rootURL + "/date_entities"; 
  }

});