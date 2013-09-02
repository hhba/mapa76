function reloadProjectList(){
  $.get("/api/v1/projects/",
    null,
    function(response){
      var template = _.template($("#projectsList").html()),
          $container = $(".projects_list");
      
      hh = {projects: response}
      console.log(hh)
      build = template(hh);
      $container.html(build);
      console.log(build)
      
    },
    'json'
  );
}
$(document).ready(function(){
  $(".with-scrollbar").mCustomScrollbar({
    mouseWheel: 5,
    scrollInertia: 250,
    advanced: { updateOnBrowserResize: true }
  });

  $(".documents .title a, a.thumbnail").click(function() {
    var $docRow = $(this).parents("tr");

    // Mark this document as "selected"
    $docRow.siblings().removeClass("selected");
    $docRow.addClass("selected");

    $("#context").empty().spin();

    var url = "/documents/" + $docRow.data("id") + "/context.json";
    $.getJSON(url, null, function(data) {
      $("#context").html(Mustache.render($("#documentContext").html(), data));
      $("#context .tablesorter").filter(function() {
        return $(this).find("tbody tr").length > 0;
      }).tablesorter({
        sortList: [[1,1]]
      });
      $(".with-scrollbar").mCustomScrollbar("update");
    }).error(function() {
      $("#context").html(Mustache.render($("#documentContextError").html()));
    });

    return false;
  });

  $("#context").on("click", ".nav a", function(){
    $(".with-scrollbar").mCustomScrollbar("update");
  });

  $(".documents").on("click", "a.add_to_project", function(event){
    var $this = $(this),
        $form = $("#add_to_project_form"); 
    event.preventDefault();
    $form.data("document-id", $this.data("document-id"));
    $("#addToProjectModal").modal();
  });

  $(".documents").on("submit", "#add_to_project_form", function(event){
    var $this = $(this),
        projectId = $this.find("select").val();
    event.preventDefault();
    $.post("/projects/" + projectId + "/add_document", {document_id: $this.data("document-id")}, function(response){
      reloadProjectList();
    }, 'json');
    $("#addToProjectModal").modal('hide');
  });


  // Auto-update documents state
  function checkDocumentsStatuses() {
    $.get("/documents/status", null, function(data){
      _.each(data, function(doc){
        $("[data-id='" + doc.id + "']").find(".bar").css("width", doc.percentage + "%");
      });
    }, 'json');
    setTimeout(checkDocumentsStatuses, 15000 );
  }

  if($("table.documents").length){
    var template = $("#documentRowTemplate").html();
    checkDocumentsStatuses();
  }

  /*
  // Blacklist
  $(".blacklist a").live("click", function(event){
    event.preventDefault();
    var $this = $(this);
    var answer = confirm("Enviar " + $this.data("name") + "a la blacklist?");
    if(answer) {
      $.post($this.attr("href"), null, function(){
        $this.parents("tr").remove();
        $(".with-scrollbar").mCustomScrollbar("update");
      }, null);
    }
  });
  */
});
