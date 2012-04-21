$(document).ready(function(){
  var td_length = 0;
  var i=0;
  var $td;
  var state;
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
      $("#stillProcessing").alert();
      break;
    }
  }
});
