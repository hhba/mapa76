/**
 * Aeolus Application
 *
 */

var 
  Project = require("./models/Project"),
  DocumentFull = require("./models/DocumentFull"),
  AeolusRouter = require("./AeolusRouter"),

  Toolbar = require("./views/Toolbar"),
  Menu = require("./views/Menu"),

  DocumentList = require("./views/Project"),
  DocumentLayout = require("./views/Document");

module.exports = function(type){

  var app = module.exports = new Backbone.Marionette.Application();

  app.addRegions({
    toolbar: ".toolbar",
    content: ".box-content",
    menu: ".vertical-toolbar",
    modals: "#modal-container",
    modalMentions: "#mentions-modal-container"
  });

  function initializeProject() {
    
    app.project = new Project();

    app.toolbar.show(new Toolbar({
      model: app.project
    }));

    app.content.show(new DocumentList({
      collection: app.project.get('documents')
    }));

    app.menu.show(new Menu({
      model: app.project,
      collection: app.project.get('documents')
    }));
  }

  function initializeDocument() {

    app.document = new DocumentFull({
      id: $("body").attr("data-document-id")
    });

    app.toolbar.show(new Toolbar({
      model: app.document,
      documentView: true
    }));

    app.menu.show(new Menu({
      model: app.document,
      documentView: true
    }));

    app.router = new AeolusRouter({
      document: app.document
    });

    app.document.fetch({
      parse: true,
      wait: true
    }).done(function(){

      app.content.show(new DocumentLayout({
        model: app.document
      }));

      Backbone.history.start();
    });
  }

  // Creates Spinner for Loadings
  app.spinner = new window.Spinner(window.aeolus.spinnerOptions);

  switch(type){
    case "project": 
      app.addInitializer(initializeProject);
      break;
    case "document":
      app.addInitializer(initializeDocument);
      break;
  }

  window.aeolus.app = app;
  window.aeolus.app.start();

  // hack to hide all menus 
  $(window.document).on("click", function() {
    $('.wrapper-dropdown').removeClass('active');
  });
};
