/* http://keith-wood.name/svg.html
   SVG graphing extension for jQuery v1.0.1.
   Written by Keith Wood (kbwood@iprimus.com.au) August 2007.
   Dual licensed under the GPL (http://dev.jquery.com/browser/trunk/jquery/GPL-LICENSE.txt) and 
   MIT (http://dev.jquery.com/browser/trunk/jquery/MIT-LICENSE.txt) licenses. 
   Please attribute the author if you use it. */

var svgGraphing = null;

(function($) { // Hide scope, no $ conflict

svgManager.addExtension('graph', SVGGraph);

// Singleton primary SVG graphing interface
svgGraphing = new SVGGraphing();

function SVGGraphing() {
	this.regional = [];
	this.regional[''] = {percentageText: 'Percentage'};
	this.region = this.regional[''];
}

$.extend(SVGGraphing.prototype, {
	_chartTypes: [],
	
	/* Add a new chart rendering type to the package.
	   The rendering object must implement the following functions:
	   getTitle(), getDescription(), getOptions(), drawChart(graph).
	   @param  id         string - the ID of this graph renderer
	   @param  chartType  object - the object implementing this chart type */
	addChartType: function(id, chartType) {
		this._chartTypes[id] = chartType;
	},
	
	/* Retrieve the list of chart types.
	   @return  object[string] - the array of chart types indexed by ID */
	chartTypes: function() {
		return this._chartTypes;
	}
});

/* Extension point for SVG graphing.
   Access through root.filters. */
function SVGGraph(root) {
	this._root = root; // The attached SVG root object
	this._drawNow = true; // True for immediate update, false to wait for redraw call
	for (var id in svgGraphing._chartTypes) {
		this._chartType = svgGraphing._chartTypes[id]; // Use first graph renderer
		break;
	}
	this._chartOptions = {}; // Extra options for the graph type
	// The graph title and settings
	this._title = {value: '', offset: 25, settings: {text_anchor: 'middle'}};
	this._area = [0.1, 0.1, 0.8, 0.9]; // The chart area: left, top, right, bottom, 
		// > 1 in pixels, <= 1 as proportion
	this._chartFormat = {fill: 'none', stroke: 'black'}; // The formatting for the chart area
	this._gridlines = []; // The formatting of the x- and y-gridlines
	this._series = []; // The series to be plotted, each is an object
	this._onstatus = null; // The callback function for status updates
	this._chartGroup = this._root.group(null, 'graph'); // The main group for the graph
	
	this.xAxis = new SVGGraphAxis(); // The main x-axis
	this.xAxis.title('', 40);
	this.yAxis = new SVGGraphAxis(); // The main y-axis
	this.yAxis.title('', 40);
	this.x2Axis = null; // The secondary x-axis
	this.y2Axis = null; // The secondary y-axis
	this.legend = new SVGGraphLegend(); // The chart legend
}

$.extend(SVGGraph.prototype, {

	/* Useful indexes. */
	X: 0,
	Y: 1,
	W: 2,
	H: 3,
	L: 0,
	T: 1,
	R: 2,
	B: 3,
	
	/* Standard percentage axis. */
	_percentageAxis: new SVGGraphAxis(svgGraphing.region.percentageText, 0, 100, 10, 0),

	/* Set or retrieve the type of chart to be rendered.
	   See svgGraphing.getChartTypes() for the list of available types.
	   @param  id       string - the ID of the chart type
	   @param  options  object - additional settings for this chart type (optional)
	   @return  SVGGraph - this graph object or 
	            string - the chart type (if no parameters) */
	chartType: function(id, options) {
		if (arguments.length == 0) {
			return this._chartType;
		}
		var chartType = svgGraphing._chartTypes[id];
		if (chartType) {
			this._chartType = chartType;
			this._chartOptions = $.extend({}, options || {});
		}
		this._drawGraph();
		return this;
	},
	
	/* Set or retrieve additional options for the particular chart type.
	   @param  options  object - the extra options
	   @return  SVGGraph - this graph object or
	            object - the chart options (if no parameters) */
	chartOptions: function(options) {
		if (arguments.length == 0) {
			return this._chartOptions;
		}
		this._chartOptions = $.extend({}, options);
		this._drawGraph();
		return this;
	},
	
	/* Set or retrieve the background of the graph chart.
	   @param  fill      string - how to fill the chart background
	   @param  stroke    string - the colour of the outline (optional)
	   @param  settings  object - additional formatting for the chart background (optional)
	   @return  SVGGraph - this graph object or
	            object - the chart format (if no parameters) */
	chartFormat: function(fill, stroke, settings) {
		if (arguments.length == 0) {
			return this._chartFormat;
		}
		if (typeof stroke == 'object') {
			settings = stroke;
			stroke = null;
		}
		this._chartFormat = $.extend($.extend({fill: fill},
			(stroke ? {stroke: stroke} : {})), settings || {});
		this._drawGraph();
		return this;
	},
	
	/* Set or retrieve the main chart area.
	   @param  left    number - > 1 is pixels, <= 1 is proportion of width or
	                   number[4] - for left, top, right, bottom
	   @param  top     number - > 1 is pixels, <= 1 is proportion of height
	   @param  right   number - > 1 is pixels, <= 1 is proportion of width
	   @param  bottom  number - > 1 is pixels, <= 1 is proportion of height
	   @return  SVGGraph - this graph object or
	            number[4] - the chart area: left, top, right, bottom (if no parameters) */
	chartArea: function(left, top, right, bottom) {
		if (arguments.length == 0) {
			return this._area;
		}
		this._area = (isArray(left) ? left : [left, top, right, bottom]);
		this._drawGraph();
		return this;
	},
	
	/* Set or retrieve the gridlines formatting for the graph chart.
	   @param  xSettings  string - the colour of the gridlines along the x-axis, or
	                      object - formatting for the gridlines along the x-axis, or
						  null for none
	   @param  ySettings  string - the colour of the gridlines along the y-axis, or
	                      object - formatting for the gridlines along the y-axis, or
						  null for none
	   @return  SVGGraph - this graph object or
	            object[2] - the gridlines formatting (if no parameters) */
	gridlines: function(xSettings, ySettings) {
		if (arguments.length == 0) {
			return this._gridlines;
		}
		this._gridlines = [(typeof xSettings == 'string' ? {stroke: xSettings} : xSettings),
			(typeof ySettings == 'string' ? {stroke: ySettings} : ySettings)];
		this._drawGraph();
		return this;
	},
	
	/* Set or retrieve the title of the graph and its formatting.
	   @param  value     string - the title
	   @param  offset    number - the vertical positioning of the title
                          > 1 is pixels, <= 1 is proportion of width (optional)
	   @param  settings  object - formatting for the title (optional)
	   @return  SVGGraph - this graph object or
	            object - value, offset, and settings for the title (if no parameters) */
	title: function(value, offset, settings) {
		if (arguments.length == 0) {
			return this._title;
		}
		if (typeof offset == 'object') {
			settings = offset;
			offset = null;
		}
		this._title = {value: value, offset: offset || this._title.offset,
			settings: $.extend({text_anchor: 'middle'}, settings || {})};
		this._drawGraph();
		return this;
	},
	
	/* Add a series of values to be plotted on the graph.
	   @param  name         string - the name of this series
	   @param  values       number[] - the values to be plotted
	   @param  fill         string - how the plotted values are filled
	   @param  stroke       string - the colour of the plotted lines
	   @param  strokeWidth  number - the width of the plotted lines (optional)
	   @param  settings     object - additional settings for the plotted values (optional)
	   @return  SVGGraph - this graph object */
	addSeries: function(name, values, fill, stroke, strokeWidth, settings) {
		if (typeof strokeWidth == 'object') {
			settings = strokeWidth;
			strokeWidth = null;
		}
		this._series[this._series.length] = 
			new SVGGraphSeries(name, values, fill, stroke, strokeWidth, settings || {});
		this._drawGraph();
		return this;
	},
	
	/* Retrieve the series wrappers.
	   @return  SVGGraphSeries[] - the list of series */
	series: function() {
		return this._series;
	},
	
	/* Suppress drawing of the graph until redraw() is called.
	   @return  SVGGraph - this graph object */
	noDraw: function() {
		this._drawNow = false;
		return this;
	},
	
	/* Redraw the entire graph with the current settings and values.
	   @return  SVGGraph - this graph object */
	redraw: function() {
		this._drawNow = true;
		this._drawGraph();
		return this;
	},
	
	/* Set the callback function for status updates.
	   @param  onstatus  function - the callback function
	   @return  SVGGraph - this graph object */
	status: function(onstatus) {
		this._onstatus = onstatus;
		return this;
	},
	
	/* Actually draw the graph (if allowed) based on the graph type set. */
	_drawGraph: function() {
		if (!this._drawNow) {
			return;
		}
		while (this._chartGroup.firstChild) {
			this._chartGroup.removeChild(this._chartGroup.firstChild);
		}
		if (!this._chartGroup.parent) {
			this._root._svg.appendChild(this._chartGroup);
		}
		this._chartType.drawGraph(this);
	},

	/* Draw the graph title - centred. */
	_drawTitle: function() {
		this._root.text(this._chartGroup, this._root._width() / 2, this._title.offset,
			this._title.value, this._title.settings);
	},
	
	/* Calculate the actual dimensions of the chart area.
	    @param  area  number[4] - the area values to evaluate (optional)
		@return  an array of dimension values: left, top, width, height */
	_getDims: function(area) {
		area = area || this._area;
		var left = (area[this.L] > 1 ? area[this.L] :
			this._root._width() * area[this.L]);
		var top = (area[this.T] > 1 ? area[this.T] :
			this._root._height() * area[this.T]);
		var width = (area[this.R] > 1 ? area[this.R] :
			this._root._width() * area[this.R]) - left;
		var height = (area[this.B] > 1 ? area[this.B] :
			this._root._height() * area[this.B]) - top;
		return [left, top, width, height];
	},
	
	/* Draw the chart background, including gridlines.
	   @param  noXGrid  boolean - true to suppress the x-gridlines, false to draw them (optional)
	   @param  noYGrid  boolean - true to suppress the y-gridlines, false to draw them (optional)
	   @return  the background group element */
	_drawChartBackground: function(noXGrid, noYGrid) {
		var bg = this._root.group(this._chartGroup, 'background');
		var dims = this._getDims();
		this._root.rect(bg, dims[this.X], dims[this.Y], dims[this.W], dims[this.H], this._chartFormat);
		if (this._gridlines[0] && this.yAxis._ticks.major && !noYGrid) {
			this._drawGridlines(bg, this.yAxis, true, dims, this._gridlines[0]);
		}
		if (this._gridlines[1] && this.xAxis._ticks.major && !noXGrid) {
			this._drawGridlines(bg, this.xAxis, false, dims, this._gridlines[1]);
		}
		return bg;
	},
	
	/* Draw one set of gridlines.
	   @param  bg      element - the background group element
	   @param  axis    SVGGraphAxis - the axis definition
	   @param  horiz   boolean - true if horizontal, false if vertical
	   @param  dims    number[] - the left, top, width, height of the chart area
	   @param  format  object - additional settings for the gridlines */
	_drawGridlines: function(bg, axis, horiz, dims, format) {
		var g = this._root.group(bg, format);
		var scale = (horiz ? dims[this.H] : dims[this.W]) / (axis._scale.max - axis._scale.min);
		var major = Math.floor(axis._scale.min / axis._ticks.major) * axis._ticks.major;
		major = (major < axis._scale.min ? major + axis._ticks.major : major);
		while (major <= axis._scale.max) {
			var v = (horiz ? axis._scale.max - major : major - axis._scale.min) * scale +
				(horiz ? dims[this.Y] : dims[this.X]);
			this._root.line(g, (horiz ? dims[this.X] : v), (horiz ? v : dims[this.Y]), 
				(horiz ? dims[this.X] + dims[this.W] : v), (horiz ? v : dims[this.Y] + dims[this.H]));
			major += axis._ticks.major;
		}
	},
	
	/* Draw the axes in their standard configuration.
	   @param  noX  boolean - true to suppress the x-axes, false to draw it (optional) */
	_drawAxes: function(noX) {
		var dims = this._getDims();
		if (this.xAxis && !noX) {
			if (this.xAxis._title) {
				this._root.text(this._chartGroup, dims[this.X] + dims[this.W] / 2,
					dims[this.Y] + dims[this.H] + this.xAxis._titleOffset, this.xAxis._title);
			}
			this._drawAxis(this.xAxis, 'xAxis', dims[this.X], dims[this.Y] + dims[this.H],
				dims[this.X] + dims[this.W], dims[this.Y] + dims[this.H]);
		}
		if (this.yAxis) {
			if (this.yAxis._title) {
				this._root.text(this._chartGroup, 0, 0, this.yAxis._title, {text_anchor: 'middle',
					transform: 'translate(' + (dims[this.X] - this.yAxis._titleOffset) + ',' +
					(dims[this.Y] + dims[this.H] / 2) + ') rotate(-90)'});
			}
			this._drawAxis(this.yAxis, 'yAxis', dims[this.X], dims[this.Y],
				dims[this.X], dims[this.Y] + dims[this.H]);
		}
		if (this.x2Axis && !noX) {
			if (this.x2Axis._title) {
				this._root.text(this._chartGroup, dims[this.X] + dims[this.W] / 2,
					dims[this.X] - this.x2Axis._titleOffset, this.x2Axis._title);
			}
			this._drawAxis(this.x2Axis, 'x2Axis', dims[this.X], dims[this.Y],
				dims[this.X] + dims[this.W], dims[this.Y]);
		}
		if (this.y2Axis) {
			if (this.y2Axis._title) {
				this._root.text(this._chartGroup, 0, 0, this.y2Axis._title, {text_anchor: 'middle',
					transform: 'translate(' + (dims[this.X] + dims[this.W] + this.y2Axis._titleOffset) +
					',' + (dims[this.Y] + dims[this.H] / 2) + ') rotate(-90)'});
			}
			this._drawAxis(this.y2Axis, 'y2Axis', dims[this.X] + dims[this.W], dims[this.Y],
				dims[this.X] + dims[this.W], dims[this.Y] + dims[this.H]);
		}
	},
	
	/* Draw an axis and its tick marks.
	   @param  axis  SVGGraphAxis - the axis definition
	   @param  id    string - the identifier for the axis group element
	   @param  x1    number - starting x-coodinate for the axis
	   @param  y1    number - starting y-coodinate for the axis
	   @param  x2    number - ending x-coodinate for the axis
	   @param  y2    number - ending y-coodinate for the axis */
	_drawAxis: function(axis, id, x1, y1, x2, y2) {
		var horiz = (y1 == y2);
		var gl = this._root.group(this._chartGroup, id, axis._lineFormat);
		var gt = this._root.group(this._chartGroup, id + 'Labels',
			$.extend({text_anchor: (horiz ? 'middle' : 'end')}, axis._labelFormat));
		this._root.line(gl, x1, y1, x2, y2);
		if (axis._ticks.major) {
			var bottomRight = (x2 > (this._root._width() / 2) && 
				y2 > (this._root._height() / 2));
			var scale = (horiz ? x2 - x1 : y2 - y1) / (axis._scale.max - axis._scale.min);
			var size = axis._ticks.size;
			var major = Math.floor(axis._scale.min / axis._ticks.major) * axis._ticks.major;
			major = (major < axis._scale.min ? major + axis._ticks.major : major);
			var minor = (!axis._ticks.minor ? axis._scale.max + 1 :
				Math.floor(axis._scale.min / axis._ticks.minor) * axis._ticks.minor);
			minor = (minor < axis._scale.min ? minor + axis._ticks.minor : minor);
			var offsets = this._getTickOffsets(axis, bottomRight);
			while (major <= axis._scale.max || minor <= axis._scale.max) {
				var cur = Math.min(major, minor);
				var len = (cur == major ? size : size / 2);
				var v = (horiz ? x1 : y1) +
					(horiz ? cur - axis._scale.min : axis._scale.max - cur) * scale;
				this._root.line(gl, (horiz ? v : x1 + len * offsets[0]), 
					(horiz ? y1 + len * offsets[0] : v), 
					(horiz ? v : x1 + len * offsets[1]), 
					(horiz ? y1 + len * offsets[1] : v));
				if (cur == major) {
					this._root.text(gt, (horiz ? v : x1 - size), (horiz ? y1 + 2 * size : v),
						(axis._labels ? axis._labels[cur] : '' + cur));
				}
				major += (cur == major ? axis._ticks.major : 0);
				minor += (cur == minor ? axis._ticks.minor : 0);
			}
		}
	},
	
	/* Calculate offsets based on axis and tick positions.
	   @param  axis         SVGGraphAxis - the axis definition
	   @param  bottomRight  boolean - true if this axis is appearing on the bottom or 
	                        right of the chart area, false if to the top or left
	   @return  the array of offset multipliers (-1..+1) */
	_getTickOffsets: function(axis, bottomRight) {
		return [(axis._ticks.position == (bottomRight ? 'in' : 'out') || 
			axis._ticks.position == 'both' ? -1 : 0), 
			(axis._ticks.position == (bottomRight ? 'out' : 'in') || 
			axis._ticks.position == 'both' ? +1 : 0), ];
	},
	
	/* Retrieve the standard percentage axis.
	   @return  percentage axis */
	_getPercentageAxis: function() {
		this._percentageAxis._title = svgGraphing.region.percentageText;
		return this._percentageAxis;
	},

	/* Calculate the column totals across all the series. */
	_getTotals: function() {
		var totals = [];
		var numVal = (this._series.length ? this._series[0]._values.length : 0);
		for (var i = 0; i < numVal; i++) {
			totals[i] = 0;
			for (var j = 0; j < this._series.length; j++) {
				totals[i] += this._series[j]._values[i];
			}
		}
		return totals;
	},
	
	/* Draw the chart legend. */
	_drawLegend: function() {
		if (!this.legend._show) {
			return;
		}
		var g = this._root.group(this._chartGroup, 'legend');
		var dims = this._getDims(this.legend._area);
		this._root.rect(g, dims[this.X], dims[this.Y], dims[this.W], dims[this.H],
			this.legend._bgSettings);
		var horiz =  dims[this.W] > dims[this.H];
		var numSer = this._series.length;
		var offset = (horiz ? dims[this.W] : dims[this.H]) / numSer;
		var xBase = dims[this.X] + 5;
		var yBase = dims[this.Y] + (horiz ? dims[this.H] / 2 : offset / 2);
		for (var i = 0; i < numSer; i++) {
			var series = this._series[i];
			this._root.rect(g, xBase + (horiz ? i * offset : 0),
				yBase + (horiz ? 0 : i * offset) - this.legend._sampleSize,
				this.legend._sampleSize, this.legend._sampleSize,
				{fill: series._fill, stroke: series._stroke, stroke_width: 1});
			this._root.text(g, xBase + (horiz ? i * offset : 0) + this.legend._sampleSize + 5,
				yBase + (horiz ? 0 : i * offset), series._name, this.legend._textSettings);
		}
	},
	
	/* Show the current value status on hover. */
	_showStatus: function(value) {
		var onStatus = (!this._onstatus ? '' :
			this._onstatus.toString().replace(/function (.*)\([\s\S]*/m, '$1'));
		return (!this._onstatus ? {} :
			{onmouseover: 'window.parent.' + onStatus + '(\'' + value + '\');',
			onmouseout: 'window.parent.' + onStatus  + '(\'\');'});
	}
});

/* Details about each graph axis.
   @param  title  string - the title of the axis
   @param  min    number - the minimum value displayed on this axis
   @param  max    number - the maximum value displayed on this axis
   @param  major  number - the distance between major ticks
   @param  minor  number - the distance between minor ticks (optional)
   @return  the new axis object */
function SVGGraphAxis(title, min, max, major, minor) {
	/* Title of this axis. */
	this._title = title || '';
	/* Formatting settings for the title. */
	this._titleFormat = {};
	/* The offset for positioning the title. */
	this._titleOffset = 0;
	/* List of labels for this axis - one per possible value across all series. */
	this._labels = null;
	/* Formatting settings for the labels. */
	this._labelFormat = {};
	/* Formatting settings for the axis lines. */
	this._lineFormat = {stroke: 'black'};
	/* Tick mark options. */
	this._ticks = {major: major || 10, minor: minor || 0, size: 10, position: 'out'};
	/* Axis scale settings. */
	this._scale = {min: min || 0, max: max || 100};
	/* Where this axis crosses the other one. */
	this._crossAt = 0;
}

$.extend(SVGGraphAxis.prototype, {

	/* Set or retrieve the scale for this axis.
	   @param  min  number - the minimum value shown
	   @param  max  number - the maximum value shown
	   @return  SVGGraphAxis - this axis object or
	            object - min and max values (if no parameters) */
	scale: function(min, max) {
		if (arguments.length == 0) {
			return this._scale;
		}
		this._scale.min = min;
		this._scale.max = max;
		return this;
	},
	
	/* Set or retrieve the ticks for this axis.
	   @param  major     number - the distance between major ticks
	   @param  minor     number - the distance between minor ticks
	   @param  size      number - the length of the major ticks (minor are half) (optional)
	   @param  position  string - the location of the ticks:
	                     'in', 'out', 'both' (optional)
	   @return  SVGGraphAxis - this axis object or
	            object - major, minor, size, and position values (if no parameters) */
	ticks: function(major, minor, size, position) {
		if (arguments.length == 0) {
			return this._ticks;
		}
		if (typeof size == 'string') {
			position = size;
			size = null;
		}
		this._ticks.major = major;
		this._ticks.minor = minor;
		this._ticks.size = size || 10;
		this._ticks.position = position || 'out';
		return this;
	},
	
	/* Set or retrieve the title for this axis.
	   @param  title   string - the title text
	   @param  offset  number - the distance to offset the title position (optional)
	   @param  format  object - formatting settings for the title (optional)
	   @return  SVGGraphAxis - this axis object or
	            object - title, offset, and format values (if no parameters) */
	title: function(title, offset, format) {
		if (arguments.length == 0) {
			return {title: this._title, offset: this._titleOffset, format: this._titleFormat};
		}
		if (typeof offset == 'object') {
			format = offset;
			offset = null;
		}
		this._title = title;
		if (offset != null) {
			this._titleOffset = offset;
		}
		if (format) {
			this._titleFormat = format;
		}
		return this;
	},
	
	/* Set or retrieve the labels for this axis.
	   @param  labels  string[] - the text for each entry
	   @param  format  object - formatting settings for the labels (optional)
	   @return  SVGGraphAxis - this axis object or
	            object - labels and format values (if no parameters) */
	labels: function(labels, format) {
		if (arguments.length == 0) {
			return {labels: this._labels, format: this._labelFormat};
		}
		this._labels = labels;
		if (format) {
			this._labelFormat = format;
		}
		return this;
	},
	
	/* Set or retrieve the line formatting for this axis.
	   @param  colour    string - the line's colour
	   @param  width     number - the line's width (optional)
	   @param  settings  object - additional formatting settings for the line (optional)
	   @return  SVGGraphAxis - this axis object or
	            object - line formatting values (if no parameters) */
	line: function(colour, width, settings) {
		if (arguments.length == 0) {
			return this._lineFormat;
		}
		if (typeof width == 'object') {
			settings = width;
			width = null;
		}
		$.extend(this._lineFormat, {stroke: colour, stroke_width: width || 1});
		$.extend(this._lineFormat, settings || {});
		return this;
	}
});

var defaultSeriesFill = 'green';
var defaultSeriesStroke = 'black';

/* Details about each graph series.
   @param  name         string - the name of this series
   @param  values       number[] - the list of values to be plotted
   @param  fill         string - how the series should be displayed
   @param  stroke       string - the colour of the (out)line for the series
   @param  strokeWidth  number - the width of the (out)line for the series
   @param  settings     object - additional formatting settings
   @return  the new series object */
function SVGGraphSeries(name, values, fill, stroke, strokeWidth, settings) {
	/* The name of this series. */
	this._name = name || '';
	/* The list of values for this series. */
	this._values = values || [];
	/* Which axis this series applies to: 1 = primary, 2 = secondary. */
	this._axis = 1;
	/* How the series is plotted. */
	this._fill = fill || defaultSeriesFill;
	/* The colour for the (out)line. */
	this._stroke = stroke || defaultSeriesStroke;
	/* The (out)line width. */
	this._strokeWidth = strokeWidth || 1;
	/* Additional formatting settings for the series. */
	this._settings = settings || {};
}

$.extend(SVGGraphSeries.prototype, {

	/* Set or retrieve the name for this series.
	   @param  name    string - the series' name
	   @return  SVGGraphSeries - this series object or
	            string - the series name (if no parameters) */
	name: function(name) {
		if (arguments.length == 0) {
			return this._name;
		}
		this._name = name;
		return this;
	},

	/* Set or retrieve the values for this series.
	   @param  name    string - the series' name (optional)
	   @param  values  number[] - the values to be graphed
	   @return  SVGGraphSeries - this series object or
	            number[] - the series values (if no parameters) */
	values: function(name, values) {
		if (arguments.length == 0) {
			return this._values;
		}
		if (isArray(name)) {
			valus = name;
			name = null;
		}
		this._name = name || this._name;
		this._values = values;
		return this;
	},
	
	/* Set or retrieve the formatting for this series.
	   @param  fill         string - how the values are filled when plotted
	   @param  stroke       string - the (out)line colour
	   @param  strokeWidth  number - the line's width (optional)
	   @param  settings     object - additional formatting settings for the series (optional)
	   @return  SVGGraphSeries - this series object or
	            object - formatting settings (if no parameters) */
	format: function(fill, stroke, strokeWidth, settings) {
		if (arguments.length == 0) {
			return $.extend({fill: this._fill, stroke: this._stroke,
				stroke_width: this._strokeWidth}, this._settings);
		}
		if (typeof strokeWidth == 'object') {
			settings = strokeWidth;
			strokeWidth = null;
		}
		this._fill = fill || defaultSeriesFill;
		this._stroke = stroke || this._stroke;
		this._strokeWidth = strokeWidth || this._strokeWidth;
		$.extend(this._settings, settings || {});
		return this;
	}
});

/* Details about the graph legend.
   @param  bgSettings    object - additional formatting settings for the legend background (optional)
   @param  textSettings  object - additional formatting settings for the legend text (optional)
   @return  the new legend object */
function SVGGraphLegend(bgSettings, textSettings) {
	this._show = true; // Show the legend?
	this._area = [0.9, 0.1, 1.0, 0.9]; // The legend area: left, top, right, bottom, 
		// > 1 in pixels, <= 1 as proportion
	this._sampleSize = 15; // Size of sample box
	this._bgSettings = bgSettings || {stroke: 'gray'}; // Additional formatting settings for the legend background
	this._textSettings = textSettings || {}; // Additional formatting settings for the text
}

$.extend(SVGGraphLegend.prototype, {

	/* Set or retrieve whether the legend should be shown.
	   @param  show  boolean - true to display it, false to hide it
	   @return  SVGGraphLegend - this legend object or
	            boolean - show the legend? (if no parameters) */
	show: function(show) {
		if (arguments.length == 0) {
			return this._show;
		}
		this._show = show;
		return this;
	},
	
	/* Set or retrieve the legend area.
	   @param  left    number - > 1 is pixels, <= 1 is proportion of width or
	                   number[4] - for left, top, right, bottom
	   @param  top     number - > 1 is pixels, <= 1 is proportion of height
	   @param  right   number - > 1 is pixels, <= 1 is proportion of width
	   @param  bottom  number - > 1 is pixels, <= 1 is proportion of height
	   @return  SVGGraphLegend - this legend object or
	            number[4] - the legend area: left, top, right, bottom (if no parameters) */
	area: function(left, top, right, bottom) {
		if (arguments.length == 0) {
			return this._area;
		}
		this._area = (isArray(left) ? left : [left, top, right, bottom]);
		return this;
	},

	/* Set or retrieve additional settings for the legend area.
	   @param  sampleSize    number - the size of the sample box to display (optional)
	   @param  bgSettings    object - additional formatting settings for the legend background
	   @param  textSettings  object - additional formatting settings for the legend text (optional)
	   @return  SVGGraphLegend - this legend object or
	            object - bgSettings and textSettings for the legend (if no parameters) */
	settings: function(sampleSize, bgSettings, textSettings) {
		if (arguments.length == 0) {
			return {sampleSize: this._sampleSize, bgSettings: this._bgSettings,
				textSettings: this._textSettings};
		}
		if (typeof sampleSize == 'object') {
			textSettings = bgSettings;
			bgSettings = sampleSize;
			sampleSize = null;
		}
		if (sampleSize) {
			this._sampleSize = sampleSize;
		}
		this._bgSettings = bgSettings;
		if (textSettings) {
			this._textSettings = textSettings;
		}
		return this;
	}
});

//==============================================================================

/* Round a number to a given number of decimal points. */
function roundNumber(num, dec) {
	return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
}

var barOptions = ['barWidth (number) - the width of each bar',
	'barGap (number) - the gap between sets of bars'];

//------------------------------------------------------------------------------

/* Draw a standard grouped column bar chart. */
function SVGColumnChart() {
}

$.extend(SVGColumnChart.prototype, {

	/* Retrieve the display title for this chart type.
	   @return  the title */
	title: function() {
		return 'Basic column chart';
	},

	/* Retrieve a description of this chart type.
	   @return  its description */
	description: function() {
		return 'Compare sets of values as vertical bars with grouped categories.';
	},

	/* Retrieve a list of the options that may be set for this chart type.
	   @return  options list */
	options: function() {
		return barOptions;
	},

	/* Actually draw the graph in this type's style.
	   @param  graph  object - the SVGGraph object */
	drawGraph: function(graph) {
		graph._drawChartBackground(true);
		var barWidth = graph._chartOptions.barWidth || 10;
		var barGap = graph._chartOptions.barGap || 10;
		var numSer = graph._series.length;
		var numVal = (numSer ? (graph._series[0])._values.length : 0);
		var dims = graph._getDims();
		var xScale = dims[graph.W] / ((numSer * barWidth + barGap) * numVal + barGap);
		var yScale = dims[graph.H] / (graph.yAxis._scale.max - graph.yAxis._scale.min);
		this._chart = graph._root.group(graph._chartGroup, 'chart');
		for (var i = 0; i < numSer; i++) {
			this._drawSeries(graph, i, numSer, barWidth, barGap, dims, xScale, yScale);
		}
		graph._drawTitle();
		graph._drawAxes(true);
		this._drawXAxis(graph, numSer, numVal, barWidth, barGap, dims, xScale);
		graph._drawLegend();
	},
	
	/* Plot an individual series. */
	_drawSeries: function(graph, cur, numSer, barWidth, barGap, dims, xScale, yScale) {
		var series = graph._series[cur];
		var g = graph._root.group(this._chart, 'series' + cur,
			$.extend({stroke: series._stroke,
			stroke_width: series._strokeWidth}, series._settings || {}));
		for (var i = 0; i < series._values.length; i++) {
			graph._root.rect(g, 
				dims[graph.X] + xScale * (barGap + i * (numSer * barWidth + barGap) + (cur * barWidth)),
				dims[graph.Y] + yScale * (graph.yAxis._scale.max - series._values[i]), 
				xScale * barWidth, yScale * series._values[i], $.extend({fill: series._fill},
				graph._showStatus(series._name + ' ' + series._values[i])));
		}
	},
	
	/* Draw the x-axis and its ticks. */
	_drawXAxis: function(graph, numSer, numVal, barWidth, barGap, dims, xScale) {
		var axis = graph.xAxis;
		if (axis._title) {
			graph._root.text(graph._chartGroup, dims[graph.X] + dims[graph.W] / 2,
				dims[graph.Y] + dims[graph.H] + axis._titleOffset,
				axis._title, {text_anchor: 'middle'});
		}
		var gl = graph._root.group(graph._chartGroup, 'xAxis', axis._lineFormat);
		var gt = graph._root.group(graph._chartGroup, 'xAxisLabels',
			$.extend({text_anchor: 'middle'}, axis._labelFormat));
		graph._root.line(gl, dims[graph.X], dims[graph.Y] + dims[graph.H],
			dims[graph.X] + dims[graph.W], dims[graph.Y] + dims[graph.H]);
		if (axis._ticks.major) {
			var offsets = graph._getTickOffsets(axis, true);
			for (var i = 1; i < numVal; i++) {
				var x = dims[graph.X] + xScale * (barGap / 2 + i * (numSer * barWidth + barGap));
				graph._root.line(gl, x, dims[graph.Y] + dims[graph.H] + offsets[0] * axis._ticks.size,
					x, dims[graph.Y] + dims[graph.H] + offsets[1] * axis._ticks.size);
			}
			for (var i = 0; i < numVal; i++) {
				var x = dims[graph.X] + xScale * (barGap / 2 + (i + 0.5) * (numSer * barWidth + barGap));
				graph._root.text(gt, x, dims[graph.Y] + dims[graph.H] + 2 * axis._ticks.size,
					(axis._labels ? axis._labels[i] : '' + i));
			}
		}
	}
});

//------------------------------------------------------------------------------

/* Draw a stacked column bar chart. */
function SVGStackedColumnChart() {
}

$.extend(SVGStackedColumnChart.prototype, {

	/* Retrieve the display title for this chart type.
	   @return  the title */
	title: function() {
		return 'Stacked column chart';
	},

	/* Retrieve a description of this chart type.
	   @return  its description */
	description: function() {
		return 'Compare sets of values as vertical bars showing ' +
			'relative contributions to the whole for each category.';
	},

	/* Retrieve a list of the options that may be set for this chart type.
	   @return  options list */
	options: function() {
		return barOptions;
	},

	/* Actually draw the graph in this type's style.
	   @param  graph  object - the SVGGraph object */
	drawGraph: function(graph) {
		var bg = graph._drawChartBackground(true, true);
		var dims = graph._getDims();
		if (graph._gridlines[0] && graph.xAxis._ticks.major) {
			graph._drawGridlines(bg, graph._getPercentageAxis(), true, dims, graph._gridlines[0]);
		}
		var barWidth = graph._chartOptions.barWidth || 10;
		var barGap = graph._chartOptions.barGap || 10;
		var numSer = graph._series.length;
		var numVal = (numSer ? (graph._series[0])._values.length : 0);
		var xScale = dims[graph.W] / ((barWidth + barGap) * numVal + barGap);
		var yScale = dims[graph.H];
		this._chart = graph._root.group(graph._chartGroup, 'chart');
		this._drawColumns(graph, numSer, numVal, barWidth, barGap, dims, xScale, yScale);
		graph._drawTitle();
		graph._root.text(graph._chartGroup, 0, 0, svgGraphing.region.percentageText,
			{text_anchor: 'middle', transform: 'translate(' + (dims[graph.X] - graph.yAxis._titleOffset) +
			',' +(dims[graph.Y] + dims[graph.H] / 2) + ') rotate(-90)'});
		//graph._drawAxis(graph._getPercentageAxis(), 'yAxis',
			//dims[graph.X], dims[graph.Y], dims[graph.X], dims[graph.Y] + dims[graph.H]);
		this._drawXAxis(graph, numVal, barWidth, barGap, dims, xScale);
		graph._drawLegend();
	},
	
	/* Plot all of the columns. */
	_drawColumns: function(graph, numSer, numVal, barWidth, barGap, dims, xScale, yScale) {
		var totals = graph._getTotals();
		var accum = [];
		for (var i = 0; i < numVal; i++) {
			accum[i] = 0;
		}
		for (var s = 0; s < numSer; s++) {
			var series = graph._series[s];
			var g = graph._root.group(this._chart, 'series' + s,
				$.extend({stroke: series._stroke, stroke_width: series._strokeWidth},
				series._settings || {}));
			for (var i = 0; i < series._values.length; i++) {
				accum[i] += series._values[i];
				graph._root.rect(g,
					dims[graph.X] + xScale * (barGap + i * (barWidth + barGap)),
					dims[graph.Y] + yScale * (totals[i] - accum[i]) / totals[i],
					xScale * barWidth, yScale * series._values[i] / totals[i],
					$.extend({fill: series._fill}, graph._showStatus(series._name + ' ' +
					roundNumber(series._values[i] / totals[i] * 100, 2) + '%')));
			}
		}
	},
	
	/* Draw the x-axis and its ticks. */
	_drawXAxis: function(graph, numVal, barWidth, barGap, dims, xScale) {
		var axis = graph.xAxis;
		if (axis._title) {
			graph._root.text(graph._chartGroup, dims[graph.X] + dims[graph.W] / 2,
				dims[graph.Y] + dims[graph.H] + axis._titleOffset,
				axis._title, {text_anchor: 'middle'});
		}
		var gl = graph._root.group(graph._chartGroup, 'xAxis', axis._lineFormat);
		var gt = graph._root.group(graph._chartGroup, 'xAxisLabels',
			$.extend({text_anchor: 'middle'}, axis._labelFormat));
		graph._root.line(gl, dims[graph.X], dims[graph.Y] + dims[graph.H],
		dims[graph.X] + dims[graph.W], dims[graph.Y] + dims[graph.H]);
		if (axis._ticks.major) {
			var offsets = graph._getTickOffsets(axis, true);
			for (var i = 1; i < numVal; i++) {
				var x = dims[graph.X] + xScale * (barGap / 2 + i * (barWidth + barGap));
				graph._root.line(gl, x, dims[graph.Y] + dims[graph.H] + offsets[0] * axis._ticks.size,
					x, dims[graph.Y] + dims[graph.H] + offsets[1] * axis._ticks.size);
			}
			for (var i = 0; i < numVal; i++) {
				var x = dims[graph.X] + xScale * (barGap / 2 + (i + 0.5) * (barWidth + barGap));
				graph._root.text(gt, x, dims[graph.Y] + dims[graph.H] + 2 * axis._ticks.size,
					(axis._labels ? axis._labels[i] : '' + i));
			}
		}
	}
});

//------------------------------------------------------------------------------

/* Draw a standard grouped row bar chart. */
function SVGRowChart() {
}

$.extend(SVGRowChart.prototype, {

	/* Retrieve the display title for this chart type.
	   @return  the title */
	title: function() {
		return 'Basic row chart';
	},

	/* Retrieve a description of this chart type.
	   @return  its description */
	description: function() {
		return 'Compare sets of values as horizontal rows with grouped categories.';
	},

	/* Retrieve a list of the options that may be set for this chart type.
	   @return  options list */
	options: function() {
		return barOptions;
	},

	/* Actually draw the graph in this type's style.
	   @param  graph  object - the SVGGraph object */
	drawGraph: function(graph) {
		var bg = graph._drawChartBackground(true, true);
		var dims = graph._getDims();
		graph._drawGridlines(bg, graph.yAxis, false, dims, graph._gridlines[0]);
		var barWidth = graph._chartOptions.barWidth || 10;
		var barGap = graph._chartOptions.barGap || 10;
		var numSer = graph._series.length;
		var numVal = (numSer ? (graph._series[0])._values.length : 0);
		var xScale = dims[graph.W] / (graph.yAxis._scale.max - graph.yAxis._scale.min);
		var yScale = dims[graph.H] / ((numSer * barWidth + barGap) * numVal + barGap);
		this._chart = graph._root.group(graph._chartGroup, 'chart');
		for (var i = 0; i < numSer; i++) {
			this._drawSeries(graph, i, numSer, barWidth, barGap, dims, xScale, yScale);
		}
		graph._drawTitle();
		this._drawAxes(graph, numSer, numVal, barWidth, barGap, dims, yScale);
		graph._drawLegend();
	},
	
	/* Plot an individual series. */
	_drawSeries: function(graph, cur, numSer, barWidth, barGap, dims, xScale, yScale) {
		var series = graph._series[cur];
		var g = graph._root.group(this._chart, 'series' + cur,
			$.extend({stroke: series._stroke, stroke_width: series._strokeWidth},
			series._settings || {}));
		for (var i = 0; i < series._values.length; i++) {
			graph._root.rect(g,
				dims[graph.X] + xScale * (0 - graph.yAxis._scale.min),
				dims[graph.Y] + yScale * (barGap + i * (numSer * barWidth + barGap) + (cur * barWidth)),
				xScale * series._values[i], yScale * barWidth, $.extend({fill: series._fill},
				graph._showStatus(series._name + ' ' + series._values[i])));
		}
	},
	
	/* Draw the axes for this graph. */
	_drawAxes: function(graph, numSer, numVal, barWidth, barGap, dims, yScale) {
		// X-axis
		var axis = graph.yAxis;
		if (axis) {
			if (axis._title) {
				graph._root.text(graph._chartGroup, dims[graph.X] + dims[graph.W] / 2,
					dims[graph.Y] + dims[graph.H] + axis._titleOffset, axis._title, axis._titleFormat);
			}
			graph._drawAxis(axis, 'xAxis', dims[graph.X], dims[graph.Y] + dims[graph.H],
				dims[graph.X] + dims[graph.W], dims[graph.Y] + dims[graph.H]);
		}
		// Y-axis
		var axis = graph.xAxis;
		if (axis._title) {
			graph._root.text(graph._chartGroup, 0, 0, axis._title, {text_anchor: 'middle',
				transform: 'translate(' + (dims[graph.X] - axis._titleOffset) + ',' +
				(dims[graph.Y] + dims[graph.H] / 2) + ') rotate(-90)'});
		}
		var gl = graph._root.group(graph._chartGroup, 'yAxis', axis._lineFormat);
		var gt = graph._root.group(graph._chartGroup, 'yAxisLabels',
			$.extend({text_anchor: 'end'}, axis._labelFormat));
		graph._root.line(gl, dims[graph.X], dims[graph.Y], dims[graph.X], dims[graph.Y] + dims[graph.H]);
		if (axis._ticks.major) {
			var offsets = graph._getTickOffsets(axis, false);
			for (var i = 1; i < numVal; i++) {
				var y = dims[graph.Y] + yScale * (barGap / 2 + i * (numSer * barWidth + barGap));
				graph._root.line(gl, dims[graph.X] + offsets[0] * axis._ticks.size, y,
					dims[graph.X] + offsets[1] * axis._ticks.size, y);
			}
			for (var i = 0; i < numVal; i++) {
				var y = dims[graph.Y] + yScale * (barGap / 2 + (i + 0.5) * (numSer * barWidth + barGap));
				graph._root.text(gt, dims[graph.X] - axis._ticks.size, y,
					(axis._labels ? axis._labels[i] : '' + i));
			}
		}
	}
});

//------------------------------------------------------------------------------

/* Draw a stacked row bar chart. */
function SVGStackedRowChart() {
}

$.extend(SVGStackedRowChart.prototype, {

	/* Retrieve the display title for this chart type.
	   @return  the title */
	title: function() {
		return 'Stacked row chart';
	},

	/* Retrieve a description of this chart type.
	   @return  its description */
	description: function() {
		return 'Compare sets of values as horizontal bars showing ' +
			'relative contributions to the whole for each category.';
	},

	/* Retrieve a list of the options that may be set for this chart type.
	   @return  options list */
	options: function() {
		return barOptions;
	},

	/* Actually draw the graph in this type's style.
	   @param  graph  object - the SVGGraph object */
	drawGraph: function(graph) {
		var bg = graph._drawChartBackground(true, true);
		var dims = graph._getDims();
		if (graph._gridlines[0] && graph.xAxis._ticks.major) {
			graph._drawGridlines(bg, graph._getPercentageAxis(), false, dims, graph._gridlines[0]);
		}
		var barWidth = graph._chartOptions.barWidth || 10;
		var barGap = graph._chartOptions.barGap || 10;
		var numSer = graph._series.length;
		var numVal = (numSer ? (graph._series[0])._values.length : 0);
		var xScale = dims[graph.W];
		var yScale = dims[graph.H] / ((barWidth + barGap) * numVal + barGap);
		this._chart = graph._root.group(graph._chartGroup, 'chart');
		this._drawRows(graph, numSer, numVal, barWidth, barGap, dims, xScale, yScale);
		graph._drawTitle();
		graph._root.text(graph._chartGroup, dims[graph.X] + dims[graph.W] / 2,
			dims[graph.Y] + dims[graph.H] + graph.xAxis._titleOffset,
			svgGraphing.region.percentageText, {text_anchor: 'middle'});
	//	graph._drawAxis(graph._getPercentageAxis(), 'xAxis',
	//		dims[graph.X], dims[graph.Y] + dims[graph.H],
	//		dims[graph.X] + dims[graph.W], dims[graph.Y] + dims[graph.H]);
	//	this._drawYAxis(graph, numVal, barWidth, barGap, dims, yScale);
		graph._drawLegend();
	},
	
	/* Plot all of the rows. */
	_drawRows: function(graph, numSer, numVal, barWidth, barGap, dims, xScale, yScale) {
		var totals = graph._getTotals();
		var accum = [];
		for (var i = 0; i < numVal; i++) {
			accum[i] = 0;
		}
		for (var s = 0; s < numSer; s++) {
			var series = graph._series[s];
			var g = graph._root.group(this._chart, 'series' + s,
				$.extend({stroke: series._stroke, stroke_width: series._strokeWidth},
				series._settings || {}));
			for (var i = 0; i < series._values.length; i++) {
				graph._root.rect(g,
					dims[graph.X] + xScale * accum[i] / totals[i],
					dims[graph.Y] + yScale * (barGap + i * (barWidth + barGap)),
					xScale * series._values[i] / totals[i], yScale * barWidth,
					$.extend({fill: series._fill}, graph._showStatus(series._name + ' ' +
					roundNumber(series._values[i] / totals[i] * 100, 2) + '%')));
				accum[i] += series._values[i];
			}
		}
	},
	
	/* Draw the y-axis and its ticks. */
	_drawYAxis: function(graph, numVal, barWidth, barGap, dims, yScale) {
		var axis = graph.xAxis;
		if (axis._title) {
			graph._root.text(graph._chartGroup, 0, 0, axis._title, {text_anchor: 'middle',
				transform: 'translate(' + (dims[graph.X] - axis._titleOffset) + ',' +
				(dims[graph.Y] + dims[graph.H] / 2) + ') rotate(-90)'});
		}
		var gl = graph._root.group(graph._chartGroup, 'yAxis', axis._lineFormat);
		var gt = graph._root.group(graph._chartGroup, 'yAxisLabels',
			$.extend({text_anchor: 'end'}, axis._labelFormat));
		graph._root.line(gl, dims[graph.X], dims[graph.Y], dims[graph.X], dims[graph.Y] + dims[graph.H]);
		if (axis._ticks.major) {
			var offsets = graph._getTickOffsets(axis, false);
			for (var i = 1; i < numVal; i++) {
				var y = dims[graph.Y] + yScale * (barGap / 2 + i * (barWidth + barGap));
				graph._root.line(gl, dims[graph.X] + offsets[0] * axis._ticks.size, y,
					dims[graph.X] + offsets[1] * axis._ticks.size, y);
			}
			for (var i = 0; i < numVal; i++) {
				var y = dims[graph.Y] + yScale * (barGap / 2 + (i + 0.5) * (barWidth + barGap));
				graph._root.text(gt, dims[graph.X] - axis._ticks.size, y,
					(axis._labels ? axis._labels[i] : '' + i));
			}
		}
	}
});

//------------------------------------------------------------------------------

/* Draw a standard line chart. */
function SVGLineChart() {
}

$.extend(SVGLineChart.prototype, {

	/* Retrieve the display title for this chart type.
	   @return  the title */
	title: function() {
		return 'Basic line chart';
	},

	/* Retrieve a description of this chart type.
	   @return  its description */
	description: function() {
		return 'Compare sets of values as continuous lines.';
	},

	/* Retrieve a list of the options that may be set for this chart type.
	   @return  options list */
	options: function() {
		return [];
	},
	
	/* Actually draw the graph in this type's style.
	   @param  graph  object - the SVGGraph object */
	drawGraph: function(graph) {
		graph._drawChartBackground();
		var dims = graph._getDims();
		var xScale = dims[graph.W] / (graph.xAxis._scale.max - graph.xAxis._scale.min);
		var yScale = dims[graph.H] / (graph.yAxis._scale.max - graph.yAxis._scale.min);
		this._chart = graph._root.group(graph._chartGroup, 'chart');
		for (var i = 0; i < graph._series.length; i++) {
			this._drawSeries(graph, i, dims, xScale, yScale);
		}
		graph._drawTitle();
		graph._drawAxes();
		graph._drawLegend();
	},
	
	/* Plot an individual series. */
	_drawSeries: function(graph, cur, dims, xScale, yScale) {
		var series = graph._series[cur];
		var path = graph._root.createPath();
		for (var i = 0; i < series._values.length; i++) {
			var x = dims[graph.X] + i * xScale;
			var y = dims[graph.Y] + (graph.yAxis._scale.max - series._values[i]) * yScale;
			if (i == 0) {
				path.moveTo(x, y);
			}
			else {
				path.lineTo(x, y);
			}
		}
		graph._root.path(this._chart, path, 
			$.extend($.extend({id: 'series' + cur, fill: 'none', stroke: series._stroke, 
			stroke_width: series._strokeWidth}, graph._showStatus(series._name),
			series._settings || {})));
	}
});

//------------------------------------------------------------------------------

/* Draw a standard pie chart. */
function SVGPieChart() {
}

$.extend(SVGPieChart.prototype, {

	_options: ['explode (number[]) - indexes of sections to explode out of the pie',
		'explodeDist (number) - the distance to move an exploded section',
		'pieGap (number) - the distance between pies for multiple values'],

	/* Retrieve the display title for this chart type.
	   @return  the title */
	title: function() {
		return 'Pie chart';
	},

	/* Retrieve a description of this chart type.
	   @return  its description */
	description: function() {
		return 'Compare relative sizes of values as contributions to the whole.';
	},

	/* Retrieve a list of the options that may be set for this chart type.
	   @return  options list */
	options: function() {
		return this._options;
	},
	
	/* Actually draw the graph in this type's style.
	   @param  graph  object - the SVGGraph object */
	drawGraph: function(graph) {
		graph._drawChartBackground(true, true);
		this._chart = graph._root.group(graph._chartGroup, 'chart');
		var dims = graph._getDims();
		this._drawSeries(graph, dims);
		graph._drawTitle();
		graph._drawLegend();
	},
	
	/* Plot all the series. */
	_drawSeries: function(graph, dims) {
		var totals = graph._getTotals();
		var numSer = graph._series.length;
		var numVal = (numSer ? (graph._series[0])._values.length : 0);
		var path = graph._root.createPath();
		var explode = graph._chartOptions.explode || [];
		var explodeDist = graph._chartOptions.explodeDist || 10;
		var pieGap = (numVal <= 1 ? 0 : graph._chartOptions.pieGap || 10);
		var xBase = (dims[graph.W] - (numVal * pieGap) - pieGap) / numVal / 2;
		var yBase = dims[graph.H] / 2;
		var radius = Math.min(xBase, yBase) - (explode.length > 0 ? explodeDist : 0);
		var gt = graph._root.group(graph._chartGroup, 'xAxisLabels',
			$.extend({text_anchor: 'middle'}, graph.xAxis._labelFormat));
		var gl = [];
		for (var i = 0; i < numVal; i++) {
			var cx = dims[graph.X] + xBase + (i * (2 * Math.min(xBase, yBase) + pieGap)) + pieGap;
			var cy = dims[graph.Y] + yBase;
			var curTotal = 0;
			for (var j = 0; j < numSer; j++) {
				var series = graph._series[j];
				if (i == 0) {
					gl[j] = graph._root.group(this._chart, 'series' + j,
						$.extend({stroke: series._stroke, stroke_width: series._strokeWidth},
						series._settings || {}));
				}
				if (series._values[i] == 0) {
					continue;
				}
				var start = (curTotal / totals[i]) * 2 * Math.PI;
				curTotal += series._values[i];
				var end = (curTotal / totals[i]) * 2 * Math.PI;
				var exploding = false;
				for (var k = 0; k < explode.length; k++) {
					if (explode[k] == j) {
						exploding = true;
						break;
					}
				}
				var x = cx + (exploding ? explodeDist * Math.cos((start + end) / 2) : 0);
				var y = cy + (exploding ? explodeDist * Math.sin((start + end) / 2) : 0);
				var status = series._name + ' ' +
					roundNumber((end - start) / 2 / Math.PI * 100, 2) + '%';
				graph._root.path(gl[j], path.reset().moveTo(x, y).
					lineTo(x + radius * Math.cos(start), y + radius * Math.sin(start)).
					arcTo(radius, radius, 0, (end - start < Math.PI ? 0 : 1), 1, 
					x + radius * Math.cos(end), y + radius * Math.sin(end)).close(), 
					$.extend({fill: series._fill}, graph._showStatus(status)));
			}
			if (graph.xAxis) {
				graph._root.text(gt, cx, dims[graph.Y] + dims[graph.H] + graph.xAxis._titleOffset,
					graph.xAxis._labels[i])
			}
		}
	}
});

//------------------------------------------------------------------------------

/* Determine whether an object is an array. */
function isArray(a) {
	return (a.constructor && a.constructor.toString().match(/\Array\(\)/));
}

// Basic chart types
svgGraphing.addChartType('column', new SVGColumnChart());
svgGraphing.addChartType('stackedColumn', new SVGStackedColumnChart());
svgGraphing.addChartType('row', new SVGRowChart());
svgGraphing.addChartType('stackedRow', new SVGStackedRowChart());
svgGraphing.addChartType('line', new SVGLineChart());
svgGraphing.addChartType('pie', new SVGPieChart());

})(jQuery)
