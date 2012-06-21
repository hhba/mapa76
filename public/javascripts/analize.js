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
  $("#whatSelector").change(function(){
    AnalizeApp.register = new Register(AnalizeApp.registerView.getValues());
  });
});
