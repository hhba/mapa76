/**
 * VIEW: Toolbar
 * 
 */

var 
    template = require("./templates/toolbar.tpl")
  , DocumentNew = require("./DocumentNew")
  /*, DocumentSearch = require("../../models/DocumentSearch")*/;

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    multiOptions: ".multi",
    subMenu: ".sub-menu",
    searchBox: "#search"
  },

  events: {
    "click #upload": "showNewDocument",
    "click #delete": "removeDocuments"
  },

  modelEvents: {
    "change:counter": "render"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onDomRefresh: function(){
    if (this.model.get("counter").selected > 0){
      this.ui.multiOptions.show();
    }
    else {
      this.ui.multiOptions.hide(); 
    }

    this.initAutocomplete();
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  removeDocuments: function(){
    this.model.get('documents').destroySelecteds();
  },

  showNewDocument: function(){
    var newDocForm = new DocumentNew();
    newDocForm.render();
    this.ui.subMenu.empty().append(newDocForm.$el);
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  initAutocomplete: function(){
    //more info at https://github.com/devbridge/jQuery-Autocomplete
    //style: https://github.com/devbridge/jQuery-Autocomplete#styling
    this.ui.searchBox.autocomplete({

      serviceUrl: aeolus.rootURL + "/documents/search",
      paramName: "q",
      minChars: 3,
      deferRequestBy: 300,

      transformResult: function(response) {
        var trans = _.map(JSON.parse(response), function(doc) {
          return { value: doc.title, data: doc.id };
        });

        return {
          suggestions: trans
        };
      },

      onSelect: function (doc) {
        console.log('search doc selected: ' + doc.value + ', ' + doc.data);
      }
    });

  }

});