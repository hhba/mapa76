// Put your application scripts here
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
  $("#selectAll").click(function(event){
    event.preventDefault();
    $("span.name").find("input").prop("checked", false);
  });

       // $.post("<%=url_for :admin_classify_name %>",
       //          {name: $(e.currentTarget).parents("li").children("span.name").text(), training: $(e.currentTarget).attr("value")},
       //          function(b){$(e.currentTarget).parents("span.buttons").text("res")},
       //          "json"
       //        )
       //  }


});