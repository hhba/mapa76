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
  render: function(){
    var html = Mustache.render(this.documentTemplate, this.model);
    console.log(this.model);
    this.$el.html(html);
  }
});
var PersonContext = Backbone.View.extend({
  el: "#contenxt",
  render: function(event){
    var compiledTemplate = _.template($("#contextTemplate").html());
    this.$el.html(compiled_template(this.model.toJSON()));
    return this;
  },
  events: {
    "submit#Update": "update",
    "click .reset": "reset"
  },
  update: function(event){
    alert("update button");
  },
  reset: function(event){
    alert("reset button");
  }
});
var Document = Backbone.Model.extend({
  urlRoot: '/api/documents/',
  initialize: function(){
    this.on("sync", function(){
      console.log("sincronizado!");
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
    this.on("change:name", function(){
        alert("the name has changed");
    });
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
    setTimeout("checkScroll()", 250);
  }
}
function callNextPage(){
  var url = "/api/documents/" + $("#next_page").attr("data-document") + "?page=" + $("#next_page").attr("data-next");
  $("#loading").show();
  $("#next_page").remove();
  $.getJSON(url, analizer.addParagraph);
}

$(document).ready(function(){
  analizer.getTemplates();
  checkScroll();
  $("#next_page").live("click", function(){
    callNextPage();
    return false;
  });
  $(".people").live("click", function(){
    var $this = $(this);
    console.log($this.attr("data-id"));
  });
});
