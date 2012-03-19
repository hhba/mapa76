function populateSwitch($element){
    var populators = [datePopulator, addressPopulator, personPopulator];
    $.each(populators, function(index, populator) {
        if(populator.canPopulate($element)){
            populator.populate($element);
        }
    });
}
var datePopulator = {
    className : "date",
    canPopulate : function($element){
        return $element.hasClass(this.className);
    },
    populate : function($element){
        $(".datepicker").each(function(index){
            if(this.value === ""){
                var $this = $(this);
                var input_parsed = $this.attr("id").replace("_txt", "_parsed");
                var input_frag = $this.attr("id").replace("_txt", "_frag");
                var date_parsed = $element.attr("datetime");
                var date_frag = $element.attr("id");
                var date_txt = $element.html();
                $this.val(date_txt);
                $("#" + input_parsed).val(date_parsed);
                $("#" + input_frag).val(date_frag);
                return false;
            }
        });
    }
};
var addressPopulator = {
    className : "address",
    canPopulate : function($element){
        return $element.hasClass(this.className);
    },
    populate : function($element){
        var where = $element.children(".where").html();
        var where_frag = $element.attr("frag");
        $("#event_where_txt").val(where);
        $("#event_where_frag").val(where_frag);
        return true;
    }
};
var personPopulator = {
    className : "person",
    canPopulate : function($element){
        return $element.hasClass(this.className);
    },
    populate : function($element){
        var person_id = $element.attr("person_id");
        var who_txt = $element.html();
        var who_frag = $element.attr("frag");
        $("#person_txt").val(who_txt);
        $("#event_person_id").val(person_id);
        $("#event_person_frag").val(who_frag);
        return true;
    }
};
var datepicker_options = {
  /*dateFormat: "dd/mm/yy",*/
  /*altFormtat: "yy/mm/dd",*/
  yearRange: "1973:1983",
  changeMonth: true,
  changeYear: true
};
function notifyResult(data){
  if(data['saved']){
    $("#successMessage").alert();
  } else {
    $("#errorMessage").alert();
  }
}
$(document).ready(function(){
  $("#event_date_from_txt").datepicker(datepicker_options);
  $("#event_date_to_txt").datepicker(datepicker_options);
  $(".popup").click(function(){
    populateSwitch($(this));
    $(".alert").alert('close');
    if($("#add_event").dialog("isOpen") !== true){
      $("#add_event").dialog();
    }
    return false;
  });
  $(".clear").click(function(){
    $("form.add_event input").val("");
    return false;
  });
  $(".clear_field").click(function(){
    $(this).parent().find("input").val("");
    return false;
  });
  $("button#save_event").click(function(){
    $form = $("form.add_event");
    $.post($form.attr("action"), $form.selialize(), notifyResult, 'json');
    $("form.add_event input").val("");
    $("#add_event").dialog("close");
    return false;
  });
});