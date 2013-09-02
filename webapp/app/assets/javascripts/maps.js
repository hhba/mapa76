function drawMap() {
  var $info = $("#map");
  var center = $info.data("center");
  var addresses = $info.data("addresses");
  var latlng = new google.maps.LatLng(center.lat, center.lng);
  var myOptions = {
    zoom: 11,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var map = new google.maps.Map(document.getElementById("map"), myOptions);
  var infoTemplate = $("#mapTooltipTemplate").html();
  var lastInfowindow = null;
  var centered = false;
  _.each(addresses, function(addr){
    (function() {
      var myLatlng = new google.maps.LatLng(addr.lat, addr.lng);
      var myOptions = {
        zoom: 4,
        center: myLatlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      if (!centered) {
        centered = true;
        map.panTo(myLatlng);
      }
      var title = addr.text;
      var infowindow = new google.maps.InfoWindow({
        content: Mustache.render(infoTemplate, {
          title: title,
          context: addr.context.replace(addr.text, "<b>" + addr.text + "</b>"),
          document_id: addr.document_id,
          page_num: addr.page_num
        })
      });
      var marker = new google.maps.Marker({
        position: myLatlng,
        map: map,
        title: title
      });
      google.maps.event.addListener(marker, "click", function() {
        if (lastInfowindow) lastInfowindow.close();
        infowindow.open(map, marker);
        lastInfowindow = infowindow;
      });
    })();
  });
}
