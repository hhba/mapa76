/**
 * VIEW: Toolbar
 * 
 */

var 
    template = require("./templates/layout.tpl")
  , Header = require("./Header")
  , types = {
        people: require("../MenuModal/People")
      , organizations: require("../MenuModal/Organizations")
      , places: require("../MenuModal/Places")
      , dates: require("../MenuModal/Dates")
    };

module.exports = Backbone.Marionette.Layout.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  ui: {
    modal: ".menu-modal",
    links: ".group-b a"
  },

  regions: {
    "header": ".menu-modal .header",
    "content": ".menu-modal .content"
  },

  modelEvents: {
    "change:counter": "render"
  },

  events: {
    "click .group-b a": "menuClicked",
    "click .close": "closeModal"
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  initialize: function(options){
    this.documentView = options.documentView;
  },

  serializeData: function(){  
    return _.extend({
      showDocumentStats: this.documentView ? false : true
    }, ((this.model && this.model.toJSON()) || {}));
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  menuClicked: function(e){
    var link = $(e.target).parents("a"),
      item = link.attr("data-menu");

    if (item && types.hasOwnProperty(item)){
      this.ui.links.removeClass("active");
      link.addClass("active");

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
    this.ui.links.removeClass("active");
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});