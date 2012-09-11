var fustion_table_id = 5136458;//5135598;//5121175; //
var map;
var layerl0;
var styles = [];
var groups = [{
    icon: "measle_brown",
    places: ["DEPENDENCIA ESTATAL", "DEPENDENCIA POLICIA PROVINCIAL", "DEPENDENCIA POLICIA FEDERAL"]
  },
  {
    icon: "small_blue",
    places: ["DEPENDENCIA GENDARMERIA", "DEPENDENCIA PREFECTURA"]
  },
  {
    icon: "small_red",
    places: ["UNIDAD MILITAR EJERCITO", "UNIDAD MILITAR FUERZA AEREA", "UNIDAD MILITAR MARINA"]
  },
  {
    icon: "small_yellow",
    places: ["DEPENDENCIA SERVICIO PENITENCIARIO PROVINCIAL", "UNIDAD PENITENCIARIA PROVINCIAL", "UNIDAD PENITENCIARIA FEDERAL", "UNIDAD PENITENCIARIA"]
  },
  {
    icon: "measle_grey",
    places: ["ESTABLECIMIENTO EDUCATIVO", "ESTABLECIMIENTO PRIVADO", "HOSPITAL PUBLICO", "HOSPITAL MILITAR", "VIVIENDA O SIMILAR / PARTICULAR", "[SIN ESTABLECER]", "OTROS"]
}];

function buildQuery(conditions){
  var new_conditions = [];
  for(var index in conditions){
    new_conditions.push("'" + conditions[index] + "'");
  }
  return "'tipo_estab_ccd' IN (" + new_conditions.join(", ") +")";
}

for(var index in groups){
  styles.push({
    where: buildQuery(groups[index].places),
    markerOptions: {
      iconName: groups[index].icon
    }
  });
}

function initialize() {
  map = new google.maps.Map(document.getElementById('map-canvas'), {
    center: new google.maps.LatLng(-33.65682940830173, -63.85107421875),
    zoom: 5
  });
  var style = [
    {
      featureType: 'all',
      elementType: 'all',
      stylers: [
        { saturation: -99 }
      ]
    }
  ]
  var styledMapType = new google.maps.StyledMapType(style, {
    map: map,
    name: 'Styled Map'
  });
  map.mapTypes.set('map-style', styledMapType);
  map.setMapTypeId('map-style');
  layerl0 = new google.maps.FusionTablesLayer({
    query: {
      select: "'Geo posta'",
      from: fustion_table_id
    },
    styles: styles,
    map: map
  });
}

function changeMapProv() {
  var searchString = document.getElementById('search-string-l2').value.replace(/'/g, "\\'");
  layerl0.setOptions({
    query: {
      select: "'Geo posta'",
      from: fustion_table_id,
      where: "'nom_prov' = '" + searchString + "'"
    }
  });
}

function changeMapl1() {
  var searchString = document.getElementById('search-string-l1').value.replace(/'/g, "\\'");
  layerl0.setOptions({
    query: {
      select: "'Geo posta'",
      from: fustion_table_id,
      where: "'ccd' CONTAINS IGNORING CASE '" + searchString + "'"
    }
  });
}

function changeMapl0() {
  var searchString = document.getElementById('search-string-l0').value.replace(/'/g, "\\'");
  if(searchString === ""){
    cleanSearch();
  } else {
    layerl0.setOptions({
      query: {
        select: "'Geo posta'",
        from: fustion_table_id,
        where: "'tipo_estab_ccd' = '" + searchString + "'"
      }
    });
  }
}

function cleanSearch(){
  layerl0.setOptions({
    query: {
      select: "'Geo posta'",
      from: fustion_table_id
    }
  });
}

google.maps.event.addDomListener(window, 'load', initialize);
