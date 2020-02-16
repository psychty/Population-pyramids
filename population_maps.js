
var width_map = document.getElementById("content_size").offsetWidth;

// https://github.com/Leaflet/Leaflet.heat

// L. is leaflet
// var tileUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
// var attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Contains Ordnance Survey data © Crown copyright and database right 2020.';

var tileUrl = 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
var attribution = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a><br> Contains Ordnance Survey data © Crown copyright and database right 2020.<br>Zoom in/out using your mouse wheel or the plus (+) and minus (-) buttons. Click on an area to find out more';

// read lsoa
// Add AJAX request for data
var lsoa = $.ajax({
  url:"./lsoa_density_simple.geojson",
  dataType: "json",
  success: console.log("LSOA boundary data successfully loaded."),
  error: function (xhr) {
    alert(xhr.statusText)
  }
})

function get_density_colour(d) {
    return d > 14000 ? '#800026' :
           d > 12000  ? '#BD0026' :
           d > 10000  ? '#E31A1C' :
           d > 8000  ? '#FC4E2A' :
           d > 6000  ? '#FD8D3C' :
           d > 4000   ? '#FEB24C' :
           d > 2000  ? '#FED976' :
                      '#fffac7';
}

function LSOAcolour(feature) {
  return {
    fillColor: get_density_colour(feature.properties.Pop_per_sq_km),
    // color: 'white',
    // color: get_density_colour(feature.properties.Pop_per_sq_km),
    weight: 0,
    fillOpacity: .8};
}

$.when(lsoa).done(function() {

var map = L.map('map_density');

if(width_map <= 800){

var basemap = L.tileLayer(tileUrl, {
  attribution,
  maxZoom: 17,
  minZoom: 9
})
    .addTo(map);

  }

if(width_map > 800){

var basemap = L.tileLayer(tileUrl, {
    attribution,
    maxZoom: 17,
    minZoom: 10
  })
      .addTo(map);

    }

var lsoa_boundary = L.geoJSON(lsoa.responseJSON,
      {style: LSOAcolour})
      .addTo(map)
      .bindPopup(function (layer) {
    return '<Strong>'+ layer.feature.properties.Name + '</Strong><br><br>Population per square kilometre: ' + d3.format(',.0f')(layer.feature.properties.Pop_per_sq_km) + '<br>Total population: ' + d3.format(',.0f')(layer.feature.properties.Pop_2018) + '<br><br>This LSOA is in the ' + layer.feature.properties.ward_label});

map
.fitBounds(lsoa_boundary.getBounds());

// Legend
var legend = L.control({position: 'bottomright'});

legend.onAdd = function (map) {
    var div = L.DomUtil.create('div', 'legend'),
        grades = [0, 2000, 4000, 6000, 8000, 10000, 12000, 14000];

        // add title
      div.innerHTML += "<p><b>Population per sq km</b></p>";

// loop through our density intervals and generate a label with a colored square for each interval
  for (var i = 0; i < grades.length; i++) {
    div.innerHTML +=
    '<i style="background:' + get_density_colour(grades[i] + 1) + '"></i> ' +
    d3.format(',.0f')(grades[i]) + (grades[i + 1] ? '&ndash;' + d3.format(',.0f')(grades[i + 1]) + '<br>' : '+');
    }

    return div;
};

legend
.addTo(map);

});
