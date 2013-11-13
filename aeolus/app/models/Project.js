
/*
 * A Group of Documents
 */

var Documents = require("./Documents");

module.exports = Backbone.Model.extend({

  initialize: function(){
    var documents = new Documents();
    this.set("documents", documents);
    documents.fetch({ reset: true });
  }

});