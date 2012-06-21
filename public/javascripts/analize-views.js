var PersonView = Backbone.View.extend({
  el: $("#context"),
  className: "person",
  initialize: function(){
    _.bindAll();
    this.template = $("#personContext").html();
    this.model.on("change", this.render, this);
  },
  render: function(){
    this.html = Mustache.render(this.template, this.model.toJSON());
    this.$el.html(this.html);
    return this;
  }
});
var NamedEntityView = Backbone.View.extend({
  el: $("#context"),
  initialize: function(){
    this.template = $("#namedEntityTemplate").html()
  },
  render: function(){
    this.html = Mustache.render(this.template, this.model.to.JSON());
  }
});
var AnalyzerView = Backbone.View.extend({
  el: $("#sidebar"),
  initialize: function(){
    this.template = $("#combTemplate").html();
  }
});
var DocumentView = Backbone.View.extend({
  el: $("#context"),
  initialize: function(){
    this.template = $("#documentContextTemplate").html(),
    this.model.on('change', this.render, this)
  },
  render: function(){
    var html = Mustache.render(this.template, this.model.toJSON());
    this.$el.html(html);
    return this;
  }
});
var ParagraphView = Backbone.View.extend({
  events: {
    "click span": "selectNamedEntity"
  },
  className: "paragraph",
    /*paragraphTemplate: $("#paragraphTemplate").html(),*/
  initialize: function(){
    this.template = $("#paragraphTemplate").html();
    this.namedEntityTemplate = $("#namedEntityTemplate").html();
  },
  render: function(){
    var html = Mustache.render(this.template, this.namedEntitiesParse());
    this.$el.html(html);
    return this;
  },
  namedEntitiesParse: function(){
    var content = this.model.get("content");
    var nes = this.model.get("named_entities");
    for(var i=0; i < nes.length; i++){
      regExp = new RegExp("(" + nes[i].text + ")");
      content = content.replace(regExp, "<span class='ne " + nes[i].tag + "' data-ne-id='" + nes[i].id + "' data-type='" + nes[i].tag + "' data-person-id='" + nes[i].person_id +"'>" + "$1" + "</span>");
    }
    return {_id: this.model._id, content: content};
  },
  selectNamedEntity: function(e){
    var $ne = $(e.currentTarget);
    var ne_id = $ne.attr("data-ne-id");
    var ne_type = $ne.attr("data-type");
    var person_id = $ne.attr("data-person-id");

    switch(ne_type){
      case "people":
        if(person_id !== "null"){
          var person = new Person({id: person_id})
          var personView = new PersonView({model: person});
          person.fetch();
        }
        break;
      default:
        break;
    }
  }
});
var ParagraphListView = Backbone.View.extend({
  el: ".paragraphs",
  className: "paragraphs",
  events: {
    "scroll": "scrolling"
  },
  scrolling: function(e){
    console.log(e);
  },
  render: function(){
    this.addAll();
    return this;
  },
  addOne: function(paragraph){
    var paragraphView = new ParagraphView({model: paragraph});
    this.$el.append(paragraphView.render().el);
  },
  addAll: function(){
    this.collection.forEach(this.addOne, this);
    $(".paragraph .ne").draggable({ helper: "clone" });
  },
  initialize: function(){
    this.collection.on("add", this.addOne, this);
    this.collection.on("reset", this.addAll, this);
  }
});
var RegisterView = Backbone.View.extend({
  el: "#register",
  events:{},
  render: function(){
    return this;
  },
  getValues: function(){
    var output = {};
    _.each(this.$el.find(".register"), function(span_ne){
      var $span = $(span_ne);
      var group = $span.parent().attr("data-klass");
      var value = $span.attr("data-ne-id");
      if(_.isArray(output[group])){
        var tmp = output[group];
        tmp.push(value);
        output[group] = tmp;
      } else {
        output[group] = [value];
      }
    });
    output['document_id'] = AnalizeApp.document.get("id");
    output['what'] = $("#whatSelector").val();
    return output;
  },
  resetRegister: function(){
    $(".new_register").find(".register").remove();
    return this;
  }
});

