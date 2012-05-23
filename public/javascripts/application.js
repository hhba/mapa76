$(document).ready(function(){
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
  });
  init_drops();
});
function init_drops(){
  $("#reference li input").click(function(){
    var klass = $(this).parent("li").attr("class");
    $(".paragraphs .ne." + klass).toggleClass("nocolor");
  });
  $('.event.new').removeClass('new').droppable({
        drop: function(ev, ui) {
          if ($(this).html() === '')
          {
            $(this).removeClass('empty').html('<div class="control-group"><div class="input-append"><input type="text" class="event-name" placeholder="Nombre del evento"><button class="btn event-save" type="button">Guardar</button></div></div>').after('<div ondragover="event.preventDefault()" class="event new empty"></div>');
            init_drops();
          }
            var draggable = ui.draggable;
          $(this).append('<span class="dragged ' + draggable.attr('class') + '">' + draggable.text() + '<i></i></span><wbr>');
          $('span.dragged i').unbind('click').click(function(){
            $(this).parent('span.dragged').remove();
          });
        }
     });
}
