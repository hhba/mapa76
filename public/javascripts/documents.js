$(document).ready(function(){
  var td_length = 0;
  var i=0;
  var $td;
  var state;

  function checkDocumentsStatuses(){
    console.log("vueltas");
    $.getJSON("/api/documents_states", function(data){
      var $tds = $("td.state");
      for(i=0;i<$tds.length;i++){
        $($tds[i]).text(data[i]);
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

  $td = $("td");
  td_length = $td.length;
  for(i=0;i<td_length;i++){
    state = $.trim($($td[i]).text());
    if(state === "waiting" || state === "processing" || state === "preprocessing"){
      $("#stillProcessing").alert().css("display", "block");
      break;
    }
  }
  setTimeout(checkDocumentsStatuses, 15000 );
});
