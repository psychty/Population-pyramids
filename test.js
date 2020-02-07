

// http://jsfiddle.net/u3tjmy0b/4/

//create svg element
var out_of_svg = d3.select("#info_graphi")
.append("svg")
.attr('class', 'svg_info')
.attr('height', 80)
.attr('width', 250)
// .attr("viewBox", "0 0 100 100");

// Define the gradient
var gradient = out_of_svg.append("svg:defs")
.append("svg:linearGradient")
.attr("id", "gradient")
.attr("y1", "100%")
.attr("y2", "0%")
.attr("spreadMethod", "pad");

// Define the gradient colors
gradient
.append("svg:stop")
.attr("offset", "0%")
.attr("stop-color", "orange")
.attr("stop-opacity", 1);

//define an icon store it in svg <defs> elements as a reusable component - this geometry can be generated from Inkscape, Illustrator or similar
out_of_svg
.append("defs")
.append("g")
.attr("id", "iconCustom")
.append("path")
.attr("d", "M3.5,2H2.7C3,1.8,3.3,1.5,3.3,1.1c0-0.6-0.4-1-1-1c-0.6,0-1,0.4-1,1c0,0.4,0.2,0.7,0.6,0.9H1.1C0.7,2,0.4,2.3,0.4,2.6v1.9c0,0.3,0.3,0.6,0.6,0.6h0.2c0,0,0,0.1,0,0.1v1.9c0,0.3,0.2,0.6,0.3,0.6h1.3c0.2,0,0.3-0.3,0.3-0.6V5.3c0,0,0-0.1,0-0.1h0.2c0.3,0,0.6-0.3,0.6-0.6V2.6C4.1,2.3,3.8,2,3.5,2z")
.attr("transform", "scale(4)")

//background rectangle
out_of_svg
.append("rect")
.attr('class', 'rect_info')
.attr("width", 250)
.attr("height", 80);

//specify the number of columns and rows for pictogram layout
var numCols = 10;
var numRows = 1;

//padding for the grid
var xPadding = 25;
var yPadding = 25;

//horizontal and vertical spacing between the icons
var hBuffer = 20;
var wBuffer = 20;

//generate a d3 range for the total number of required elements
var myIndex = d3.range(numCols * numRows);

//text element to display number of icons highlighted
out_of_svg.append("text")
    .attr("id", "txtValue")
    .attr("x", xPadding)
    .attr("y", yPadding)
    .attr("dy", -3)
    .text("0");

//create group element and create an svg <use> element for each icon
out_of_svg.append("g")
    .attr("id", "pictoLayer")
    .selectAll("use")
    .data(myIndex)
    .enter()
    .append("use")
        .attr("xlink:href", "#iconCustom")
        .attr("id", function (d) {
            return "icon" + d;
        })
        .attr("x", function (d) {
            var remainder = d % numCols;//calculates the x position (column number) using modulus
            return xPadding + (remainder * wBuffer);//apply the buffer and return value
        })
          .attr("y", function (d) {
              var whole = Math.floor(d / numCols)//calculates the y position (row number)
              return yPadding + (whole * hBuffer);//apply the buffer and return the value
          })
        .classed("iconPlain", true);

var data = { percent: 34.0 };

function drawIsotype(dataObject) {
    var valueLit = dataObject.percent,
    total = numCols * numRows,
    valuePict = total * (dataObject.percent / 100),
    valueDecimal = (valuePict % 1);

    d3.select("#txtValue").text(valueLit + '%');

    d3.selectAll("use").attr("fill", function (d, i) {
        if (d < valuePict - 1) {
          return "orange";
        } else if (d > (valuePict - 1) && d < (valuePict)){
          gradient.append("svg:stop")
            .attr("offset", (valueDecimal * 100) + '%')
            .attr("stop-color", "orange")
            .attr("stop-opacity", 1);
          gradient.append("svg:stop")
            .attr("offset", (valueDecimal * 100) + '%')
            .attr("stop-color", "#ff0266")
            .attr("stop-opacity", 1);
         gradient.append("svg:stop")
            .attr("offset", '100%')
            .attr("stop-color", "#ff0266")
            .attr("stop-opacity", 1);
          return "url(#gradient)";
        } else {
          return "#ff0266"; // This is for any whole icons after the gradient starts
        }
    });
}
drawIsotype(data);

// Colour transition?
// icons
//   .attr("fill", "#eee")
//   .transition()
//   .duration(750)
//   .delay((d, i) -> i/5*750)
//   .attr("fill", (d, i) -> if i is 0 then "green" else "blue")
//
