var 
    template = require("./templates/layout.tpl")
  , DocumentInfo = require("./DocumentInfo")
  , DocumentHighlight = require("../Project/DocumentHighlight")
  , DocumentHighlights = require("../Project/DocumentHighlights");

module.exports = Backbone.Marionette.Layout.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  tagName: "div",
  className: "results",
  itemView: DocumentHighlight,

  regions: {
    "documentInfo": ".header .documentInfo",
    "content": ".content-wrapper-doc"
  },

  templateHelpers: function(){
    var $projectData = $('body').data(),
        documentUrl;

    if ($projectData.editable){
      documentUrl = $projectData.documentId;
    } else {
      documentUrl = 'comb?document_id=' + $projectData.documentId;
    }

    return {
      searching: true,
      loggedIn: $projectData.editable,
      documentUrl: documentUrl
    };
  },

  onRender: function(){
    this.documentInfo.show(new DocumentInfo({
      model: this.model
    }));
    this.content.show(new DocumentHighlights({
      model: this.model,
      collection: this.collection
    }));
  }
});
