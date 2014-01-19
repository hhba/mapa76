/**
 * VIEW: Document Page
 * 
 */

var 
  template = require('./templates/page.tpl'),
  Person = require("../../models/Person"),
  DateEntity = require("../../models/Date"),
  Organization = require("../../models/Organization"),
  Place = require("../../models/Place"),
  Mentions = require("../MenuModal/Mentions");

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "li",
  className: "doc",
  template: template,

  events: {
    "click span.people": "clickPerson",
    "click span.organizations": "clickOrganization",
    "click span.dates": "clickDate",
    "click span.places": "clickPlace",
    "click span.addresses": "clickPlace"
  },

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
        var template = Handlebars.compile('<span class="{{ne_class}}" data-eid="{{entity_id}}">{{text}}</span>');
        
        for (var i=entities.length; i--;){
          var ent = entities[i];

          var p = ent.pos;

          var begin = formatted_text.substr(0, p - from_pos);
          var tail = formatted_text.substr(p - from_pos + ent.text.length);

          ent.text = ent.text.replace(/_/gi, " ");

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
  },

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  clickPerson: function(e){
    var ele = $(e.currentTarget);
    var entity = new Person({
      id: ele.attr("data-eid")
    });

    entity.fetch().done(this.showMentions.bind(this, entity, ele));
    e.stopPropagation();
  },

  clickOrganization: function(e){
    var ele = $(e.currentTarget);
    var entity = new Organization({
      id: ele.attr("data-eid")
    });

    entity.fetch().done(this.showMentions.bind(this, entity, ele));
    e.stopPropagation();
  },

  clickDate: function(e){
    var ele = $(e.currentTarget);
    var entity = new DateEntity({
      id: ele.attr("data-eid")
    });

    entity.fetch().done(this.showMentions.bind(this, entity, ele));
    e.stopPropagation();
  },

  clickPlace: function(e){
    var ele = $(e.currentTarget);
    var entity = new Place({
      id: ele.attr("data-eid")
    });

    entity.fetch().done(this.showMentions.bind(this, entity, ele));
    e.stopPropagation();
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  showMentions: function(entity, ele){
    var mentions = new Mentions({
      hideClose: true,
      newClassNames: "view-more-doc view-more-list left-position",
      model: entity,
      collection: entity.get("mentioned_in")
    });

    window.aeolus.app.modalMentions.show(mentions);

    var pos = ele.offset();

    mentions.$el.css({
      top: pos.top + 25,
      left: pos.left
    });
  }

});