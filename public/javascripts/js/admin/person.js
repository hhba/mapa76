//
// On init
//

$(document).ready(function() {

	// agrandar el fragmento
	$(".more").click(function(e) { update_fragment( $(e.currentTarget).parent(), 1); });
	$(".less").click(function(e) { update_fragment( $(e.currentTarget).parent(), 2); });
	$(".down").click(function(e) { update_fragment( $(e.currentTarget).parent(), 3); });
	$(".up").click(function(e) { update_fragment( $(e.currentTarget).parent(), 4); });

	// Bindeamos todos los eventos de JS a los fragmentos
	$("p.fragment").each(
	  function(idx,d){ 
      live_markup(d); 
    }
  );

	$("#milestone_human_date_from").datepicker({dateFormat: "dd/mm/yy", altFormat: "yy/mm/dd", altField: "#milestone_date_from"} );
	$("#milestone_human_date_to").datepicker({dateFormat: "dd/mm/yy", altFormat: "yy/mm/dd", altField: "#milestone_date_to"} );
});

// Actualiza el fragmento
function update_fragment( el, cur_action) {

    var cur_fragment_id = el.attr('id');
		var context_around = 400;

		$.getJSON("/context", {fragment_id: cur_fragment_id, around: context_around, action: cur_action},
      function(response) {
        // NO anda. Dios sabrá x que. Hay que usar document.getElementById() aca.
        // item = $('#' + response.prev_fragment_id.replace(/(:|\.)/g,'\\$1'), $('#fragment-pane')); // escapamos los : y . en el ID
        item = $(document.getElementById(response.prev_fragment_id));
        //item.name = response.fragment_id;
        item.children("p.fragment").html(response.text)
        live_markup(item.children("p.fragment"))
        // le cambiamos el id al <li> con el nuevo fragmento.
        item.attr('id', response.fragment_id);
      }
		);
}

function live_markup(o)
{
  // Cuando hacen click sobre una fecha mostramos el popup de Hitos.
  $(o).children(".date").click(function(e) {
		var parts = $(e.currentTarget).attr("datetime").split("-",3);
		$("#add_milestone").dialog({autoOpen: false, title: 'XXX'});
		if (! $("#add_milestone").dialog("isOpen") ){
		  $("#milestone_human_date_from").datepicker("setDate", parts[2] + "/" + parts[1] + "/" + parts[0]);
		  $("#milestone_human_date_to").datepicker("setDate","");
		  $("#milestone_source").val(e.currentTarget.id);
		  $("#add_milestone").dialog("open");
		} else {
		  $("#milestone_human_date_to").datepicker("setDate", parts[2] + "/" + parts[1] + "/" + parts[0]);
		}
  })

  // Cuando hacen click sobre un nombre mostramos la info de esa persona.
  $(o).children(".name").click(function(e){
    person_info($(e.currentTarget).text(), e.currentTarget.id, 'XXX');
  })

  // Cuando hacen click sobre una dirección ...
  $(o).children(".address").click(function(e) {
    if ( $("#add_milestone").dialog("isOpen") ) {
      var place_name = $(e.currentTarget).text().toLowerCase() 
      console.log("placename: ", place_name)
      var match_opt = $("#milestone_where_opc option").filter(function(i,e){return $(e).val().toLowerCase() == place_name} )
      console.log("matching opc:", match_opt)
      if (match_opt.length > 0){
        match_opt.attr("selected",true)
      } else {
        $("#milestone_where_txt").val($(e.currentTarget).text())
      }
    }
  });
}

function add_milestone(person_name, milestone_date, fragment_id)
{
  console.log(person_name,milestone_date,fragment_id)
}

function person_info(name,fragment_id,related_to)
{
  var dialog_id = "dialog" + name.toLowerCase().replace(/[^a-z]/gi,"_")
  var dialog = $("#"+dialog_id)
  console.log(dialog_id)
  if (dialog.length){
	dialog.dialog("open")
	return
  }
  var dialog = $("<div id='"+dialog_id+"'></div>")
  dialog.html("<p><a href='"+name+"'>View in context</a></p>")

  var loading_image = $("<img src='/images/ajax-loader.gif' />")
  dialog.append(loading_image)
  
  $(".body").append(dialog) 
  dialog.dialog({title: name})
  dialog.dialog("open")

  $.getJSON("/admin/person/",{name: name},
	function(d){
	  $(loading_image).remove()
	  dialog.append("<p>"+d+"</p>")
	}
  );
}

function address_info(lat,lon,addr,fragment_id)
{
  var url="http://maps.google.com/maps/api/staticmap?size=200x200&markers=color:blue|"+lat+","+lon;
  $("#map #map_img").attr("src",url)
}

// vim: se ts=2 sw=2 expandtab:
