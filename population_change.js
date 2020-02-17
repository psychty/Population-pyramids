
// var width = window.innerWidth / 100 * 50;
var width = document.getElementById("content_size").offsetWidth - 60;

var height_pyramid = 500;

var age_levels = ["0-4 years", "5-9 years", "10-14 years", "15-19 years", "20-24 years", "25-29 years", "30-34 years", "35-39 years", "40-44 years", "45-49 years", "50-54 years", "55-59 years", "60-64 years", "65-69 years", "70-74 years", "75-79 years", "80-84 years", "85-89 years", "90+ years"]

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
      return d.Area === 'West Sussex'})

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

d3.select("#wsx_intro_string_1")
    .data(wsx_coc)
    .text(function(d) {
        return 'In 2018 ' + d3.format(',.4r')(d.population) + ' people were estimated to be resident in ' + d.Area + '. There were ' + d3.format(',.0f')(d.births) + ' births and ' + d3.format(',.0f')(d.deaths) + ' deaths and net internal migration (from/to elsewhere in the UK) was ' + d3.format(',.0f')(d.internal_net) + ' (' + d3.format(',.0f')(d.internal_out) + ' people moving out and ' + d3.format(',.0f')(d.internal_in) + ' people moving in). Net international migration in ' + d.Area + ', in 2018 was ' + d3.format(',.0f')(d.international_net) + ' (' + d3.format(',.0f')(d.international_out) + ' people moving out and ' + d3.format(',.0f')(d.international_in) + ' people moving in).'});

d3.select("#wsx_intro_string_2")
    .data(wsx_coc)
    .text(function(d) {
        return 'The total population in 2017 was ' + d3.format(',.4r')(d.population - d.pop_change) + ' which means between 2017 and 2018 the overall population increased by ' + d3.format(',.3r')(d.pop_change) + ', an increase of approximately ' + d3.format('0.1f')(d.pop_change / (d.population - d.pop_change) * 100) + '%. The population increase resulted largely from ' + change_switch_key(top_cause_change) + '.'});

// Population 2018 data
var request = new XMLHttpRequest();
    request.open("GET", "./wsx_2018_pop.json", false);
    request.send(null);

var pop_2018 = JSON.parse(request.responseText); // parse the fetched json data into a variable

pop_2018.sort(function(a,b) {
    return age_levels.indexOf( a.Age) > age_levels.indexOf( b.Age);
});

// GET THE TOTAL POPULATION SIZE AND CREATE A FUNCTION FOR RETURNING THE PERCENTAGE
var total_GP_pop = d3.sum(pop_2018, function(d) { return d['Total (GP register)']; });
var total_MYE_pop = d3.sum(pop_2018, function(d) { return d['Total (MYE)']; });

d3.select('#wsx_gp_2018_string')
  .data(pop_2018)
  .text(function(d) {
    return 'At the time of the latest mid year estimate, there were ' + d3.format(',.0f')(total_GP_pop) + ' patients registered to GP practices in West Sussex. This means around ' + d3.format(',.2r')(total_GP_pop - total_MYE_pop) + ' more people were registered to primary care services than were estimated to be living in the county. This has implications for planning some services which are provided in primary care (such as NHS Health Checks and NHS Stop Smoking Services). Some residents outside of the county may be registered to practices in the county, and some residents of West Sussex may use services outside of the county, perhaps choosing to use services near places of work. Limited data on where GP practice patients reside are available publically and will be explored in more detail in the section "primary care populations" below'});

///////////////////
// Top ten table //
///////////////////

// Create a function for tabulating the data
function tabulate_pop(data, columns) {
var table = d3.select('#population_18_table')
    .append('table')
var thead = table
    .append('thead')
var tbody = table
    .append('tbody');

// append the header row
thead
.append('tr')
.selectAll('th')
.data(columns).enter()
.append('th')
.text(function (column) {
      return column;
          });

// create a row for each object in the data
var rows = tbody.selectAll('tr')
  .data(data)
  .enter()
  .append('tr');

// create a cell in each row for each column
var cells = rows.selectAll('td')
  .data(function (row) {
    return columns.map(function (column) {
    return {column: column, value: row[column]};
      });
      })
  .enter()
  .append('td')
  .text(function(d,i) {
    if(i >= 1) return d3.format(",.0f")(d.value);
               return d.value; })
    return table;
    }

var topTable = tabulate_pop(pop_2018, ['Age', 'Total (MYE)', 'Total (GP register)', 'Females (MYE)', 'Females (GP register)', 'Males (MYE)', 'Males (GP register)']);

// components of change districts in wsx

// Population 2018 data
var request = new XMLHttpRequest();
    request.open("GET", "./area_components_of_change_df.json", false);
    request.send(null);

var coc_2018 = JSON.parse(request.responseText);

// .sort(function(a,b) {
    // return age_levels.indexOf( a.Age_group) > age_levels.indexOf( b.Age_group );
// });

// Create a function for tabulating the data
function tabulate_coc(data, columns) {
var table = d3.select('#population_coc_18_table')
    .append('table')
var thead = table
    .append('thead')
var tbody = table
    .append('tbody');

// append the header row
thead
.append('tr')
.selectAll('th')
.data(columns).enter()
.append('th')
.text(function (column) {
      return column;
          });

// create a row for each object in the data
var rows = tbody.selectAll('tr')
  .data(data)
  .enter()
  .append('tr');

// create a cell in each row for each column
var cells = rows.selectAll('td')
  .data(function (row) {
    return columns.map(function (column) {
    return {column: column, value: row[column]};
      });
      })
  .enter()
  .append('td')
  .text(function(d) {
       return d.value;})
    return table;
    }

var topTable = tabulate_coc(coc_2018, ["Area", "Births per 1,000 population", "Deaths per 1,000 population", "Internal in per 1,000 population", "Internal out per 1,000 population","International in per 1,000 population", "International out per 1,000 population", "Population in 2018" ,"Population change since 2017", "2018 people per sq. km", "Median age (2018)"]);


// Population change 2018 2028 2038 data
var request = new XMLHttpRequest();
    request.open("GET", "./area_change_over_time_df.json", false);
    request.send(null);

var cot_20182838 = JSON.parse(request.responseText);

// Create a function for tabulating the data
function tabulate_cot(data, columns) {
var table = d3.select('#population_18_28_38_table')
    .append('table')
var thead = table
    .append('thead')
var tbody = table
    .append('tbody');

// append the header row
thead
.append('tr')
.selectAll('th')
.data(columns).enter()
.append('th')
.text(function (column) {
      return column;
          });

// create a row for each object in the data
var rows = tbody.selectAll('tr')
  .data(data)
  .enter()
  .append('tr');

// create a cell in each row for each column
var cells = rows.selectAll('td')
  .data(function (row) {
    return columns.map(function (column) {
    return {column: column, value: row[column]};
      });
      })
  .enter()
  .append('td')
  .text(function(d) {
       return d.value;})
    return table;
    }

var topTable = tabulate_cot(cot_20182838, ["Area", "2018", "2028", "Change 2018-2028", "2038", "Change 2018-2038"]);

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


// Median age data
var request = new XMLHttpRequest();
    request.open("GET", "./area_median_age_df.json", false);
    request.send(null);

var median_age = JSON.parse(request.responseText);

// Create a function for tabulating the data
function tabulate_median(data, columns) {
var table = d3.select('#population_median_age_table')
    .append('table')
var thead = table
    .append('thead')
var tbody = table
    .append('tbody');

// append the header row
thead
.append('tr')
.selectAll('th')
.data(columns).enter()
.append('th')
.text(function (column) {
      return column;
          });

// create a row for each object in the data
var rows = tbody.selectAll('tr')
  .data(data)
  .enter()
  .append('tr');

// create a cell in each row for each column
var cells = rows.selectAll('td')
  .data(function (row) {
    return columns.map(function (column) {
    return {column: column, value: row[column]};
      });
      })
  .enter()
  .append('td')
  .text(function(d) {
       return d.value;})
    return table;
    }

var topTable = tabulate_median(median_age, ["Area", "Median age (2003)", "Median age (2008)", "Median age (2013)", "Median age (2018)"]);
