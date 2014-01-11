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

  tagName: "li",
  className: "doc",
  template: template,
  attributes: function(){
    return { 'data-num': this.model.get('num')};
  },

  id: function(){
    return 'page_' + this.model.get('num');
  },

  templateHelpers: {
    formatted_text: function(){
      var formatted_text = this.text || "";
      var from_pos = this.from_pos;
      var entities = this.named_entities;

      if (formatted_text && entities){
        var template = Handlebars.compile('<span class="{{ne_class}}" data-eid="{{id}}">{{text}}</span>');
        
        for (var i=entities.length; i--;){
          var ent = entities[i];

          var p = ent.pos;

          var begin = formatted_text.substr(0, p - from_pos);
          var tail = formatted_text.substr(p - from_pos + ent.text.length);

          formatted_text = begin + template(ent) + tail;
        }
      }

      return formatted_text.split("\n").join("</p><p>");
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
        $("span." + name, this.$el).removeClass("hide");
      }
      else {
        $("span." + name, this.$el).addClass("hide");
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