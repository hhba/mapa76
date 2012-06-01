var Document = Backbone.Model.extend({
  urlRoot: '/api/documents/',
  initialize: function(){
    this.on("change", function(){
     
    });
  }
});
var Milestone = Backbone.Model.extend({
});
var Address = Backbone.Model.extend({
});
var Date = Backbone.Model.extend({
});
var Person = Backbone.Model.extend({
  urlRoot: "/api/people/",
  initialize: function(){
    this.on("reset", function(){
        alert("the name has changed");
    });
  }
});
var Paragraph = Backbone.Model.extend({});
var ParagraphList = Backbone.Collection.extend({
  model: Paragraph,
  url: function(){
    return '/api/documents/' + this.get("document_id");
  }
});
var AnalyzerView = Backbone.View.extend({
  el: $("#sidebar"),
  sidebarTemplate: $("#combTemplate").html(),
  events: {
  },
  initialize: function(){
  }
});
var DocumentContext = Backbone.View.extend({
  el: $("#context"),
  documentTemplate: $("#documentContextTemplate").html(),
  initialize: function(){
    this.model.on('change', this.render, this)
  },
  render: function(){
    var html = Mustache.render(this.documentTemplate, this.model.toJSON());
    this.$el.html(html);
    return this;
  }
});
var ParagraphView = Backbone.View.extend({
  events: {
    "click span": "selectNamedEntity" 
  },
  className: "paragraph",
  paragraphTemplate: $("#paragraphTemplate").html(),
  render: function(){
    var html = Mustache.render(this.paragraphTemplate, this.namedEntitiesParse());
    this.$el.html(html);
    return this;
  },
  namedEntitiesParse: function(){
    var content = this.model.get("content");
    var nes = this.model.get("named_entities");
    for(var i=0; i < nes.length; i++){
      regExp = new RegExp("(" + nes[i].text + ")");
      content = content.replace(regExp, "<span class='ne " + nes[i].tag + "'>" + "$1" + "</span>");
    }  
    return {_id: this.model._id, content: content};
  },
  selectNamedEntity: function(e){
    alert("named!");
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
  },
  initialize: function(){
    this.collection.on("add", this.addOne, this);
    this.collection.on("reset", this.addAll, this);
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
    console.log(data.last_page);
    if(!data.last_page){
      console.log("entro");
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
var AnalizeApp = new (Backbone.Router.extend({
  initialize: function(){
    var document_id = $("#document_heading").attr("data-document-id");

    this.document = new Document({id: document_id});
    this.document.fetch();
    this.paragraphList = new ParagraphList();
    this.paragraphList.url = "/api/documents/" + document_id + "/";
    this.paragraphListView = new ParagraphListView({collection: this.paragraphList});
    this.paragraphList.fetch({data:{page:1}});
  }
}));
$(document).ready(function(){
  analizer.getTemplates();
  /*checkScroll();*/
  $("#next_page").live("click", function(){
    callNextPage();
    return false;
  });
  $(".people").live("click", function(){
    var $this = $(this);
  });
  /*documentContext = new DocumentContext({model: doc});*/
});

