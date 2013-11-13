/**
 * Aeolus Application
 *
 */

var 
  Project = require("./models/Project"),
  ProjectLayout = require("./views/Project");

var app = module.exports = new Backbone.Marionette.Application();

app.addInitializer( function () {

  app.addRegions({
    appContainer: "#app-container"
  });

  app.project = new Project();

  app.appContainer.show(new ProjectLayout({
    model: app.project
  }));
});
