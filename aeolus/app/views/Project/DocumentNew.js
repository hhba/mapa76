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
    uploadForm: "#new-document",
    inputFile: "#new-document input[type=file]",
    errorMessage: "#error-upload"
  },

  events:{
    "click #upload": "uploadDocument"
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
    var self = this;

    this.ui.uploadForm.ajaxForm(function(data, status/*, xhr*/) { 
      console.log(data);
      console.log(status);

      if (status.toLowerCase() === "success") {
        console.log("all good!");
      }
    });

    this.ui.uploadForm.ajaxError(function(event, request/*, settings*/){
      var err = JSON.parse(request.responseText);
      if (err && err.hasOwnProperty('error')){
        self.ui.errorMessage.show();
      }
    });
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------
  
  uploadDocument: function(){
    if (this.ui.inputFile.val()){
      this.ui.errorMessage.hide();
      this.ui.uploadForm.submit();
    }
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});