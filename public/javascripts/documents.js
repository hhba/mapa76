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
});
