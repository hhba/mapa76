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
      dataType: "multipart/form-data",
      paramName: "document[files][]",
      formAcceptCharset: "utf-8",
      singleFileUploads: false,

      add: function (e, data) {
        data.submit();
      },

      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $('#progress .bar').css('width', progress + '%');
      },

      done: function (e, data) {
        $.each(data.result.files, function (index, file) {
          $('<p/>').text(file.name).appendTo(window.document.body);
        });

        self.close();
      }
    });

  }

});