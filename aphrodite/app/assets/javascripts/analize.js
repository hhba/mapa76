var AnalyzeApp = new (Backbone.Router.extend({
  initialize: function() {
    var document_id = $("#document-title").attr("data-document-id");

    this.document = new Document({ id: document_id });
    this.documentView = new DocumentView({ model: this.document });
    this.document.fetch();

    this.pageList = new PageList();
    this.pageList.url = "/api/documents/" + document_id;
    this.pageListView = new PageListView({ collection: this.pageList });

    this.register = new Register();
    this.registerView = new RegisterView({ model: this.register });
  },

  saveRegister: function() {
    AnalyzeApp.register = new Register(AnalyzeApp.registerView.getValues());
      if (AnalyzeApp.register.isValid()) {
        AnalyzeApp.register.save();
        AnalyzeApp.registerView.resetRegister();
        $("#register-save").alert().show().fadeOut(2000);
      } else {
        $("#register-error").alert().show().fadeOut(2000);
      }
   }
}));

var analyzer = {
  init: function() {
    this.getTemplates();
  },

  getTemplates: function() {
    this.pageTemplate = $('#pageTemplate').html();
    this.nextPageTemplate = $("#nextPageTemplate").html();
  }
};

function Droppable(el){
  this.el = el;
  this.new_el = this.el.find(".new");
  this.new_el.droppable({
    drop: function(event, ui) {
      var template = $("#preRegisterTemplate").html();
      var params = {
        text: ui.helper.text(),
        type: ui.draggable.attr("data-type"),
        ne_class: ui.draggable.attr("data-class"),
        id: ui.draggable.attr("data-ne-id")
      };
      $(this).before(Mustache.render(template, params));
      AnalyzeApp.register = new Register(AnalyzeApp.registerView.getValues());
      $(".sidebar").mCustomScrollbar("update");
    },
    accept: "." + this.el.attr("data-type")
  });
}

$(document).ready(function() {

  analyzer.getTemplates();

  window.droppable_klasses = ['who', 'when', 'where', 'to_who'];

  $("#reference input").click(function() {
    var $this = $(this);
    var klass = $this.parent().attr("class");
    $(".pages").toggleClass("hide-" + klass);
  });

  droppeables = _.map(window.droppable_klasses, function(klass) {
    return new Droppable($(".box." + klass));
  });

  $(".new_register button.close").live("click", function() {
    $(this).parent().remove();
  });

  $("button.clean").live("click", function() {
    AnalyzeApp.registerView.resetRegister();
  });

  $("button.save").live("click", function() {
    AnalyzeApp.saveRegister();
  });

  // Update scrollbar when changing tabs
  $(".document .nav a").live("click", function() {
    $(".sidebar").mCustomScrollbar("update");
  });
  if($("#map").length){
    drawMap();
  }
  $("button.showTimeline").click(function(event){
    event.preventDefault();
    $(".timeline-container").toggle("30");
  });
  currentTimeline = TimelineSetter.Timeline.boot(
    $("#timeline").data("dates"),
    {"interval":"","container":"#timeline"}
  );
});
