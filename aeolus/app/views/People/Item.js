/**
 * VIEW: A Person
 * 
 */

var 
    template = require("./templates/item.tpl")
  , Mentions = require("./Mentions");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  template: template,

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
      
      var self = this;

      this.model.fetch().done(function(){

        var mentions = new Mentions({
          model: self.model,
          collection: self.model.get("mentioned_in")
        });

        mentions.render();

        self.ui.mentions.empty().append(mentions.$el).show();
      });
    }
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------



});