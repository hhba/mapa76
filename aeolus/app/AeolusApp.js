/**
 * Aeolus Application
 *
 */

var Documents = require('./views/Documents');

var app = module.exports = new Backbone.Marionette.Application();

app.addInitializer( function () {

  app.addRegions({
    appContainer: "#app-container"
  });

  app.appContainer.show(new Documents());
});
