var analizer = {
  init: function(){
    this.getTemplates();
  },
  getTemplates: function(){
    this.paragraphTemplate = $('#paragraphTemplate').html();
  },
  addParagraph: function(data){
    var url;
    //analizer.new_html = Mustache.render(analizer.paragraphTemplate, data);
    $(".paragraphs").append(Mustache.render(analizer.paragraphTemplate, data));
    $("#loading").hide();
    if(data.more_pages){
      url = "/documents/" + data.document_id + "/comb?page=" + data.next_page;
      $(".next_page").html("<a href='" + url + "' id='next_page'>Cargar más contenido</a>");
      callNextPage();
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
