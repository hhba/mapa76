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
    var baseUrl = aeolus.baseRoot + "/documents/" + this.model.get("id"),
      p = this.model.get("percentage"),
      show = (p === -1 || (p >= 0 && p < 100)) ? true : false,
      type = (p === -1) ? "error" : "info",
      msg = (type === "error") ? "Error al analizar documento" : "Analizando documento";

    return {
      urls: {
        preview: baseUrl + "/",
        file: baseUrl + "/download",
        export: baseUrl + "/export"
      },
      showProgress: show,
      progressType: type,
      progressMessage: msg,
      showFlag: (type === "error") ? true : false
    };
  },

  ui: {
    selection: ".selection",
    highlights: ".highlights"
  },

  events: {
    "click .delete": "deleteDocument",
    "click .flag": "flagDocument"
  },

  modelEvents: {
    "change:selection": "render",
    "change:percentage": "render"
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

  onDomRefresh: function(){
    this.ui.selection.iCheck({
        checkboxClass: 'icheckbox_flat-grey left',
        radioClass: 'iradio_flat-grey left',
        increaseArea: '20%'
      })
      .on('ifChecked', this.onCheck.bind(this))
      .on('ifUnchecked', this.onUncheck.bind(this));
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  deleteDocument: function(){
    if(window.confirm("Se eliminará el documento " + this.model.get("title") + ", está seguro?")){
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