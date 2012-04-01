$(document).ready(function(){
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
});