$(document).ready(function(){
  var i=0;
  var $td;
  var state;

  function checkDocumentsStatuses(){
    $.getJSON("/api/documents_states", function(data){
      var $bars = $(".bar");
      for(i=0;i<$bars.length;i++){
        $($bars[i]).css("width", data[i] + "%");
      }
    });
    setTimeout(checkDocumentsStatuses, 15000 );
  }

  $(".link a").popover();
  $(".link a").click(function(event){
    event.preventDefault();
    var $this = $(this);
    $.get($this.attr("href"),
      null,
      function(data){
        $this.parent().siblings(".content").html(data.p);
      },
      'json');
  });

  $("#stillProcessing").alert().css("display", "block");
  setTimeout(checkDocumentsStatuses, 15000 );
  if($(".tablesorter").length !== 0) {
    $(".tablesorter").tablesorter();
  }
  $(".documents tbody tr").click(function() {
    $(this).siblings().removeClass("selected");
    $(this).addClass("selected");
    var url = "/api/" + $(this).data("id") + "/context";
    var template = $("#documentContext").html();
    $("#document").html("").spin();
    $.getJSON(url, null, function(data) {
      $("#document").html(Mustache.render(template, data));
    }).error(function() {
      $("#document").html(Mustache.render($("#documentContextError").html()));
    });
    return false;
  });
});

