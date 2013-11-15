/**
 * VIEW: Toolbar
 * 
 */

var 
    template = require("./templates/layout.tpl")
  , Header = require("./Header")
  , types = {
        people: require("../People")
      //, organizations: require("../Organizations")
      //, places: require("../Places")
      //, dates: require("../Dates")
    };

module.exports = Backbone.Marionette.Layout.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    modal: ".menu-modal"
  },

  regions: {
    "header": ".menu-modal .header",
    "content": ".menu-modal .content"
  },

  modelEvents: {
    "change:counter": "render"
  },

  events: {
    "click ul li": "menuClicked",
    "click .close": "closeModal"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  menuClicked: function(e){
    var item = $(e.target).attr("data-menu");

    if (item && types.hasOwnProperty(item)){
      this.ui.modal.show();

      var header = new Header({
        type: item
      });

      var content = new types[item]({
        collection: this.model.getListByTypes(item)
      });

      this.header.show(header);
      this.content.show(content);

      header.on("filter", function(keyword){
         $("li", content.$el)
          .show()
          .not(":icontains(" + keyword + ")")
          .hide();
      });
    }
  },

  closeModal: function(){
    this.ui.modal.hide();
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});