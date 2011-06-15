  //var chartArea = [[0.1, 0.1, 0.95, 0.9], [0.2, 0.1, 0.95, 0.9],
  //                [0.1, 0.1, 0.8, 0.9], [0.1, 0.25, 0.9, 0.9], [0.1, 0.1, 0.9, 0.8]];
  //var legendArea = [[0.0, 0.0, 0.0, 0.0], [0.005, 0.1, 0.125, 0.5],
  //        [0.875, 0.1, 0.995, 0.5], [0.2, 0.1, 0.8, 0.2], [0.2, 0.9, 0.8, 0.995]];   
  //var fills = [['lightblue', 'url(#fadeBlue)'], ['pink', 'url(#fadeRed)'],
  // ['lightgreen', 'url(#fadeGreen)']];
  function buildGraph(options) { 
      var settings = $.extend({
            svg_container: "",
            graph_url: "test",
            id: 1,   
            dataType: "summary", 
            chartType: "line", //tell svg plugin if we want line, bar, or pie graphs
            chartTitle: "",
            timeframe: "7 days",
            xTitle: "",
            yTitle: ""
          },options||{});
      var svg = svgManager.getSVGFor(settings.svg_container);
      var params = {
            id:settings.id, //id of the node to get graph data for
            type:settings.dataType, /*this will be what we pass in to tell 
             *the data api what kind of data to return*/
            timeframe:settings.timeframe, //what time period do we want back from the data api?
            isJSON:true}; /*while this is not used right now, there is the chance we will want to 
              call the data api before rendering the page, this is a flag to allow that*/
      $.getJSON(settings.graph_url, params, function(response) { 
          var defs = svg.defs();
          var legendPos = 1; 
/*
* Everything else that is commented out from here down is experimental stuff that we shouldn't need right away, 
* but may want to play with as we make this look nicer.
*/                
          //svg.linearGradient(defs, 'fadeBlue', [[0, 'lightblue'], [1, 'blue']]);
          //svg.linearGradient(defs, 'fadeRed', [[0, 'pink'], [1, 'red']]);
          //svg.linearGradient(defs, 'fadeGreen', [[0, 'lightgreen'], [1, 'green']]);
          svg.graph.noDraw().title(settings.chartTitle,10).
              chartFormat('lightyellow', 'gray').
              //gridlines({stroke: 'gray', stroke_dasharray: '2,2'}, 'gray').
              status(setStatus);
          $(response.dataset).each(function(){
            svg.graph.noDraw().
                    addSeries(this.name, this.values, this.fill, this.stroke, this.strokeWidth);

          });
          svg.graph.xAxis.title(settings.xTitle).scale(0, 3);
          if (response.timepoints.length > 0){
            svg.graph.xAxis.ticks(1, 0).labels(response.timepoints);
          }
            svg.graph.yAxis.title(settings.yTitle).scale(-5, 105).ticks(10, 5);
            //svg.graph.legend.settings({fill: 'lightgoldenrodyellow', stroke: 'gray'});
            svg.graph.legend.show(legendPos).area([0.0, 0.0, 0.0, 0.0]);
            //for (var i = 0; i < 3; i++) {
            //        svg.graph.series()[i].format((fills[i])[0]);
            //}            
            svg.graph.noDraw().//chartArea(chartArea[legendPos]).
                    chartType(settings.chartType, {explode: [2], explodeDist: 10}).redraw();

      });
}
/*callback function for when you mouse over the data.
 *I hope for this eventually to highlight the datapoint and show any additional information 
 *the design may call for.  
 **/
function setStatus(value) {
    //alert(value);
} 
