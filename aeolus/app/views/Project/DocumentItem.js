/**
 * VIEW: Document Item List
 *
 */

var
    template = require('./templates/documentItem.tpl')
  , DocumentHighlights = require("./DocumentHighlights");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  className: "item-list clearfix",
  template: template,

  templateHelpers: function(){
    var $projectData = $('body').data(),
      baseUrl = aeolus.baseRoot + "/documents/" + this.model.get("id"),
      previewUrl = baseUrl,
      p = this.model.get("percentage"),
      show = (p !== 100),
      type = (p === -1) ? "error" : "info",
      msg = this.model.get("status_msg") || "Cargando...",
      downloadable = this.model.get('url') === null,
      showSpinner = (p >= 0);

    if(!$projectData.editable){
      previewUrl = $projectData.slug + "/comb?document_id=" + this.model.get("id");
    }

    return {
      downloadable: downloadable,
      urls: {
        preview: previewUrl,
        file: baseUrl + "/download",
        export: baseUrl + "/export"
      },
      showSpinner: showSpinner,
      status_msg: msg,
      showProgress: show,
      progressType: type,
      showFlag: ((type === "error") ? true : false) && $projectData.editable,
      deleteable: $projectData.editable,
      showErrorMessage: ((type === "error") ? true : false)
    };
  },

  ui: {
    selection: ".selection",
    highlights: ".highlights"
  },

  events: {
    "click .delete": "deleteDocument",
    "click .flag": "flagDocument",
    "change .selection": 'checkboxClicked'
  },

  modelEvents: {
    "change:selection": "render",
    "change:percentage": "render",
    "change:status_msg": "render"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    var sums = this.model.get("highlights");

    if (sums && sums.length > 0){
      var highlights = new DocumentHighlights({
        model: this.model,
        collection: sums
      });

      highlights.render();

      this.ui.highlights.empty().append(highlights.$el);
    }
  },

  checkboxClicked: function() {
    if (this.ui.selection.is(':checked')) {
      this.onCheck();
    } else {
      this.onUncheck();
    }
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  deleteDocument: function(){
    if(window.confirm("Se eliminará el documento " + this.model.get("title") + ". ¿Está seguro?")){
      this.model.destroy();
    }
  },

  flagDocument: function(){
    this.model.flag();
  },

  onCheck: function(){
    this.toggleSelectDocument(true);
  },

  onUncheck: function(){
    this.toggleSelectDocument(false);
  },

  toggleSelectDocument: function(checked){
    this.model.set("selected", checked);
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});
