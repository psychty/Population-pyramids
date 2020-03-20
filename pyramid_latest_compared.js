

// Population pyramid
var request = new XMLHttpRequest();
    request.open("GET", "./area_population_quinary_df_v2.json", false);
    request.send(null);

var json_pyramid = JSON.parse(request.responseText); // parse the fetched json data into a variable

// List of years in the dataset
var latest_year_pyr = d3.max(json_pyramid, function (d) {
     return (d.Year)
     })

// console.log(latest_year_pyr)

// List of areas in the dataset
var areas_pyramid_compare = d3.map(json_pyramid, function (d) {
   return (d.Area_Name)
   })
   .keys()

// We need to create a dropdown button for the user to choose which area to be displayed on the figure.
d3.select("#selectArea1P1Button")
    .selectAll('myOptions')
    .data([ 'Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing', 'West Sussex', 'South East', 'England'])
    .enter()
    .append('option')
    .text(function (d) {
        return d; }) // text to appear in the menu - this does not have to be as it is in the data (you can concatenate other values).
    .attr("value", function (d) {
        return d; }) // corresponding value returned by the button

var selectedArea1P1Option = d3.select('#selectArea1P1Button').property("value")

d3.select("#selectArea2P1Button")
    .selectAll('myOptions')
    .data(['West Sussex', 'South East', 'England', 'Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing'])
    .enter()
    .append('option')
    .text(function (d) {
        return d; }) // text to appear in the menu - this does not have to be as it is in the data (you can concatenate other values).
    .attr("value", function (d) {
        return d; }) // corresponding value returned by the button

var selectedArea2P1Option = d3.select('#selectArea2P1Button').property("value")

// append the svg object to the body of the page
var svg_pyramid_1 = d3.select("#pyramid_1_datavis")
.append("svg")
.attr("width", width + margin.left + margin.right)
.attr("height", height_pyramid + margin.top + 75)
.append("g")
.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var data_bars = json_pyramid.filter(function(d){
    return d.Year === '2018' &
           d.Area_Name === selectedArea1P1Option})
    .sort(function(a,b) {
    return age_levels.indexOf( a.Age_group) > age_levels.indexOf( b.Age_group)});

var data_lines = json_pyramid.filter(function(d){
    return d.Year === '2018' &
           d.Area_Name === selectedArea2P1Option})
    .sort(function(a,b) {
    return age_levels.indexOf( a.Age_group) > age_levels.indexOf( b.Age_group)});

function update_p1(data) {

var selectedArea1P1Option = d3.select('#selectArea1P1Button').property("value")
var selectedArea2P1Option = d3.select('#selectArea2P1Button').property("value")

// This selects the text on the figure and removes it imediately
svg_pyramid_1
 .selectAll("text")
 .remove();

svg_pyramid_1
 .selectAll("*")
 .remove();

var data_bars = json_pyramid.filter(function(d){
    return d.Year === '2018' &
           d.Area_Name === selectedArea1P1Option})
    .sort(function(a,b) {
    return age_levels.indexOf( a.Age_group) > age_levels.indexOf( b.Age_group)});

var data_lines = json_pyramid.filter(function(d){
    return d.Year === '2018' &
           d.Area_Name === selectedArea2P1Option})
    .sort(function(a,b) {
    return age_levels.indexOf( a.Age_group) > age_levels.indexOf( b.Age_group)});

var showTooltip_p1_male = function(d, i) {

tooltip_compare_pyramid_male_bars
  .html("<h2>" + d.Area_Name + '; ' + d.Age_group + '</h2><p class = "side">The estimated number of males aged ' + d.Age_group + ' living in ' + d.Area_Name + ' in 2018 was ' + d3.format(",.0f")(d.Male_Population) + '. This is ' + d3.format('.1%')(d.Male_Percentage) + ' of the population of males in ' + d.Area_Name + 'in 2018.</p><p class = "side"><b>Note:</b> resident estimates are rounded in the figure although percentages are calculated based on unrounded estimates.</p>')
  .style("opacity", 1)
  .style("top", (event.pageY - 10) + "px")
  .style("left", (event.pageX + 10) + "px")
  .style("visibility", "visible")
        }

var showTooltip_p1_female = function(d, i) {

tooltip_compare_pyramid_female_bars
  .html("<h2>" + d.Area_Name + '; ' + d.Age_group + '</h2><p class = "side">The estimated number of females aged ' + d.Age_group + ' living in ' + d.Area_Name + ' in 2018 was ' + d3.format(",.0f")(d.Female_Population) + '. This is ' + d3.format('.1%')(d.Female_Percentage) + ' of the population of females in ' + d.Area_Name + 'in 2018.</p><p class = "side"><b>Note:</b> resident estimates are rounded in the figure although percentages are calculated based on unrounded estimates.</p>')
  .style("opacity", 1)
  .style("top", (event.pageY - 10) + "px")
  .style("left", (event.pageX + 10) + "px")
  .style("visibility", "visible")
        }

// find the maximum data value on either side
 var maxPopulation_compare_pyr = Math.max(
   d3.max(data_bars, function(d) { return d.Female_Percentage; }),
   d3.max(data_bars, function(d) { return d.Male_Percentage; }),
  d3.max(data_lines, function(d) { return d.Female_Percentage; }),
  d3.max(data_lines, function(d) { return d.Male_Percentage; })
 );

if (maxPopulation_compare_pyr < .1){
 maxPopulation_compare_pyr = .1
}

var mouseleave_p1 = function(d) {
tooltip_compare_pyramid_male_bars
.style("visibility", "hidden")
tooltip_compare_pyramid_female_bars
.style("visibility", "hidden")
            }

d3.select("#selected_p_compare_title")
  	.text(function(d){
  	return "Population pyramid; " + selectedArea1P1Option + ' compared to ' + selectedArea2P1Option + '; 2018;' });

// These functions and variables will become universal so only need to be declared once (eventually) for the three pyramids
margin.middle = 80;

// plotting region for each pyramid and Where should the pyramids start (males on the left)
var pyramid_plot_width = (width/2) - (margin.middle/2) ;
var male_zero = pyramid_plot_width
var female_zero = width - pyramid_plot_width

var formatPercent = d3.format(".0%")

// the scale goes from 0 to the width of the pyramid plotting region. We will invert this for the left x-axis
var x_compare_pyramid_scale_male = d3.scaleLinear()
  .domain([0, maxPopulation_compare_pyr])
  .range([male_zero, 0]);
//
var xAxis_compare_pyramid = svg_pyramid_1
  .append("g")
  .attr("transform", "translate(0," + height_pyramid + ")")
  .call(d3.axisBottom(x_compare_pyramid_scale_male).tickFormat(formatPercent));

var x_compare_pyramid_scale_female = d3.scaleLinear()
  .domain([0, maxPopulation_compare_pyr])
  .range([female_zero, width]);

var xAxis_compare_pyramid_2 = svg_pyramid_1
  .append("g")
  .attr("transform", "translate(0," + height_pyramid + ")")
  .call(d3.axisBottom(x_compare_pyramid_scale_female).tickFormat(formatPercent));

var compare_pyramid_scale_bars = d3.scaleLinear()
  .domain([0,maxPopulation_compare_pyr])
  .range([0, pyramid_plot_width]);

var tooltip_compare_pyramid_female_bars = d3.select("#pyramid_1_datavis")
    .append("div")
    .style("opacity", 0)
    .attr("class", "tooltip_pyramid_bars")
    .style("position", "absolute")
    .style("z-index", "10")
    .style("background-color", "white")
    .style("border", "solid")
    .style("border-width", "1px")
    .style("border-radius", "5px")
    .style("padding", "10px")

var tooltip_compare_pyramid_male_bars = d3.select("#pyramid_1_datavis")
  .append("div")
  .style("opacity", 0)
  .attr("class", "tooltip_pyramid_bars")
  .style("position", "absolute")
  .style("z-index", "10")
  .style("background-color", "white")
  .style("border", "solid")
  .style("border-width", "1px")
  .style("border-radius", "5px")
  .style("padding", "10px")

// // Y axis scale
var y_pyramid_compare = d3.scaleBand()
.domain(age_levels)
.range([height_pyramid, 0])
.padding([0.2]);

yaxis_pos = female_zero - (margin.middle / 2)

var yAxis_compare_pyramid = svg_pyramid_1
.append("g")
.attr("transform", "translate(0" + yaxis_pos + ",0)")
.call(d3.axisLeft(y_pyramid_compare).tickSize(0))
.style('text-anchor', 'middle')
.select(".domain").remove()

 svg_pyramid_1
  .selectAll("myRect")
  .data(data_bars)
  .enter()
  .append("rect")
  .attr("x", female_zero)
  .attr("y", function(d) { return y_pyramid_compare(d.Age_group); })
  .attr("width", function(d) { return compare_pyramid_scale_bars(d.Female_Percentage) })
  .attr("height", y_pyramid_compare.bandwidth())
  .attr("fill", "#0099ff")
  .on("mousemove", showTooltip_p1_female)
  .on('mouseout', mouseleave_p1)

svg_pyramid_1
    .append('g')
    .append("path")
    .datum(data_lines)
    .attr("d", d3.line()
    .x(function (d) { return compare_pyramid_scale_bars(d.Female_Percentage) + female_zero })
    .y(function(d) { return y_pyramid_compare(d.Age_group) + 10; }))
    .attr("stroke", '#005b99')
    .style("stroke-width", 3)
    .style("fill", "none");

svg_pyramid_1
.selectAll("myRect")
.data(data_bars)
.enter()
.append("rect")
.attr("x", function(d) { return male_zero - compare_pyramid_scale_bars(d.Male_Percentage); })
.attr("y", function(d) { return y_pyramid_compare(d.Age_group); })
.attr("width", function(d) { return compare_pyramid_scale_bars(d.Male_Percentage); })
.attr("height", y_pyramid_compare.bandwidth())
.attr("fill", "#ff6600")
.on("mousemove", showTooltip_p1_male)
.on('mouseout', mouseleave_p1)

svg_pyramid_1
    .append('g')
    .append("path")
    .datum(data_lines)
    .attr("d", d3.line()
    .x(function (d) { return male_zero - compare_pyramid_scale_bars(d.Male_Percentage) })
    .y(function(d) { return y_pyramid_compare(d.Age_group) + 10; }))
    .attr("stroke", '#993d00')
    .style("stroke-width", 3)
    .style("fill", "none");

var max90_compare_b = data_bars.filter(function(d,i){
  return d.Age_group === '90+ years' })

var max90_compare_l = data_lines.filter(function(d,i){
  return d.Age_group === '90+ years' })

var max90_position_compare = Math.max(
    d3.max(max90_compare_b, function(d) { return d.Female_Percentage; }),
    d3.max(max90_compare_b, function(d) { return d.Male_Percentage; }),
    d3.max(max90_compare_l, function(d) { return d.Female_Percentage; }),
    d3.max(max90_compare_l, function(d) { return d.Male_Percentage; })
  );

svg_pyramid_1
.append("text")
.attr("text-anchor", "end")
.attr("y", 15)
.attr("x", function(d) { return male_zero - compare_pyramid_scale_bars(max90_position_compare) - 10; })
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('Males');

svg_pyramid_1
.append("text")
.attr("text-anchor", "start")
.attr("y", 15)
.attr("x", function(d) { return female_zero + compare_pyramid_scale_bars(max90_position_compare) + 10; })
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('Females');


}



// Initialize the plot with the first dataset
update_p1(data)

  d3.select("#selectArea1P1Button").on("change", function(d) {
  var selectedArea1P1Option = d3.select('#selectArea1P1Button').property("value")
  var selectedArea2P1Option = d3.select('#selectArea2P1Button').property("value")
  update_p1(data)
  })

  d3.select("#selectArea2P1Button").on("change", function(d) {
  var selectedArea1P1Option = d3.select('#selectArea1P1Button').property("value")
  var selectedArea2P1Option = d3.select('#selectArea2P1Button').property("value")
  update_p1(data)
  })
