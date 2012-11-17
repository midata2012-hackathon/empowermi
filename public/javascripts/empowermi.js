var jsonp = function(data) {
    $('#name').html(data.name);
    displayRecomendations(data.recommendations);
    drawChart(data.spendings);
    
};

var displayRecomendations = function(recommendations) {
    var recommendationsEl = document.createElement("ul");
    $.each(recommendations, function(index, value) { 
        var listEl = document.createElement("li");       
    });
}

var dataToDraw = {};

var drawChart = function(spendings) {
    var chartWidth = $('#chart').width(),
        chartHeight = 500;

    dataToDraw[spendings[0]["name"]] = spendings[0]["cost"];
  // Suppose there is currently one div with id "d3TutoGraphContainer" in the DOM
  // We append a 600x300 empty SVG container in the div
  var chart = d3.select("#chart").append("svg").attr("width", chartWidth).attr("height", chartHeight);

  var actualHeight = 0;

  // Create the bar chart which consists of ten SVG rectangles, one for each piece of data
  var rects = chart.selectAll('rect').data([1 ,4, 5, 6, 24, 8, 12, 1, 1, 200])
                   .enter().append('rect')
                   .attr("stroke", "none")
                    .attr("text-anchor", "end")
                    .text('ala')
                    .attr("fill", function(d,i) {var color = 'rgb(' + i * 20 + ',' + i * 30  +',100)'; return color })
                   .attr("x", 0)
                   .attr("y", function(d) { toReturn = actualHeight; actualHeight+=d; return toReturn } )
                   .attr("width", chartWidth /*function(d) { return 20 * d; }*/ )
                   .attr("height", function(d) {return d});

  // Transition on click managed by jQuery
  rects.on('click', function() {
    // Generate randomly a data set with 10 elements
    var newData = [];
    for (var i=0; i<10; i+=1) { newData.push(Math.floor(24 * Math.random())); }

    // Generate a random color
    var newColor = 'rgb(' + Math.floor(255 * Math.random()) +
                     ', ' + Math.floor(255 * Math.random()) +
                     ', ' + Math.floor(255 * Math.random()) + ')';

    rects.data(newData)
         .transition().duration(2000).delay(200)
         .attr("width", function(d) { return d * 20; } )
         .attr("fill", newColor);
  });
    
}

var checked = function(key,value) {
console.log('check');
    dataToDraw[key] = value;
    dataToDraw['Energy bill'] -= value;
}

var unchecked = function(key,value) {
console.log('uncheck');
    dataToDraw['Energy bill'] += value;
    delete dataToDraw[key]; 
}
