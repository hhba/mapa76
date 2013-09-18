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

  // Auto-update documents state
  function checkDocumentsStatuses() {
    $.get("/documents/status", null, function(data){
      _.each(data, function(doc){
        if (doc.percentage === 100){
          $("[data-id='" + doc.id + "']").
            find('.progress').
            hide();
        } else {
          $("[data-id='" + doc.id + "']").
            find('.progress').
            show().
            find('.bar').
              css("width", doc.percentage + "%");
        }
      });
    }, 'json');
    setTimeout(checkDocumentsStatuses, 1000 );
  }

  if($("table.documents").length){
    var template = $("#documentRowTemplate").html();
    checkDocumentsStatuses();
  }
});
