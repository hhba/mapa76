var analizer = {
  init: function(){
    this.getTemplates();
  },
  getTemplates: function(){
    this.indexTemplate = $('#indexTemplate').html();
  },
  getDocumentId: function(){
    return $.trim($("#document_id").text());
  },
  loadInformation: function(){
    return 2;
  },
  getDocumentIndex: function(document_id){
    var url = "/api/" + document_id + "/document_index";
    $.get(url, null, this.printDocumentIndex, "json");
  },
  printDocumentIndex: function(data){
    $(".content").append(Mustache.render(analizer.indexTemplate, data));
    $(".loading").remove();
  },
  populateParagraph: function(document_id, data){
    $("td#" + document_id).html(data.content);
  }
};
$(document).ready(function(){
  var document_id = analizer.getDocumentId();

  $("a.paragraph").live("click", function(){
    var url = $(this).attr("href");
    var document_id = $(this).attr("data-id");
    $.getJSON(url, function(data) {
      analizer.populateParagraph(document_id, data);
    });
    return false;
  });

  analizer.init();
  analizer.getDocumentIndex(document_id);
});
