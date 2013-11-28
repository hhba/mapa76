/**
 * VIEW: DocumentNew
 * Toolbar section for uploading new documents
 */

var 
  template = require('./templates/documentNew.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    inputFile: "#file_upload"
  },

  modelEvents: {
    "change":"render"
  },

  templateHelpers: function(){
    return {
      uploadURL: aeolus.rootURL + "/documents",
      token: aeolus.authKey
    };
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    this.initUploader();
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------
  
  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  initUploader: function(){
    var self = this;

    this.ui.inputFile.fileupload({
      url: aeolus.rootURL + "/documents",
      paramName: "document[files][]",
      formAcceptCharset: "utf-8",
      singleFileUploads: false,

      add: function (e, data) {
        data.submit()
          .done(self.onUploadDone.bind(self))
          .fail(self.onUploadError.bind(self));
      },

      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $('#progress .bar').css('width', progress + '%');
      }
    });

  },

  onUploadDone: function(docs){
    aeolus.app.project.get("documents").add(docs);
    this.close();
  },

  onUploadError: function(jqXHR, textStatus, errorThrown){
    //TODO: send this error to view
    console.error("UPLOAD ERROR: " + textStatus + " - " + errorThrown);
    console.dir(jqXHR);
  }

});