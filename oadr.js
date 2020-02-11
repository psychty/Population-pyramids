// var width = window.innerWidth / 100 * 50;
var width_oadr = document.getElementById("content_size").offsetWidth;
var height_oadr = 350;

var svg_oadr = d3.select("#oadr_ts_viz")
.append("svg")
.attr("width", width_oadr)
.attr("height", height_oadr)
.append("g")
.attr("transform", "translate(" + 30 + "," + 30 + ")");

var estimate_key = d3.scaleOrdinal()
  .domain(['Mid year estimate', 'Projection'])
  .range(['#460061', '#966fa6'])

var estimate_key_eng = d3.scaleOrdinal()
  .domain(['Mid year estimate', 'Projection'])
  .range(['#666666', '#9f9f9f'])

// OADR data
var request = new XMLHttpRequest();
    request.open("GET", "./area_oadr_df.json", false);
    request.send(null);

var json_oadr = JSON.parse(request.responseText); // parse the fetched json data into a variable

// List of years in the dataset
var areas_oadr = d3.map(json_oadr, function (d) {
  return (d.Area)
  })
  .keys()

// List of years in the dataset
var years_oadr = d3.map(json_oadr, function (d) {
  return (d.Year)
  })
  .keys()

// We need to create a dropdown button for the user to choose which area to be displayed on the figure.
d3.select("#select_oadr_area_button")
  .selectAll('myOptions')
  .data(areas_oadr)
  .enter()
  .append('option')
  .text(function (d) {
        return d; }) // text to appear in the menu - this does not have to be as it is in the data (you can concatenate other values).
  .attr("value", function (d) {
        return d; }) // corresponding value returned by the button

var selected_oadr_area_option = d3.select('#select_oadr_area_button').property("value")

oadr_chosen = json_oadr.filter(function (d) { // gets a subset of the json data - This time it excludes SE and England values
    return d.Area === selected_oadr_area_option
})
    .sort(function (a, b) {
        return d3.ascending(a.Year, b.Year);
    });

var x_oadr = d3.scaleLinear()
.domain(d3.extent(oadr_chosen, function(d) { return d.Year; }))
.range([0, width_oadr - 60]);

var xAxis_oadr = svg_oadr
.append("g")
.attr("transform", "translate(0," + 290 + ")")

xAxis_oadr
.call(d3.axisBottom(x_oadr).ticks(years_oadr.length, '0f'))

// Rotate the xAxis labels
xAxis_oadr
.selectAll("text")
.attr("transform", "rotate(-45)")
.style("text-anchor", "end")

var maxOADR = Math.max(
  d3.max(json_oadr, function(d) { return d.OADR + 50; })
);

// Add Y axis
var y_oadr = d3.scaleLinear()
.domain([0, 750]) // Add the ceiling
.range([290, 0]);

var yAxis_oadr = svg_oadr
.append("g")
.call(d3.axisLeft(y_oadr).ticks(20));

var tooltip_oadr = d3.select("#oadr_ts_viz")
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

var showTooltip_OADR = function(d) {

tooltip_oadr
  .html("<h3>" + d.Area + ' - ' + d.Year + '</h3><p class = "side"><font color = "#1e4b7a"><b>' + d3.format(',.0f')(d.OADR) + '</font></b> state pension age population per 1,000 working age population.</p><p class = "side"><font color = "#1e4b7a"><b>' + d3.format(',.0f')(d.Number_SPA) + '</font></b> estimated state pension age population</p><p class = "side"><font color = "#1e4b7a"><b>'  +  d3.format(',.0f')(d.Number_Workers) + '</font></b> estimated working age (16-SPA) population.</p>')
  .style("opacity", 1)
  .style("top", (event.pageY - 10) + "px")
  .style("left", (event.pageX + 10) + "px")
  .style("visibility", "visible")
        }

var mouseleave_oadr = function(d) {

tooltip_oadr
.style("visibility", "hidden")
    }

var lines_oadr = svg_oadr
    .append('g')
    .append("path")
    .datum(json_oadr.filter(function (d) {
        return d.Area === selected_oadr_area_option
    }))
    .attr("d", d3.line()
        .x(function (d) {
            return x_oadr(d.Year)
        })
        .y(function (d) {
            return y_oadr(+d.OADR)
        }))
    .attr("stroke", function (d) {
        return estimate_key(d.Estimate)
    })
    .style("stroke-width", 2)
    .style("fill", "none");

var dots_oadr = svg_oadr
  .selectAll('myCircles')
  .data(json_oadr.filter(function (d) {
      return d.Area === selected_oadr_area_option
    }))
  .enter()
  .append("circle")
  .attr("cx", function(d) { return x_oadr(d.Year) } )
  .attr("cy", function(d) { return y_oadr(+d.OADR) } )
  .attr("r", 6)
  .style("fill", function(d){ return estimate_key(d.Estimate)})
  .attr("stroke", "white")
  .on("mousemove", showTooltip_OADR)
  .on('mouseout', mouseleave_oadr);

  var lines_oadr_eng = svg_oadr
      .append('g')
      .append("path")
      .datum(json_oadr.filter(function (d) {
          return d.Area === 'England'
      }))
      .attr("d", d3.line()
          .x(function (d) {
              return x_oadr(d.Year)
          })
          .y(function (d) {
              return y_oadr(+d.OADR)
          }))
      .attr("stroke", '#dbdbdb')
      .style("stroke-width", 2)
      .style("fill", "none");

      var dots_oadr_eng = svg_oadr
        .selectAll('myCircles')
        .data(json_oadr.filter(function (d) {
            return d.Area === 'England'
          }))
        .enter()
        .append("circle")
        .attr("cx", function(d) { return x_oadr(d.Year) } )
        .attr("cy", function(d) { return y_oadr(+d.OADR) } )
        .attr("r", 6)
        .style("fill", function(d){ return estimate_key_eng(d.Estimate)})
        .attr("stroke", "white")
        .on("mousemove", showTooltip_OADR)
        .on('mouseout', mouseleave_oadr);

eng_41 = json_oadr.filter(function (d) {
        return d.Area === 'England' &
               d.Year === 2041})

svg_oadr
.append("text")
.attr("text-anchor", "start")
.attr("y", y_oadr(65))
.attr("x", x_oadr('2011'))
.attr('opacity', 1)
.attr('class', 'pop_65_text')
.text('Data for 2010 to 2018');

svg_oadr
.append("text")
.attr("text-anchor", "start")
.attr("y", y_oadr(40))
.attr("x", x_oadr('2011'))
.attr('opacity', 1)
.attr('class', 'pop_65_text')
.text('are based on ONS estimates.');

svg_oadr
.append("text")
.attr("text-anchor", "end")
.attr("y", y_oadr(eng_41[0]['OADR'] - 65))
.attr("x", x_oadr('2041'))
.attr('opacity', 1)
.text('England');

chosen_41 = json_oadr.filter(function (d) {
        return d.Area === selected_oadr_area_option &
               d.Year === 2041})

svg_oadr
.append("text")
.attr("text-anchor", "end")
.attr('id', 'area_x_oadr_label')
.attr("y", y_oadr(chosen_41[0]['OADR'] + 50))
.attr("x", x_oadr('2041'))
.attr('opacity', 1)
.text(selected_oadr_area_option);

function update_oadr(selected_oadr_area_option) {

svg_oadr
.selectAll("#area_x_oadr_label")
.transition()
.duration(750)
.attr('opacity', 0)
.remove();


var selected_oadr_area_option = d3.select('#select_oadr_area_button').property("value")

oadr_chosen = json_oadr.filter(function (d) {
    return d.Area === selected_oadr_area_option
})
    .sort(function (a, b) {
        return d3.ascending(a.Year, b.Year);
    });

lines_oadr
.datum(oadr_chosen)
.transition()
.duration(1000)
.attr("d", d3.line()
.x(function (d) {
  return x_oadr(d.Year)
  })
.y(function (d) {
  return y_oadr(+d.OADR)
  }))
.attr("stroke", function (d) {
  return estimate_key(d.Estimate)
  })

dots_oadr
.data(oadr_chosen)
.transition()
.duration(1000)
.attr("cx", function(d) { return x_oadr(d.Year) } )
.attr("cy", function(d) { return y_oadr(+d.OADR) } )
.attr("r", 6)
.style("fill", function(d){ return estimate_key(d.Estimate)})
.attr("stroke", "white")

chosen_41 = json_oadr.filter(function (d) {
        return d.Area === selected_oadr_area_option &
               d.Year === 2041})

setTimeout(function(){
svg_oadr
.append("text")
.attr("text-anchor", "end")
.attr('id', 'area_x_oadr_label')
.attr("y", function(d) {
  if (chosen_41[0]['OADR'] < eng_41[0]['OADR']) {
    return y_oadr(chosen_41[0]['OADR'] - 65) }
    else {
    return y_oadr(chosen_41[0]['OADR'] + 50) }
          })
.attr("x", x_oadr('2041'))
.attr('opacity', 0)
.transition()
.duration(1000)
.attr('opacity', 1)
.text(selected_oadr_area_option);
}, 500);

}

d3.select("#select_oadr_area_button").on("change", function (d) {
var selected_oadr_area_option = d3.select('#select_oadr_area_button').property("value")
    update_oadr(selected_oadr_area_option)
})
