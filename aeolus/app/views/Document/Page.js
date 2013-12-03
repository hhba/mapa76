
/**
 * VIEW: Document Page
 * 
 */

var 
  template = require('./templates/page.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  templateHelpers: {
    formatted_text: function(){
      var formatted_text = this.text || "";
      var entities = this.named_entities;

      if (formatted_text && entities){
        var template = Handlebars.compile('<a class="{{ne_class}}" data-eid="{{id}}">{{text}}</a>');
        
        for (var i=entities.length; i--;){
          var ent = entities[i];

          var p = ent.pos+1;

          var begin = formatted_text.substr(0, p);
          var tail = formatted_text.substr(p + ent.text.length);

          formatted_text = begin + template(ent) + tail;
        }
      }

      return formatted_text;
    }
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  initialize: function(){
    window.aeolus.app.document
      .on("change:selected", this.updateVisibleEntities.bind(this));
  },

  onDomRefresh: function(){
    this.updateVisibleEntities();
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  updateVisibleEntities: function(){
    var selected = window.aeolus.app.document.get("selected");

    function toggleLinks(visible, name){
      if (visible) {
        $("a." + name, this.$el).removeClass("hide");
      }
      else {
        $("a." + name, this.$el).addClass("hide");
      }
    }

    _.each(selected, toggleLinks);
  }

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------


});