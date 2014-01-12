/**
 * VIEW: ExportDocuments
 * Toolbar section for exporting by class the selected documents
 */

var 
  template = require('./templates/exportDocuments.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    classes: "input[type=radio]",
    exportLink: "#do-export"
  },

  templateHelpers: function(){
    return {
      uploadURL: aeolus.rootURL + "/documents",
      token: aeolus.authKey
    };
  },

  modelEvents: {
    "change:counter": "render"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onDomRefresh: function(){
    this.ui.classes.iCheck({
        checkboxClass: 'icheckbox_flat-grey left',
        radioClass: 'iradio_flat-grey left',
        increaseArea: '20%'
      })
      .on('ifChecked', this.onCheck.bind(this))
      .first().iCheck("check");
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------
  
  onCheck: function(e){
    this.updateLinkURL($(e.currentTarget).val());
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  updateLinkURL: function(type){
    var 
      url = "/documents/export?"
      ids = [];

    if(typeof aeolus.app.project === 'undefined'){
      ids = [this.model.id];
    } else {
      ids = aeolus.app.project.get("documents").getSelectedIds();
    }

    url += "ids=" + ids.join(",");
    url += "&class=" + type;
    this.ui.exportLink.attr("href", url);
  }

});