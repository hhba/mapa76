/**
 * VIEW: Toolbar
 * 
 */

var 
    template = require("./templates/toolbar.tpl")
  , DocumentNew = require("./Project/DocumentNew")
  , ExportDocuments = require("./Project/ExportDocuments");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  className: "nav-bar-submenu",

  ui: {
    multiOptions: ".multi",
    searchBox: "#search",
    clearSearch: ".clear-search"
  },

  events: {
    "keyup #search": "onSearchKeyup",
    "click .clear-search": "clearSearch",

    "click #upload": "toggleNewDocument",
    "click #export": "toggleExport",
    "click #delete": "removeDocuments"
  },

  modelEvents: {
    "change:counter": "updateCounter"
  },

  newDocVisible: false,
  exportDocsVisible: false,

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  initialize: function(options){
    this.documentView = options.documentView;
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
    this.ui.clearSearch.hide();
    this.model.get('documents').clearSearch();
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
      this.ui.clearSearch.show();
      this.model.get('documents').search(query);
    }
  }

});