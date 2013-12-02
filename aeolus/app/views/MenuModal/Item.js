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
    mentions: ".mentions-ctn"
  },

  events: {
    "click .mentions": "showMentions"
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

      mentions.render();

      this.ui.mentions.empty().append(mentions.$el).show();
    }
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------



});