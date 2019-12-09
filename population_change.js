
// var width = window.innerWidth / 100 * 50;
var width = document.getElementById("content_size").offsetWidth;

var height_pyramid = 500;

// margins
var margin = {top: 30,
              right: 30,
              bottom: 100,
              left: 30};

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

// Population pyramid data
var request = new XMLHttpRequest();
    request.open("GET", "./area_population_quinary_df_v2.json", false);
    request.send(null);

var json_pyramid = JSON.parse(request.responseText); // parse the fetched json data into a variable

var data = json_pyramid.filter(function(d){
    return d.Year === '2018' &
           d.Area_Name === 'West Sussex'})

// append the svg object to the body of the page
var svg_pyramid_1 = d3.select("#pyramid_1_datavis")
.append("svg")
.attr("width", width + margin.left + margin.right)
.attr("height", height_pyramid + margin.top + 75)
.append("g")
.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// space for y axis
margin.middle = 60;

// Once you have these points set up, things become much simpler, since you can simply plug these values into an svg transform to translate the objects you create to those positions.

// some contrived data
var exampleData = [
  {group: '0-9', male: 10, female: 10},
  {group: '10-19', male: 14, female: 15},
  {group: '20-29', male: 15, female: 18},
  {group: '30-39', male: 18, female: 18},
  {group: '40-49', male: 21, female: 22},
  {group: '50-59', male: 19, female: 24},
  {group: '60-69', male: 15, female: 14},
  {group: '70-79', male: 8, female: 1},
  {group: '80-89', male: 4, female: 5},
  {group: '90-99', male: 2, female: 3},
  {group: '100-109', male: 18, female: 1},
];

console.log(data)
// GET THE TOTAL POPULATION SIZE AND CREATE A FUNCTION FOR RETURNING THE PERCENTAGE
var totalPopulation = d3.sum(exampleData, function(d) { return d.male + d.female; });

// find the maximum data value on either side
var maxPopulation = Math.max(
  d3.max(exampleData, function(d) { return d.male; }),
  d3.max(exampleData, function(d) { return d.female; })
);

// plotting region for each pyramid and Where should the pyramids start (males on the left)
var pyramid_plot_width = (width/2) - (margin.middle/2);
var male_zero = pyramid_plot_width
var female_zero = width - pyramid_plot_width

// the scale goes from 0 to the width of the pyramid plotting region. We will invert this for the left x-axis
var x_pyramid_scale_male = d3.scaleLinear()
  .domain([0, maxPopulation])
  .range([male_zero, 0]);

var xAxis_pyramid_1 = svg_pyramid_1
  .append("g")
  .attr("transform", "translate(0," + height_pyramid + ")")
  .call(d3.axisBottom(x_pyramid_scale_male));

var x_pyramid_scale_female = d3.scaleLinear()
  .domain([0, maxPopulation])
  .range([female_zero, width]);

var xAxis_pyramid_2 = svg_pyramid_1
  .append("g")
  .attr("transform", "translate(0," + height_pyramid + ")")
  .call(d3.axisBottom(x_pyramid_scale_female));

var pyramid_scale_bars = d3.scaleLinear()
  .domain([0,maxPopulation])
  .range([0, pyramid_plot_width]);

// .tickFormat(d3.format('.0%'))
ages = exampleData.map(function(d) { return d.group; })

// Y axis scale
var y_pyramid_1 = d3.scaleBand()
.domain(ages)
.range([height_pyramid, 0])
.padding([0.2]);

yaxis_pos = female_zero - (margin.middle / 2)

var yAxis_top_risks = svg_pyramid_1
.append("g")
.attr("transform", "translate(0" + yaxis_pos + ",0)")
.call(d3.axisLeft(y_pyramid_1).tickSize(0))
.style('text-anchor', 'middle')
.select(".domain").remove()

svg_pyramid_1
.selectAll("myRect")
.data(exampleData)
.enter()
.append("rect")
.attr("x", female_zero)
.attr("y", function(d) { return y_pyramid_1(d.group); })
.attr("width", function(d) { return pyramid_scale_bars(d.female); })
.attr("height", y_pyramid_1.bandwidth())
.attr("fill", "#f49b2f")

svg_pyramid_1
.selectAll("myRect")
.data(exampleData)
.enter()
.append("rect")
.attr("x", function(d) { return male_zero - pyramid_scale_bars(d.male); })
.attr("y", function(d) { return y_pyramid_1(d.group); })
.attr("width", function(d) { return pyramid_scale_bars(d.male); })
.attr("height", y_pyramid_1.bandwidth())
.attr("fill", "#193d82")

// svg_pyramid_1
// .selectAll("myRect")
// .data(exampleData)
// .enter()
// .append("rect")
// .attr("x", male_zero)
// .attr("y", function(d) { return y_pyramid_1(d.group); })
// .attr("width", function(d) { return - x_pyramid_scale_female(d.female); })
// .attr("height", y_pyramid_1.bandwidth())
// .attr("fill", "#f49b2f")
