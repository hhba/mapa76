Milestone = Backbone.Model.extend({
  defaults: {
    what: "",
    where: "",
    when: "",
    date_from: new Date,
    date_to: new Date
  }
});
Person = Backbone.Model.extend({
  defaults: {
    name: "",
    searchable_name: ""
  },
  urlRoot: '/api/people',
  initialize: function(){}
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
  var url = "/api/documents/" + $("#next_page").attr("data-document") + "/paragraphs/" + $("#next_page").attr("data-next");
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
});
