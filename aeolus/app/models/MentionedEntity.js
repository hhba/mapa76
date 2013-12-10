
/*
 * Base class for entities which has mentions
 * It manages the common parser for its mentions.
 */

var Mentions = require("./Mentions");

module.exports = Backbone.Model.extend({

  defaults: {
    mentions: 0
  },

  parse: function(response, options){
    var mentioned_in = response.mentions,
      docIds = (options && options.xDocumentIds) || [], 
      mentions = 0;

    _.each(response.mentions, function(mention){
      if (docIds.indexOf(mention.id) >= 0){
        mentions += mention.mentions;
      }
    });

    response.mentioned_in = new Mentions(mentioned_in);
    response.mentions = mentions;

    return response;
  }

});