
// var width = window.innerWidth / 100 * 50;
var width = document.getElementById("content_size").offsetWidth - 60;

var height_pyramid = 500;

var age_levels = ["0-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years", "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years", "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years", "75-79 years", "80-84 years", "85-89 years", "90+ years"]

// margins
var margin = {top: 30,
              right: 30,
              bottom: 100,
              left: 30};


// Population pyramid
var request = new XMLHttpRequest();
    request.open("GET", "./wsx_2018_pop.json", false);
    request.send(null);

var wsx_pyramid = JSON.parse(request.responseText); // parse the fetched json data into a variable

wsx_pyramid.sort(function(a,b) {
    return age_levels.indexOf( a.Age) > age_levels.indexOf( b.Age)});

// append the svg object to the body of the page
var svg_wsx_pyramid = d3.select("#pyramid_wsx_datavis")
.append("svg")
.attr("width", width + margin.left + margin.right)
.attr("height", height_pyramid + margin.top + 75)
.append("g")
.attr("transform", "translate(" + margin.left + "," + margin.top + ")");


var showTooltip_p1_male = function(d, i) {

tooltip_static_pyramid_male
  .html("<h2>" + d.Age + '</h2><p class = "side">The estimated number of males aged ' + d.Age + ' living in West Sussex in 2018 was ' + d3.format(",.0f")(d['Males (MYE)']) + '. This is ' + d3.format('.1%')(d.Percentage_male_res) + ' of the population of males in West Sussex.</p><p class = "side">The number of male patients aged ' + d.Age + ' registered to GP practices in West Sussex in July 2018 was ' + d3.format(',.0f')(d['Males (GP register)']) + '. This is ' +  d3.format('.1%')(d.Percentage_male_reg) + ' of the population of males registered to GP practices in West Sussex.</p>')
  .style("opacity", 1)
  .style("top", (event.pageY - 10) + "px")
  .style("left", (event.pageX + 10) + "px")
  .style("visibility", "visible")
        }
//
var showTooltip_p1_female = function(d, i) {

tooltip_static_pyramid_female
  .html("<h2>" + d.Age + '</h2><p class = "side">The estimated number of females aged ' + d.Age + ' living in West Sussex in 2018 was ' + d3.format(",.0f")(d['Females (MYE)']) + '. This is ' + d3.format('.1%')(d.Percentage_female_res) + ' of the population of females in West Sussex.</p><p class = "side">The number of female patients aged ' + d.Age + ' registered to GP practices in West Sussex in July 2018 was ' + d3.format(',.0f')(d['Females (GP register)']) + '. This is ' +  d3.format('.1%')(d.Percentage_female_reg) + ' of the population of females registered to GP practices in West Sussex.</p>')
  .style("opacity", 1)
  .style("top", (event.pageY - 10) + "px")
  .style("left", (event.pageX + 10) + "px")
  .style("visibility", "visible")
        }

var mouseleave_static_pyr = function(d) {

tooltip_static_pyramid_male
.style("visibility", "hidden")
tooltip_static_pyramid_female
.style("visibility", "hidden")
            }
// find the maximum data value on either side
 var maxPopulation_static_pyr = Math.max(
   d3.max(wsx_pyramid, function(d) { return d['Males (GP register)']; }),
   d3.max(wsx_pyramid, function(d) { return d['Females (GP register)']; }),
  d3.max(wsx_pyramid, function(d) { return d['Males (MYE)']; }),
  d3.max(wsx_pyramid, function(d) { return d['Females (MYE)']; })
 );

// These functions and variables will become universal so only need to be declared once (eventually) for the three pyramids
margin.middle = 80;

// plotting region for each pyramid and Where should the pyramids start (males on the left)
var pyramid_plot_width = (width/2) - (margin.middle/2) ;
var male_zero = pyramid_plot_width
var female_zero = width - pyramid_plot_width

// the scale goes from 0 to the width of the pyramid plotting region. We will invert this for the left x-axis
var x_static_pyramid_scale_male = d3.scaleLinear()
  .domain([0, maxPopulation_static_pyr])
  .range([male_zero, 0]);
//
var xAxis_static_pyramid = svg_wsx_pyramid
  .append("g")
  .attr("transform", "translate(0," + height_pyramid + ")")
  .call(d3.axisBottom(x_static_pyramid_scale_male));

var x_static_pyramid_scale_female = d3.scaleLinear()
  .domain([0, maxPopulation_static_pyr])
  .range([female_zero, width]);

var xAxis_static_pyramid_2 = svg_wsx_pyramid
  .append("g")
  .attr("transform", "translate(0," + height_pyramid + ")")
  .call(d3.axisBottom(x_static_pyramid_scale_female));

var wsx_pyramid_scale_bars = d3.scaleLinear()
  .domain([0,maxPopulation_static_pyr])
  .range([0, pyramid_plot_width]);

var tooltip_static_pyramid_male = d3.select("#pyramid_wsx_datavis")
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

var tooltip_static_pyramid_female = d3.select("#pyramid_wsx_datavis")
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

// // Y axis scale
var y_pyramid_wsx = d3.scaleBand()
.domain(age_levels)
.range([height_pyramid, 0])
.padding([0.2]);
//
yaxis_pos = female_zero - (margin.middle / 2)
//
var yAxis_static_pyramid = svg_wsx_pyramid
.append("g")
.attr("transform", "translate(0" + yaxis_pos + ",0)")
.call(d3.axisLeft(y_pyramid_wsx).tickSize(0))
.style('text-anchor', 'middle')
.select(".domain").remove()

 svg_wsx_pyramid
  .selectAll("myRect")
  .data(wsx_pyramid)
  .enter()
  .append("rect")
  .attr("x", female_zero)
  .attr("y", function(d) { return y_pyramid_wsx(d.Age); })
  .attr("width", function(d) { return wsx_pyramid_scale_bars(d['Females (MYE)']); })
  .attr("height", y_pyramid_wsx.bandwidth())
  .attr("fill", "#0099ff")
  .on("mousemove", showTooltip_p1_female)
  .on('mouseout', mouseleave_static_pyr)

svg_wsx_pyramid
    .append('g')
    .append("path")
    .datum(wsx_pyramid)
    .attr("d", d3.line()
    .x(function (d) { return wsx_pyramid_scale_bars(d['Females (GP register)']) + female_zero })
    .y(function(d) { return y_pyramid_wsx(d.Age) + 10; }))
    // .curve(d3.curveStepAfter)
    .attr("stroke", '#005b99')
    .style("stroke-width", 3)
    .style("fill", "none");

svg_wsx_pyramid
.selectAll("myRect")
.data(wsx_pyramid)
.enter()
.append("rect")
.attr("x", function(d) { return male_zero - wsx_pyramid_scale_bars(d['Males (MYE)']); })
.attr("y", function(d) { return y_pyramid_wsx(d.Age); })
.attr("width", function(d) { return wsx_pyramid_scale_bars(d['Males (MYE)']); })
.attr("height", y_pyramid_wsx.bandwidth())
.attr("fill", "#ff6600")
.on("mousemove", showTooltip_p1_male)
.on('mouseout', mouseleave_static_pyr)

svg_wsx_pyramid
    .append('g')
    .append("path")
    .datum(wsx_pyramid)
    .attr("d", d3.line()
    .x(function (d) { return male_zero - wsx_pyramid_scale_bars(d['Males (GP register)']) })
    .y(function(d) { return y_pyramid_wsx(d.Age) + 10; }))
    // .curve(d3.curveStep))
    .attr("stroke", '#993d00')
    .style("stroke-width", 3)
    .style("fill", "none");

var max90_wsx = wsx_pyramid.filter(function(d,i){
  return d.Age === '90+ years' })

var max90_position_wsx = Math.max(
    d3.max(max90_wsx, function(d) { return d['Males (MYE)']; }),
    d3.max(max90_wsx, function(d) { return d['Females (MYE)']; }),
    d3.max(max90_wsx, function(d) { return d['Males (GP register)']; }),
    d3.max(max90_wsx, function(d) { return d['Females (GP register)']; })
  );

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "end")
.attr("y", 15)
.attr("x", function(d) { return male_zero - wsx_pyramid_scale_bars(max90_position_wsx) - 10; })
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('Males');

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "start")
.attr("y", 15)
.attr("x", function(d) { return female_zero + wsx_pyramid_scale_bars(max90_position_wsx) + 10; })
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('Females');

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "start")
.attr("x", 5)
.attr("y", function(d) { return y_pyramid_wsx('25-29 years')})
.attr('opacity', 1)
.text('There are more');

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "start")
.attr("x", 5)
.attr("y", function(d) { return y_pyramid_wsx('25-29 years') + 15})
.attr('opacity', 1)
.text('15-44 year old');

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "start")
.attr("x", 5)
.attr("y", function(d) { return y_pyramid_wsx('25-29 years') + 30})
.attr('opacity', 1)
.text('males registered');

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "start")
.attr("x", 5)
.attr("y", function(d) { return y_pyramid_wsx('25-29 years') + 45})
.attr('opacity', 1)
.text('to GPs than living');

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "start")
.attr("x", 5)
.attr("y", function(d) { return y_pyramid_wsx('25-29 years') + 60})
.attr('opacity', 1)
.text('in West Sussex');

svg_wsx_pyramid
.append("text")
.attr("text-anchor", "start")
.attr('class', 'year_pyramid')
.style('fill', 'Red')
.attr("y", 35)
.attr("x", width - 60)
.attr('opacity', 1)
.style('font-weight', 'bold')
.text('2018');
