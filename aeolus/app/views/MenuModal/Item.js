/**
 * VIEW: A Item for menu modal collection
 * Must Inherit and implement the template
 */

var 
    Mentions = require("./Mentions");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  
  ui: {
    viewMoreLink: ".view-more"
  },

  events: {
    "click .view-more": "showMentions"
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

  showMentions: function(){
    if (this.model.get("mentions") > 0){
      
      var mentions = new Mentions({
        model: this.model,
        collection: this.model.get("mentioned_in")
      });

      window.aeolus.app.modalMentions.show(mentions);

      var pos = this.ui.viewMoreLink.offset();
      var pad = (this.$el.outerHeight() - this.$el.height() )/2;

      mentions.$el.css({
        top: pos.top + pad,
        right: 73
      });
    }
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------



});