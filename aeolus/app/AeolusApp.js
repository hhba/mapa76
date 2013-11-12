/**
 * Aeolus Application
 *
 */

var Documents = require('./models/Documents');
var DocumentsListView = require('./views/Documents');

var app = module.exports = new Backbone.Marionette.Application();

app.addInitializer( function () {

  app.addRegions({
    appContainer: "#app-container"
  });

  var docs = new Documents();

  app.appContainer.show(new DocumentsListView({
    collection: docs
  }));

  docs.fetch({
    reset: true
  });

});
