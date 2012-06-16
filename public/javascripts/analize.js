var Document = Backbone.Model.extend({
  urlRoot: '/api/documents/'
});
var Person = Backbone.Model.extend({
  urlRoot: "/api/people/"
});
var Paragraph = Backbone.Model.extend({});
var Register = Backbone.Model.extend({
  urlRoot: "/api/registers/",
  loadValues: function(info) {
    var that = this;
    _.each(info, function(value, key){
      that.set(key, value, {silent: true});
    });
    return that;
  },
  validate: function(attribs){
    console.log(attribs);
    if(attribs.who.length === 0) {
      return "There must be a who";
    } else if (attribs.when.length === 0) {
      return "There must be a when";
    } else if (attribs.where.length === 0) {
      return "There must be a where";
    } else if (attribs.what === null) {
      return "There must be a what";
    }
  },
  defaults: {
    who    : [],
    where  : [],
    when   : [],
    to_who : [],
    what   : []
  }
});
var ParagraphList = Backbone.Collection.extend({
  model: Paragraph,
  url: function(){
    return '/api/documents/' + this.get("document_id");
  }
});
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
var analizer = {
  init: function(){
    this.getTemplates();
  },
  getTemplates: function(){
    this.paragraphTemplate = $('#paragraphTemplate').html();
    this.nextPageTemplate = $("#nextPageTemplate").html();
  },
  addParagraph: function(data){
    var url;
    var nextPageValues;
    var nextPage;
    $(".paragraphs").append(Mustache.render(analizer.paragraphTemplate, data));
    $("#loading").hide();
    if(!data.last_page){
      nextPage = parseInt(data.current_page, 10) + 1;
      url = "/documents/" + data.document_id + "/comb?page=" + nextPage;
      nextPageValues = { url: url, id: data.document_id, 'next_page': data.current_page + 1 };
      $(".next_page").html(Mustache.render(analizer.nextPageTemplate, nextPageValues));
      checkScroll();
    }
  }
};
function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 200;
}
function scrollDistanceFromBottom(argument) {
  return pageHeight() - (window.pageYOffset + self.innerHeight);
}
function pageHeight() {
  return Math.max(document.body.scrollHeight, document.body.offsetHeight);
}
function checkScroll() {
  if (nearBottomOfPage()) {
    callNextPage();
  } else {
    window.setTimeout("checkScroll", 250);
  }
}
function callNextPage(){
  var url = "/api/documents/" + $("#next_page").attr("data-document") + "?page=" + $("#next_page").attr("data-next");
  $("#loading").show();
  $("#next_page").remove();
  $.getJSON(url, analizer.addParagraph);
}
function Droppable(el){
  this.el = el;
  this.new_el = this.el.find(".new");
  this.new_el.droppable({
    drop: function(event, ui){
      var draggable = ui.draggable;
      var template = $("#preRegisterTemplate").html();
      var params = {text: draggable.text(), type: draggable.attr("data-type"), id: draggable.attr("data-ne-id")}
      $(this).before(Mustache.render(template, params));
      AnalizeApp.register = new Register(AnalizeApp.registerView.getValues());
    },
    accept: "." + this.el.attr("data-type")
  });
}
var AnalizeApp = new (Backbone.Router.extend({
  initialize: function(){
    var document_id = $("#document_heading").attr("data-document-id");

    this.document = new Document({id: document_id});
    this.documentView = new DocumentView({model: this.document});
    this.document.fetch();
    this.paragraphList = new ParagraphList();
    this.paragraphList.url = "/api/documents/" + document_id + "/";
    this.paragraphListView = new ParagraphListView({collection: this.paragraphList});
    this.paragraphList.fetch({data:{page:1}});
    this.register = new Register();
    this.registerView = new RegisterView({model: this.register});
  },
  saveRegister: function() {
    if (AnalizeApp.register.isValid()) {
      AnalizeApp.register.save();
      AnalizeApp.registerView.resetRegister();
      $("#register-save").alert().show().fadeOut(2000);
    } else {
      $("#register-error").alert().show().fadeOut(2000);
    }
  }
}));
$(document).ready(function(){
  analizer.getTemplates();
  window.droppable_klasses = ['who', 'when', 'where', 'to_who'];
  $("#next_page").live("click", function(){
    callNextPage();
    return false;
  });
  $("#reference input").click(function(){
    var $this = $(this);
    var klass = $this.parent().attr("class");
    $(".paragraphs ." + klass).toggle("nocolor");
  });
  droppeables = _.map(window.droppable_klasses, function(klass){
    return new Droppable($(".box." + klass));
  });
  $(".new_register button.close").live("click", function(){
    $(this).parent().remove();
  });
  $("button.clean").live("click", function(){
    AnalizeApp.registerView.resetRegister();
  });
  $("button.save").live("click", function(){
    AnalizeApp.saveRegister();
  });
});
