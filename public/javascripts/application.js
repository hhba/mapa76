$(document).ready(function(){
  // $("#published_at").datepicker({
  //     changeMonth: true,
  //     changeYear: true,
  //     minDate: new Date(1976, 1 - 1, 1)
  // });
  $("#sorteable").tablesorter();
  $("#showhide").click(function(event){
    event.preventDefault();
    $("tr.classified_bad").toggleClass("hidden");
    $("tbody tr:visible").each(function(index){
      $(this).find("td:first").html(index + 1);
    });
  });
  $("#classify").click(function(event){
    event.preventDefault();
    $(".claddifyName").toggleClass("hidden");
  });
  $("#selectAll").toggle(
    function () {
      $(this).html("No seleccionar nada");
      $("span.name").find("input").prop("checked", true);
      return false;
    },
    function () {
      $(this).html("Seleccionar todo");
      $("span.name").find("input").prop("checked", false);
      return false;
    }
  );
  $("a.trainner").click(function(event){
    var $this = $(this);
    event.preventDefault();
    $.post("/api/classify_name",
        {
          name: $this.attr("data-name"),
          training: $this.attr("data-value")
        },
        function(data){
          if(data){
            $this.hide();
          }
        },
        "json"
      );
  });
	$('.paragraphs span.ne').draggable({
		helper: 'clone'
	}).css('cursor', 'move');
	init_drops();
       // $.post("<%=url_for :admin_classify_name %>",
       //          {name: $(e.currentTarget).parents("li").children("span.name").text(), training: $(e.currentTarget).attr("value")},
       //          function(b){$(e.currentTarget).parents("span.buttons").text("res")},
       //          "json"
       //        )
       //  }
});
function init_drops(){
	$('.event.new').removeClass('new').droppable({
        drop: function(ev, ui) {
        	if ($(this).html() == '')
        	{
        		$(this).removeClass('empty').after('<div ondragover="event.preventDefault()" class="event new empty"></div>');
        		init_drops();
        	}
        	  var draggable = ui.draggable;
        	$(this).append('<span class="dragged ' + draggable.attr('class') + '">' + draggable.text() + '<i></i></span><wbr>');
        }
     });
}