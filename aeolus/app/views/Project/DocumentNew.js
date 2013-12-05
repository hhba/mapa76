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
    inputFile: "#file-upload",
    inputFileCtn: ".file-upload-container",
    progressCtn: "#progress",
    progressBar: "#progress .bar",
    progressMsg: "#progress .result"
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
        self.ui.inputFileCtn.hide();
        data.submit()
          .done(self.onUploadDone.bind(self))
          .fail(self.onUploadError.bind(self));
      },

      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        self.ui.progressCtn.show().addClass("info");
        self.ui.progressBar.css('width', progress + '%');
        self.ui.progressMsg.text("Subiendo Archivos, un momento por favor.");
      }
    });

  },

  onUploadDone: function(docs){
    this.resetUpload();

    aeolus.app.project.get("documents").add(docs);
    this.close();
  },

  onUploadError: function(/*jqXHR, textStatus, errorThrown*/){
    this.ui.progressCtn.removeClass("info").addClass("error");
    
    var aReset = $('<a class="important">Vuelva a intentarlo</a>');

    this.ui.progressMsg
      .text("Error al subir documento.")
      .append(aReset);

    aReset.on("click", this.resetUpload.bind(this));
  },

  resetUpload: function(){
    this.ui.inputFileCtn.show();
    this.ui.progressCtn.hide().removeClass("info").removeClass("error");
    this.ui.progressBar.css('width', '0%');
    this.ui.progressMsg.empty();
  }

});