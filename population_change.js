
var width = window.innerWidth / 100 * 50;
// var width = document.getElementById("content_size").offsetWidth;

// Components of change
var request = new XMLHttpRequest();
    request.open("GET", "./area_components_of_change_df.json", false);
    request.send(null);

var json_coc = JSON.parse(request.responseText); // parse the fetched json data into a variable

var wsx_coc = json_coc.filter(function(d){
      return d.Year === '2018' &
             d.Area_name === 'West Sussex'})

// Create values
var nat_change = d3.max(wsx_coc, function (d) {
  return +d.natchange;});

var internal_net = d3.max(wsx_coc, function (d) {
  return +d.internal_net;});

var international_net = d3.max(wsx_coc, function (d) {
  return +d.international_net;});

// top_cause_change will be the highest of the three values
var top_cause_change = d3.max([nat_change, internal_net, international_net])

// This function says if the highest value is nat_change then output string one, and so on.
var change_switch_key = d3.scaleOrdinal()
    .domain([nat_change, internal_net, international_net])
    .range(['more births than deaths', 'more people moving into the area from elsewhere in the UK', 'more people moving into the area from other countries'])

d3.select("#wsx_intro_string")
    .data(wsx_coc)
    .text(function(d) {
        return 'In ' +d.Year + ', ' + d3.format(',.0f')(d.population) + ' people were estimated to be resident in ' + d.Area_name + '. This was ' + d3.format(',.0f')(d.pop_change) + ' more than in the previous year (' + d3.format(',.0f')(d.population - d.pop_change) + '), an increase of approximately ' + d3.format('0.1f')(d.pop_change / (d.population - d.pop_change) * 100) + '%. There were ' + d3.format(',.0f')(d.births) + ' births and ' + d3.format(',.0f')(d.deaths) + ' deaths and net internal migration (from/to elsewhere in the UK) was ' + d3.format(',.0f')(d.internal_net) + ' (' + d3.format(',.0f')(d.internal_out) + ' people moving out and ' + d3.format(',.0f')(d.internal_in) + ' people moving in). Net international migration in ' + d.Area_name + ', in ' + d.Year + ', was ' + d3.format(',.0f')(d.international_net) + ' (' + d3.format(',.0f')(d.international_out) + ' people moving out and ' + d3.format(',.0f')(d.international_in) + ' people moving in). This means that population increase resulted largely from ' + change_switch_key(top_cause_change) + '.'});

var height_pyramid = 500;

// margins
var margin = {top: 30,
              right: 30,
              bottom: 100,
              left: 60};

// append the svg object to the body of the page
var svg_pyramid = d3.select("#pyramid_1_datavis")
.append("svg")
.attr("width", width)
.attr("height", height_pyramid + margin.top + 75)
.append("g")
.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// This will require a lot of calculations from the mid point to the edge of bars

// Add X axis scale - this is the max value plus 10%
var x_pyramid_males = d3.scaleLinear()
.domain([0, max_risk_value + (max_risk_value * .1)])
.range([0, width - 240]);

var xAxis_top_risks = top_ten_risks_svg
.append("g")
.attr("transform", "translate(0," + height_top_ten + ")")
.call(d3.axisBottom(x_top_ten).tickSizeOuter(0));

// Y axis scale
var y_top_ten = d3.scaleBand()
.domain(top_risk_selected.map(function(d) { return d.Risk; }))
.range([0, height_top_ten])
.padding([0.2]);
