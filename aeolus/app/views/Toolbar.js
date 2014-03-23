/**
 * VIEW: Toolbar
 * 
 */

var 
    template = require("./templates/toolbar.tpl")
  , DocumentNew = require("./Project/DocumentNew")
  , ExportDocuments = require("./Project/ExportDocuments")
  , DocumentLayout = require("./Document")
  , Results = require("./Document/Results");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  className: "nav-bar-submenu",

  ui: {
    multiOptions: ".multi",
    searchBox: "#search",
  },

  events: {
    "keyup #search": "onSearchKeyup",
    "click #upload": "toggleNewDocument",
    "click #export": "toggleExport",
    "click #delete": "removeDocuments",
    "click #seachButton": "searchDocuments"
  },

  modelEvents: {
    "change:counter": "updateCounter"
  },

  templateHelpers: function(){
    return {
      canUploadDocument: this.model.get('singleDocument') && this.model.get('editable'),
      canDeleteDocuments: this.model.get('editable')
    };
  },

  newDocVisible: false,
  exportDocsVisible: false,

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  initialize: function(options){
    this.documentView = options.documentView;

    if (this.documentView){
      this.model.on("clearSearch", this.clearSearch.bind(this));
    }
    else {
      this.model.get('documents').on("clearSearch", this.clearSearch.bind(this));
    }
  },

  onDomRefresh: function(){
    this.updateCounter();
  },

  serializeData: function(){  
    return _.extend({
      singleDocument: this.documentView ? true : false
    }, ((this.model && this.model.toJSON()) || {}));
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  removeDocuments: function(){
    if(window.confirm("Se eliminarán todos los documentos seleccionados, está seguro?")){
      this.model.get('documents').destroySelecteds();
    }
  },

  toggleNewDocument: function(){
    if (!this.newDocVisible){
      var upload = new DocumentNew();
      window.aeolus.app.modals.show(upload);

      var self = this;
      upload.on("close", function(){
        self.newDocVisible = false;
      });
    }
    else {
      window.aeolus.app.modals.close(); 
    }
    
    this.newDocVisible = !this.newDocVisible;
  },

  toggleExport: function(){
    if (!this.exportDocsVisible){
      var exportDocs = new ExportDocuments({
        model: this.model
      });
      
      window.aeolus.app.modals.show(exportDocs);

      var self = this;
      exportDocs.on("close", function(){
        self.exportDocsVisible = false;
      });
    }
    else {
      window.aeolus.app.modals.close(); 
    }
    
    this.exportDocsVisible = !this.exportDocsVisible;
  },

  onSearchKeyup: function(e){
    var key = e.keyCode || e.which;
    if (key === 13){
      this.searchDocuments();
    }
  },

  clearSearch: function(){
    this.ui.searchBox.val("");

    if (this.documentView){
      window.aeolus.app.content.show(new DocumentLayout({
        model: window.aeolus.app.document
      }));
    }
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  updateCounter: function(){
    if (this.documentView){
      return;
    }
    
    if (this.model.get("counter").selected > 0){
      this.ui.multiOptions.show();
    }
    else {
      this.ui.multiOptions.hide(); 
    }
  },

  searchDocuments: function(){
    var query = this.ui.searchBox.val();

    if (query){
      if (this.documentView){
        this.model.search(query, function(doc){
          window.aeolus.app.content.show(new Results({
            model: doc,
            collection: doc.get("highlights")
          }));
        });
      } else {
        this.model.get('documents').search(query);
      }
    }
  }
});