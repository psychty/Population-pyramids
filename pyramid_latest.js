

// Population pyramid
var request = new XMLHttpRequest();
    request.open("GET", "./area_population_quinary_df_v2.json", false);
    request.send(null);

var json_pyramid = JSON.parse(request.responseText); // parse the fetched json data into a variable

// List of years in the dataset
var years_pyramid_1 = d3.map(json_pyramid, function (d) {
     return (d.Year)
     })
   .keys()

// We need to create a dropdown button for the user to choose which area to be displayed on the figure.
d3.select("#selectYearsP1Button")
    .selectAll('myOptions')
    .data(years_pyramid_1)
    .enter()
    .append('option')
    .text(function (d) {
        return d; }) // text to appear in the menu - this does not have to be as it is in the data (you can concatenate other values).
    .attr("value", function (d) {
        return d; }) // corresponding value returned by the button

var selectedYearP1Option = d3.select('#selectYearsP1Button').property("value")

// List of years in the dataset
var areas_pyramid_1 = d3.map(json_pyramid, function (d) {
   return (d.Area_Name)
   })
   .keys()

// We need to create a dropdown button for the user to choose which area to be displayed on the figure.
d3.select("#selectAreasP1Button")
  .selectAll('myOptions')
  .data(['West Sussex','Adur','Arun','Chichester','Crawley','Horsham','Mid Sussex','Worthing','South East','England'])
  .enter()
  .append('option')
  .text(function (d) {
        return d; }) // text to appear in the menu - this does not have to be as it is in the data (you can concatenate other values).
  .attr("value", function (d) {
        return d; }) // corresponding value returned by the button

var selectedAreaP1Option = d3.select('#selectAreasP1Button').property("value")

// append the svg object to the body of the page
var svg_pyramid_1 = d3.select("#pyramid_1_datavis")
.append("svg")
.attr("width", width + margin.left + margin.right)
.attr("height", height_pyramid + margin.top + 75)
.append("g")
.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var data = json_pyramid.filter(function(d){
    return d.Year === selectedYearP1Option &
           d.Area_Name === selectedAreaP1Option})

var data_all_years = json_pyramid.filter(function(d){
   return d.Area_Name === selectedAreaP1Option})

function update_p1(data) {

var selectedYearP1Option = d3.select('#selectYearsP1Button').property("value")
var selectedAreaP1Option = d3.select('#selectAreasP1Button').property("value")

// This selects the text on the figure and removes it imediately
svg_pyramid_1
 .selectAll("text")
 .remove();

// This selects the whole div, changes the r value for all circles to 0 and then removes the svg before new plots are rebuilt.
svg_pyramid_1
 .selectAll("*")
 .transition()
 .duration(750)
 .attr("r", 0)
 .remove();

svg_pyramid_1
 .selectAll("*")
 .remove();

var data = json_pyramid.filter(function(d){
    return d.Year === selectedYearP1Option &
           d.Area_Name === selectedAreaP1Option})

var data_all_years = json_pyramid.filter(function(d){
    return d.Area_Name === selectedAreaP1Option})

var showTooltip_p1_male = function(d, i) {

tooltip_pyramid_1_male
  .html("<h2>" + d.Age_group + '</h2><p class = "side">The estimated number of males aged ' + d.Age_group + ' in ' + d.Year + ' was ' + d3.format(",.0f")(d.Male_Population) + '. This is ' + d3.format('.1%')(d.Male_Percentage) + ' of the population of males in ' + d.Area_Name + '.</p><p class = "side">The total population in ' + d.Area_Name + ' in ' + d.Year + ' is ' + d3.format(',.0f')(totalPopulation) + '</p>')
  .style("opacity", 1)
  .style("top", (event.pageY - 10) + "px")
  .style("left", (event.pageX + 10) + "px")
  .style("visibility", "visible")
        }

var showTooltip_p1_female = function(d, i) {

tooltip_pyramid_1_female
  .html("<h2>" + d.Age_group + '</h2><p class = "side">The estimated number of females aged ' + d.Age_group + ' in ' + d.Year + ' was ' + d3.format(",.0f")(d.Female_Population) + '. This is ' + d3.format('.1%')(d.Female_Percentage) + ' of the population of females in ' + d.Area_Name + '.</p><p class = "side">The total population in ' + d.Area_Name + ' in ' + d.Year + ' is ' + d3.format(',.0f')(totalPopulation) + '</p>')
  .style("opacity", 1)
  .style("top", (event.pageY - 10) + "px")
  .style("left", (event.pageX + 10) + "px")
  .style("visibility", "visible")
        }

var mouseleave_p1 = function(d) {

tooltip_pyramid_1_male
.style("visibility", "hidden")
tooltip_pyramid_1_female
.style("visibility", "hidden")
            }

tokeep = ["65-69 years", "70-74 years", "75-79 years", "80-84 years", "85-89 years", "90+ years"]

over_65_data = data.filter(function(d,i){
  return tokeep.indexOf(d.Age_group) >= 0 })

var total65plusPop = d3.sum(over_65_data, function(d) { return d.Female_Population + d.Male_Population; });

var totalPopulation = d3.sum(data, function(d) { return d.Female_Population + d.Male_Population; });

// find the maximum data value on either side
var maxPopulation = Math.max(
  d3.max(data_all_years, function(d) { return d.Male_Population; }),
  d3.max(data_all_years, function(d) { return d.Female_Population; })
);

// space for y axis
margin.middle = 80;

// plotting region for each pyramid and Where should the pyramids start (males on the left)
var pyramid_plot_width = (width/2) - (margin.middle/2) ;
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

var tooltip_pyramid_1_male = d3.select("#pyramid_1_datavis")
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

var tooltip_pyramid_1_female = d3.select("#pyramid_1_datavis")
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

// .tickFormat(d3.format('.0%'))
// ages = data.map(function(d) { return d.Age_group; })

// Y axis scale
var y_pyramid_1 = d3.scaleBand()
.domain(age_levels)
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
.data(data)
.enter()
.append("rect")
.attr("x", female_zero)
.attr("y", function(d) { return y_pyramid_1(d.Age_group); })
.attr("width", function(d) { return pyramid_scale_bars(d.Female_Population); })
.attr("height", y_pyramid_1.bandwidth())
.attr("fill", "#0099ff")
.on("mousemove", showTooltip_p1_female)
.on('mouseout', mouseleave_p1)

svg_pyramid_1
.selectAll("myRect")
.data(data)
.enter()
.append("rect")
.attr("x", function(d) { return male_zero - pyramid_scale_bars(d.Male_Population); })
.attr("y", function(d) { return y_pyramid_1(d.Age_group); })
.attr("width", function(d) { return pyramid_scale_bars(d.Male_Population); })
.attr("height", y_pyramid_1.bandwidth())
.attr("fill", "#ff6600")
.on("mousemove", showTooltip_p1_male)
.on('mouseout', mouseleave_p1)

svg_pyramid_1
.append("text")
.attr("text-anchor", "start")
.attr("y", 0)
.attr("x", -10)
.attr('opacity', 0)
.transition()
.duration(2000)
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('Population age 65+');

var max90 = data.filter(function(d,i){
  return d.Age_group === '90+ years' })

var max90_position = Math.max(
    d3.max(max90, function(d) { return d.Male_Population; }),
    d3.max(max90, function(d) { return d.Female_Population; })
  );

svg_pyramid_1
.append("text")
.attr("text-anchor", "end")
.attr("y", 15)
.attr("x", function(d) { return male_zero - pyramid_scale_bars(max90_position) - 10; })
.attr('opacity', 0)
.transition()
.duration(2000)
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('Males');

svg_pyramid_1
.append("text")
.attr("text-anchor", "start")
.attr("y", 15)
.attr("x", function(d) { return female_zero + pyramid_scale_bars(max90_position) + 10; })
.attr('opacity', 0)
.transition()
.duration(2000)
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('Females');

svg_pyramid_1
.append("text")
.attr("text-anchor", "start")
.attr('class', 'year_pyramid')
.style('fill', 'Red')
.attr("y", 35)
.attr("x", width - 60)
.attr('opacity', 0)
.transition()
.duration(2000)
.attr('opacity', 1)
.style('font-weight', 'bold')
.text(selectedYearP1Option);

svg_pyramid_1
.append("text")
.attr("text-anchor", "start")
.attr('class', 'pop_65_class')
.style('fill', 'Red')
.style('font-weight', 'bold')
.attr("y", 35)
.attr("x", -10)
.attr('opacity', 0)
.transition()
.duration(2000)
.attr('opacity', 1)
.text(d3.format(',.4r')(total65plusPop));

svg_pyramid_1
.append("text")
.attr("text-anchor", "start")
.attr('class', 'pop_65_text')
.attr("y", 50)
.attr("x", -10)
.attr('opacity', 0)
.transition()
.duration(2000)
.attr('opacity', 1)
.text('This is ' + d3.format('.1%')(total65plusPop / totalPopulation) + ' of the');

svg_pyramid_1
.append("text")
.attr("text-anchor", "start")
.attr('class', 'pop_65_text')
.attr("y", 65)
.attr("x", -10)
.attr('opacity', 0)
.transition()
.duration(2000)
.attr('opacity', 1)
.text('total population (' + d3.format(',.4r')(totalPopulation) +').');

// Select the div id total_death_string (this is where you want the result of this to be displayed in the html page)
d3.select("#selected_p1_title")
  	.data(data)
  	.text(function(d){
  	return "Population pyramid; " + selectedAreaP1Option + '; ' + selectedYearP1Option + ';' });

}

// Initialize the plot with the first dataset
update_p1(data)

  d3.select("#selectAreasP1Button").on("change", function(d) {
    var selectedYearP1Option = d3.select('#selectYearsP1Button').property("value")
    var selectedAreaP1Option = d3.select('#selectAreasP1Button').property("value")
  update_p1(data)
  })

  d3.select("#selectYearsP1Button").on("change", function(d) {
    var selectedYearP1Option = d3.select('#selectYearsP1Button').property("value")
    var selectedAreaP1Option = d3.select('#selectAreasP1Button').property("value")
  update_p1(data)
  })
