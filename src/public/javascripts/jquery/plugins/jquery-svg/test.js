// Demonstrate an onLoad callback to initialise a canvas
function drawIntro() {
	var svg = svgManager.getSVGFor('#cool_graph');
	svg.circle(null, 75, 75, 50, {fill: 'none', stroke: 'red', stroke_width: 3});
	var g = svg.group(null, {stroke: 'black', stroke_width: 2});
	svg.line(g, 15, 75, 135, 75);
	svg.line(g, 75, 15, 75, 135);
}

// -----------------------------------------------------------------------------

var svgSpec = 'http://www.w3c.org/TR/SVG11/';
// SVG examples
var examples = [
	['Basic shapes', basicShapesDemo,
	'SVG provides for the creation of several basic shapes, including ' +
	'rectangles, rectangles with rounded corners, circles, ellipses, ' +
	'lines segments, polygonal lines, and closed polygons. ' +
	'Each shape may be drawn with its own fill and border colourings. ' +
	'Shapes may be moved and rotated via the transformation abilities of SVG. ' +
	'Grouping elements allows common attributes to be easily applied.<br/>' +
	'See the original documents: <a href="http://www.w3.org/TR/SVG11/images/shapes/rect01.svg" target="_blank">rectangle</a>, ' +
	'<a href="http://www.w3.org/TR/SVG11/images/shapes/rect02.svg" target="_blank">rounded rectangle</a>, ' +
	'<a href="http://www.w3.org/TR/SVG11/images/shapes/circle01.svg" target="_blank">circle</a>, ' +
	'<a href="http://www.w3.org/TR/SVG11/images/shapes/ellipse01.svg" target="_blank">ellipse</a>, ' +
	'<a href="http://www.w3.org/TR/SVG11/images/shapes/line01.svg" target="_blank">line</a>, ' +
	'<a href="http://www.w3.org/TR/SVG11/images/shapes/polyline01.svg" target="_blank">polyline</a>, ' +
	'and <a href="http://www.w3.org/TR/SVG11/images/shapes/polygon01.svg" target="_blank">polygon</a>.',
	'<rect x="20" y="50" width="100" height="50"\r\n' +
	'    fill="yellow" stroke="navy" stroke-width="5"  />\r\n' +
	'<rect x="150" y="50" width="100" height="50" rx="10"\r\n' +
	'    fill="green" />\r\n' +
	'<g transform="translate(270 80) rotate(-30)">\r\n' +
	'  <rect x="0" y="0" width="100" height="500" rx="10"\r\n' +
	'      fill="none" stroke="purple" stroke-width="3" />\r\n' +
	'</g>\r\n' +
	'<circle cx="70" cy="220" r="50"\r\n' +
	'    fill="red" stroke="blue" stroke-width="5"  />\r\n' +
	'<g transform="translate(175 220)">\r\n' +
	'  <ellipse rx="75" ry="50" fill="red"  />\r\n' +
	'</g>\r\n' +
	'<ellipse transform="translate(300 220) rotate(-30)"\r\n' +
	'    rx="75" ry="50" fill="none" stroke="blue" stroke-width="10"  />\r\n' +
	'<g stroke="green" >\r\n' +
	'  <line x1="450" y1="120" x2="550" y2="20" stroke-width="5"  />\r\n' +
	'  <line x1="550" y1="120" x2="650" y2="20" stroke-width="10"  />\r\n' +
	'  <line x1="650" y1="120" x2="750" y2="20" stroke-width="15"  />\r\n' +
	'  <line x1="750" y1="120" x2="850" y2="20" stroke-width="20"  />\r\n' +
	'  <line x1="850" y1="120" x2="950" y2="20" stroke-width="25"  />\r\n' +
	'</g>\r\n' +
	'<polyline fill="none" stroke="blue" stroke-width="5" \r\n' +
	'    points="450,250\r\n' +
	'            475,250 475,220 500,220 500,250\r\n' +
	'            525,250 525,200 550,200 550,250\r\n' +
	'            575,250 575,180 600,180 600,250\r\n' +
	'            625,250 625,160 650,160 650,250\r\n' +
	'            675,250" />\r\n' +
	'<polygon fill="lime" stroke="blue" stroke-width="10" \r\n' +
	'    points="800,150 900,180 900,240 800,270 700,240 700,180" />'],
	
	['Filters', filterDemo,
	'This example relies on the <i>filter</i> extension for the SVG plugin.<br/>' +
	'1.  Filter primitive \'feGaussianBlur\' takes input SourceAlpha, ' +
	'which is the alpha channel of the source graphic. The result is ' +
	'stored in a temporary buffer named "blur". Note that "blur" is ' +
	'used as input to both filter primitives 2 and 3.<br/>' +
	'2. Filter primitive \'feOffset\' takes buffer "blur", shifts the ' +
	'result in a positive direction in both x and y, and creates a new ' +
	'buffer named "offsetBlur". The effect is that of a drop shadow.<br/>' +
	'3. Filter primitive \'feSpecularLighting\', uses buffer "blur" as a ' +
	'model of a surface elevation and generates a lighting effect from a ' +
	'single point source. The result is stored in buffer "specOut".<br/>' +
	'4. Filter primitive \'feComposite\' masks out the result of filter ' +
	'primitive 3 by the original source graphics alpha channel so that ' +
	'the intermediate result is no bigger than the original source graphic.<br/>' +
	'5. Filter primitive \'feComposite\' composites the result of the ' +
	'specular lighting with the original source graphic.<br/>' +
	'6. Filter primitive \'feMerge\' composites two layers together. ' +
	'The lower layer consists of the drop shadow result from filter primitive 2. ' +
	'The upper layer consists of the specular lighting result from filter primitive 5.<br/>' +
	'See the <a href="http://www.w3.org/TR/SVG11/images/filters/filters01.svg" target="_blank">original document</a>.',
	'<desc>An example which combines multiple filter primitives\r\n' +
	'    to produce a 3D lighting effect on a graphic consisting\r\n' +
	'    of the string "SVG" sitting on top of oval filled in red\r\n' +
	'    and surrounded by an oval outlined in red.</desc>\r\n' +
	'<defs>\r\n' +
	'  <filter id="MyFilter" filterUnits="userSpaceOnUse" x="0" y="0" width="200" height="120">\r\n' +
	'    <feGaussianBlur in="SourceAlpha" stdDeviation="4" result="blur"/>\r\n' +
	'    <feOffset in="blur" dx="4" dy="4" result="offsetBlur"/>\r\n' +
	'    <feSpecularLighting in="blur" surfaceScale="5" specularConstant=".75" \r\n' +
	'        specularExponent="20" lighting-color="#bbbbbb"  \r\n' +
	'        result="specOut">\r\n' +
	'      <fePointLight x="-5000" y="-10000" z="20000"/>\r\n' +
	'    </feSpecularLighting>\r\n' +
	'    <feComposite in="specOut" in2="SourceAlpha" operator="in" result="specOut"/>\r\n' +
	'    <feComposite in="SourceGraphic" in2="specOut" operator="arithmetic" \r\n' +
	'        k1="0" k2="1" k3="1" k4="0" result="litPaint"/>\r\n' +
	'    <feMerge>\r\n' +
	'      <feMergeNode in="offsetBlur"/>\r\n' +
	'      <feMergeNode in="litPaint"/>\r\n' +
	'    </feMerge>\r\n' +
	'  </filter>\r\n' +
	'</defs>\r\n' +
	'<rect x="1" y="1" width="198" height="118" fill="#888888" stroke="blue" />\r\n' +
	'<g filter="url(#MyFilter)" >\r\n' +
	'  <g>\r\n' +
	'    <path fill="none" stroke="#D90000" stroke-width="10" \r\n' +
	'        d="M50,90 C0,90 0,30 50,30 L150,30 C200,30 200,90 150,90 z" />\r\n' +
	'    <path fill="#D90000" \r\n' +
	'        d="M60,80 C30,80 30,40 60,40 L140,40 C170,40 170,80 140,80 z" />\r\n' +
	'    <g fill="#FFFFFF" stroke="black" font-size="45" font-family="Verdana" >\r\n' +
	'      <text x="52" y="76">SVG</text>\r\n' +
	'    </g>\r\n' +
	'  </g>\r\n' +
	'</g>'],
	
	['Gradients and Patterns', gradientPatternDemo,
	'Shows how to fill a rectangle by referencing a radial gradient paint server.<br/>' +
	'Shows how to fill a rectangle by referencing a pattern paint server. ' +
	'Note how the blue stroke of each triangle has been clipped at the top and the left. ' +
	'This is due to SVG\'s user agent style sheet setting the \'overflow\' property ' +
	'for \'pattern\' elements to hidden, which causes the pattern to be clipped to ' +
	'the bounds of the pattern tile.<br/>' +
	'See the original documents: <a href="http://www.w3.org/TR/SVG11/images/pservers/radgrad01.svg" target="_blank">gradient</a> ' +
	'and <a href="http://www.w3.org/TR/SVG11/images/pservers/pattern01.svg" target="_blank">pattern</a>.',
	'<desc>Example radgrad01 - fill a rectangle by referencing a\r\n' +
	'    radial gradient paint server</desc>\r\n' +
	'<g>\r\n' +
	'  <defs>\r\n' +
	'    <radialGradient id="MyGradient" gradientUnits="userSpaceOnUse"\r\n' +
	'        cx="200" cy="100" r="150" fx="200" fy="100">\r\n' +
	'      <stop offset="0%" stop-color="red" />\r\n' +
	'      <stop offset="50%" stop-color="blue" />\r\n' +
	'      <stop offset="100%" stop-color="red" />\r\n' +
	'    </radialGradient>\r\n' +
	'  </defs>\r\n' +
	'  <!-- The rectangle is filled using a radial gradient paint server -->\r\n' +
	'  <rect fill="url(#MyGradient)" stroke="black" stroke-width="5"\r\n' +
	'      x="50" y="50" width="300" height="100"/>\r\n' +
	'</g>\r\n' + 
	'<g>\r\n' +
	'  <defs>\r\n' +
	'    <pattern id="TrianglePattern" patternUnits="userSpaceOnUse"\r\n' +
	'        x="0" y="0" width="100" height="100" viewBox="0 0 10 10" >\r\n' +
	'      <path d="M 0 0 L 7 0 L 3.5 7 z" fill="red" stroke="blue" />\r\n' +
	'    </pattern> \r\n' +
	'  </defs>\r\n' +
	'  <!-- The ellipse is filled using a triangle pattern paint server\r\n' +
	'       and stroked with black -->\r\n' +
	'  <ellipse fill="url(#TrianglePattern)" stroke="black" stroke-width="5"  \r\n' +
	'      cx="550" cy="100" rx="175" ry="75" />\r\n' +
	'</g>'],
	
	['Interactivity', interactiveDemo,
	'This example defines a function <code>circle_click</code> which is called ' +
	'by the onclick event attribute on the \'circle\' element. Each click toggles ' +
	'the circle\'s size between small and large.<br/>' +
	'See the <a href="http://www.w3.org/TR/SVG11/images/script/script01.svg" target="_blank">original document</a>.',
	'<desc>Example script01 - invoke an ECMAScript function from an onclick event\r\n' +
	'</desc>\r\n' +
	'<!-- ECMAScript to change the radius with each click -->\r\n' +
	'<script type="text/ecmascript"> <![CDATA[\r\n' +
	'  function circle_click(evt) {\r\n' +
	'    var circle = evt.target;\r\n' +
	'    var currentRadius = circle.getAttribute("r");\r\n' +
	'    if (currentRadius == 100)\r\n' +
	'      circle.setAttribute("r", currentRadius*2);\r\n' +
	'    else\r\n' +
	'      circle.setAttribute("r", currentRadius*0.5);\r\n' +
	'  }\r\n' +
	']]> </script>\r\n' +
	'<!-- Act on each click event -->\r\n' +
	'<circle onclick="circle_click(evt)" cx="300" cy="150" r="100"\r\n' +
	'    fill="red"/>\r\n' +
	'<text x="300" y="280" \r\n' +
	'    font-family="Verdana" font-size="35" text-anchor="middle">\r\n' +
	'  Click on circle to change its size\r\n' +
	'</text>'],
	
	['Masking', maskingDemo,
	'In SVG, you can specify that any other graphics object or \'g\' element ' +
	'can be used as an alpha mask for compositing the current object into the background.<br/>' +
	'See the <a href="http://www.w3.org/TR/SVG11/images/masking/mask01.svg" target="_blank">original document</a>.',
	'<desc>Example mask01 - blue text masked with gradient against red background\r\n' +
	'</desc>\r\n' +
	'<defs>\r\n' +
	'  <linearGradient id="Gradient" gradientUnits="userSpaceOnUse"\r\n' +
	'      x1="0" y1="0" x2="800" y2="0">\r\n' +
	'    <stop offset="0" stop-color="white" stop-opacity="0" />\r\n' +
	'    <stop offset="1" stop-color="white" stop-opacity="1" />\r\n' +
	'  </linearGradient>\r\n' +
	'  <mask id="Mask" maskUnits="userSpaceOnUse"\r\n' +
	'       x="0" y="0" width="800" height="300">\r\n' +
	'    <rect x="0" y="0" width="800" height="300" fill="url(#Gradient)"  />\r\n' +
	'  </mask>\r\n' +
	'  <text id="Text" x="400" y="200" \r\n' +
	'      font-family="Verdana" font-size="100" text-anchor="middle" >\r\n' +
	'    Masked text\r\n' +
	'  </text>\r\n' +
	'</defs>\r\n' +
	'<!-- Draw a pale red rectangle in the background -->\r\n' +
	'<rect x="0" y="0" width="800" height="300" fill="#FF8080" />\r\n' +
	'<!-- Draw the text string twice. First, filled blue, with the mask applied.\r\n' +
	'     	Second, outlined in black without the mask. -->\r\n' +
	'<use xlink:href="#Text" fill="blue" mask="url(#Mask)" />\r\n' +
	'<use xlink:href="#Text" fill="none" stroke="black" stroke-width="2" />'],
	
	['Styles and References', useStyleDemo,
	'Illustrates a \'use\' element with various methods of applying CSS styling.<br/>' +
	'See the <a href="http://www.w3.org/TR/SVG11/images/struct/Use04.svg" target="_blank">original document</a>.', 
	'<desc>Example Use04 - \'use\' with CSS styling</desc>\r\n' +
	'<defs style=" /* rule 9 */ stroke-miterlimit: 10" >\r\n' +
	'  <path id="MyPath" d="M100 50 L700 50 L700 250 L100 250"\r\n' +
	'    class="MyPathClass" style=" /* rule 10 */ stroke-dasharray:300,100" />\r\n' +
	'</defs>\r\n' +
	'<style type="text/css">\r\n' +
	'  <![CDATA[\r\n' +
	'    /* rule 1 */ #MyUse { fill: blue }\r\n' +
	'    /* rule 2 */ #MyPath { stroke: red }\r\n' +
	'    /* rule 3 */ use { fill-opacity: .5 }\r\n' +
	'    /* rule 4 */ path { stroke-opacity: .5 }\r\n' +
	'    /* rule 5 */ .MyUseClass { stroke-linecap: round }\r\n' +
	'    /* rule 6 */ .MyPathClass { stroke-linejoin: bevel }\r\n' +
	'    /* rule 7 */ use > path { shape-rendering: optimizeQuality }\r\n' +
	'    /* rule 8 */ g > path { visibility: hidden }\r\n' +
	'  ]]>\r\n' +
	'</style>\r\n' +
	'<g style=" /* rule 11 */ stroke-width:40">\r\n' +
	'  <use id="MyUse" xlink:href="#MyPath" \r\n' +
	'    class="MyUseClass" style="/* rule 12 */ stroke-dashoffset:50" />\r\n' +
	'</g>'],
	
	['Text', textDemo,
	'Shows how \'tspan\' elements can be included within \'textPath\' ' +
	'elements to adjust styling attributes and adjust the current text ' +
	'position before rendering a particular glyph. The first occurrence ' +
	'of the word "up" is filled with the color red. Attribute dy is used ' +
	'to lift the word "up" from the baseline.<br/>' +
	'See the <a href="http://www.w3.org/TR/SVG11/images/text/toap02.svg" target="_blank">original document</a>.',
	'<defs>\r\n' +
	'  <path id="MyPath"\r\n' +
	'      d="M 100 200 \r\n' +
	'         C 200 100 300   0 400 100\r\n' +
	'         C 500 200 600 300 700 200\r\n' +
	'         C 800 100 900 100 900 100" />\r\n' +
	'</defs>\r\n' +
	'<desc>Example toap02 - tspan within textPath</desc>\r\n' +
	'<use xlink:href="#MyPath" fill="none" stroke="red"  />\r\n' +
	'<text font-family="Verdana" font-size="42.5" fill="blue" >\r\n' +
	'  <textPath xlink:href="#MyPath">\r\n' +
	'    We go \r\n' +
	'    <tspan dy="-30" fill="red" >\r\n' +
	'      up\r\n' +
	'    </tspan>\r\n' +
	'    <tspan dy="30">\r\n' +
	'      ,\r\n' +
	'    </tspan>\r\n' +
	'    then we go down, then up again\r\n' +
	'  </textPath>\r\n' +
	'</text>'],
	
	['Transformations', transformDemo,
	'Defines two coordinate systems which are skewed ' +
	'relative to the origin coordinate system.<br/>' +
	'Transformations can be nested to any level. The effect of nested ' +
	'transformations is to post-multiply (i.e., concatenate) the subsequent ' +
	'transformation matrices onto previously defined transformations.<br/>' +
	'See the original documents: <a href="http://www.w3.org/TR/SVG11/images/coords/Skew.svg" target="_blank">skew</a> ' +
	'and <a href="http://www.w3.org/TR/SVG11/images/coords/Nested.svg" target="_blank">nesting</a>.',
	'<desc>Example Skew - Show effects of skewX and skewY</desc>\r\n' +
	'<!-- Establish a new coordinate system whose origin is at (30,100)\r\n' +
	'     in the initial coord. system and which is skewed in X by 30 degrees. -->\r\n' +
	'<g transform="translate(30,100)">\r\n' +
	'  <g transform="skewX(30)">\r\n' +
	'    <g fill="none" stroke="red" stroke-width="3" >\r\n' +
	'      <line x1="0" y1="0" x2="50" y2="0" />\r\n' +
	'      <line x1="0" y1="0" x2="0" y2="50" />\r\n' +
	'    </g>\r\n' +
	'    <text x="0" y="0" font-size="20" font-family="Verdana" fill="blue" >\r\n' +
	'      ABC (skewX)\r\n' +
	'    </text>\r\n' +
	'  </g>\r\n' +
	'</g>\r\n' +
	'<!-- Establish a new coordinate system whose origin is at (200,100)\r\n' +
	'     in the initial coord. system and which is skewed in Y by 30 degrees. -->\r\n' +
	'<g transform="translate(200,100)">\r\n' +
	'  <g transform="skewY(30)">\r\n' +
	'    <g fill="none" stroke="red" stroke-width="3" >\r\n' +
	'      <line x1="0" y1="0" x2="50" y2="0" />\r\n' +
	'      <line x1="0" y1="0" x2="0" y2="50" />\r\n' +
	'    </g>\r\n' +
	'    <text x="0" y="0" font-size="20" font-family="Verdana" fill="blue" >\r\n' +
	'      ABC (skewY)\r\n' +
	'    </text>\r\n' +
	'  </g>\r\n' +
	'</g>\r\n' +
	'<!-- First, a translate -->\r\n' +
	'<g transform="translate(450,150)">\r\n' +
	'  <g fill="none" stroke="red" stroke-width="3" >\r\n' +
	'    <line x1="0" y1="0" x2="50" y2="0" />\r\n' +
	'    <line x1="0" y1="0" x2="0" y2="50" />\r\n' +
	'  </g>\r\n' +
	'  <text x="0" y="0" font-size="16" font-family="Verdana" >\r\n' +
	'    ....Translate(1)\r\n' +
	'  </text>\r\n' +
	'  <!-- Second, a rotate -->\r\n' +
	'  <g transform="rotate(-45)">\r\n' +
	'    <g fill="none" stroke="green" stroke-width="3" >\r\n' +
	'      <line x1="0" y1="0" x2="50" y2="0" />\r\n' +
	'      <line x1="0" y1="0" x2="0" y2="50" />\r\n' +
	'    </g>\r\n' +
	'    <text x="0" y="0" font-size="16" font-family="Verdana" >\r\n' +
	'      ....Rotate(2)\r\n' +
	'    </text>\r\n' +
	'    <!-- Third, another translate -->\r\n' +
	'    <g transform="translate(130,160)">\r\n' +
	'      <g fill="none" stroke="blue" stroke-width="3" >\r\n' +
	'        <line x1="0" y1="0" x2="50" y2="0" />\r\n' +
	'        <line x1="0" y1="0" x2="0" y2="50" />\r\n' +
	'      </g>\r\n' +
	'      <text x="0" y="0" font-size="16" font-family="Verdana" >\r\n' +
	'        ....Translate(3)\r\n' +
	'      </text>\r\n' +
	'    </g>\r\n' +
	'  </g>\r\n' +
	'</g>']];

// Populate the examples drop-down
function initExamples() {
	var html = '<option value=""></option>';
	for (var i = 0; i < examples.length; i++) {
		html += '<option value="' + i + '">' + examples[i][0] + '</option>';
	}
	$('#example').html(html).change(pickExample)[0].selectedIndex = 0;
}

// Display the selected example
function pickExample() {
	var ex = $('#example').val();
	if (!ex) {
		return;
	}
	$('#exampledesc').html(examples[ex][2]);
	$('#svgsource pre').text(examples[ex][3]);
	$('#svgcode pre').text(codeFormat(examples[ex][1].toString()));
	var svg = svgManager.getSVGFor('#svgexample');
	svg.clear();
	examples[ex][1](svg);
}

// Format the JavaScript SVG code for display
function codeFormat(code) {
	var lines = code.split('\n');
	var formatted = '';
	for (var i = 0; i < lines.length; i++) {
		var line = $.trim(lines[i]);
		if (!line || line.length == 1 || line.substring(0, 9) == 'function ') {
			continue;
		}
		while (line.length > 50) {
			var pos = line.substr(0, 50).lastIndexOf(' ');
			if (pos == -1) {
				break;
			}
			formatted += line.substr(0, pos) + '\r\n  ' + ($.browser.msie ? '  ' : '');
			line = line.substr(pos + 1);
		}
		formatted += line + '\r\n';
	}
	return formatted;
}

// Demonstrate basic SVG shapes and constructs
function basicShapesDemo(svg) {
	svg.rect(null, 20, 50, 100, 50, 
		{fill: 'yellow', stroke: 'navy', stroke_width: 5});
	svg.roundrect(null, 150, 50, 100, 50, 10, 10, {fill: 'green'});
	var g = svg.group(null, {transform: 'translate(270 80) rotate(-30)'});
	svg.roundrect(g, 0, 0, 100, 50, 10, 10, {fill: 'none', stroke: 'purple', stroke_width: 3});
	svg.circle(null, 70, 220, 50, {fill: 'red', stroke: 'blue', stroke_width: 5});
	var g = svg.group(null, {transform: 'translate(175 220)'});
	svg.ellipse(g, '', '', 75, 50, {fill: 'yellow'});
	svg.ellipse(null, '', '', 75, 50, {transform: 'translate(300 220) rotate(-30)', 
		fill: 'none', stroke: 'blue', stroke_width: 10});
	var g = svg.group(null, {stroke: 'green'});
	svg.line(g, 450, 120, 550, 20, {stroke_width: 5});
	svg.line(g, 550, 120, 650, 20, {stroke_width: 10});
	svg.line(g, 650, 120, 750, 20, {stroke_width: 15});
	svg.line(g, 750, 120, 850, 20, {stroke_width: 20});
	svg.line(g, 850, 120, 950, 20, {stroke_width: 25});
	svg.polyline(null, [[450,250],
		[475,250],[475,220],[500,220],[500,250],
		[525,250],[525,200],[550,200],[550,250],
		[575,250],[575,180],[600,180],[600,250],
		[625,250],[625,160],[650,160],[650,250],[675,250]],
		{fill: 'none', stroke: 'blue', stroke_width: 5});
	svg.polygon(null, [[800,150],[900,180],[900,240],[800,270],[700,240],[700,180]], 
		{fill: 'lime', stroke: 'blue', stroke_width: 10});
}

// Demonstrate SVG filter effects
function filterDemo(svg) {
	svg.describe(null, 'An example which combines multiple filter primitives ' +
		'to produce a 3D lighting effect on a graphic consisting ' +
		'of the string "SVG" sitting on top of oval filled in red ' +
		'and surrounded by an oval outlined in red.');
	var defs = svg.defs();
	var filter = svg.filter(defs, 'MyFilter', 0, 0, 200, 120, 
		{filterUnits: 'userSpaceOnUse'});
	svg.filters.gaussianBlur(filter, 'blur', 'SourceAlpha', 4);
	svg.filters.offset(filter, 'offsetBlur', 'blur', 4, 4);
	var spec = svg.filters.specularLighting(filter, 'specOut', 'blur', 
		5, 0.75, 20, {lighting_color: '#bbbbbb'});
	svg.filters.pointLight(spec, '', -5000, -10000, 20000);
	svg.filters.composite(filter, 'specOut', 'in', 'specOut', 'SourceAlpha');
	svg.filters.composite(filter, 'litPaint', 'arithmetic', 'SourceGraphic', 
		'specOut', 0, 1, 1, 0);
	var merge = svg.filters.merge(filter, '', ['offsetBlur', 'litPaint']);
	var g1 = svg.group(null, {filter: 'url(#MyFilter)'});
	var g2 = svg.group(g1);
	var path = svg.createPath();
	svg.path(g2, path.moveTo(50, 90).curveCTo(0, 90, 0, 30, 50, 30).
		lineTo(150, 30).curveCTo(200, 30, 200, 90, 150, 90).close(), 
		{fill: 'none', stroke: '#D90000', stroke_width: 10});
	svg.path(g2, path.reset().moveTo(60, 80).curveCTo(30, 80, 30, 40, 60, 40).
		lineTo(140, 40).curveCTo(170, 40, 170, 80, 140, 80).close(), 
		{fill: '#D90000'});
	var g3 = svg.group(g2, {fill: '#FFFFFF', stroke: 'black', 
		font_size: 45, font_family: 'Verdana'});
	svg.text(g3, 52, 76, 'SVG');
}

// Demonstrate SVG gradient and pattern fills
function gradientPatternDemo(svg) {
	svg.describe(null, 'Example radgrad01 - fill a rectangle by ' +
		'referencing a radial gradient paint server');
	var g = svg.group();
	var defs = svg.defs(g);
	svg.radialGradient(defs, 'MyGradient', 
		[['0%', 'red'], ['50%', 'blue'], ['100%', 'red']],
		200, 100, 150, 200, 100, {gradientUnits: 'userSpaceOnUse'});
	svg.rect(g, 50, 50, 300, 100, 
		{fill: 'url(#MyGradient)', stroke: 'black', stroke_width: 5});
	g = svg.group();
	defs = svg.defs(g);
	var ptn = svg.pattern(defs, 'TrianglePattern', 0, 0, 100, 100, 
		0, 0, 10, 10, {patternUnits: 'userSpaceOnUse'});
	var path = svg.createPath();
	svg.path(ptn, path.moveTo(0, 0).lineTo([[7, 0], [3.5, 7]]).close(), 
		{fill: 'red', stroke: 'blue'});
	svg.ellipse(g, 550, 100, 175, 75, 
		{fill: 'url(#TrianglePattern)', stroke: 'black', stroke_width: 5});
}

// Demonstrate SVG interactivity
function interactiveDemo(svg) {
	svg.describe(null, 'Example script01 - invoke an ECMAScript function from an onclick event');
	svg.script(null, 'function circle_click(evt) {\n' +
		'  var circle = evt.target;\n' +
		'  var currentRadius = circle.getAttribute("r");\n' +
		'  if (currentRadius == 100)\n' +
		'    circle.setAttribute("r", currentRadius*2);\n' +
		'  else\n' +
		'    circle.setAttribute("r", currentRadius*0.5);\n' +
		'}', 'text/ecmascript');
	svg.circle(null, 300, 150, 100, {onclick: 'circle_click(evt)', fill: 'red'});
	svg.text(null, 300, 280, 'Click on circle to change its size', 
		{font_family: 'Verdana', font_size: 35,  text_anchor: 'middle'});
}

// Demonstrate SVG masking operations
function maskingDemo(svg) {
	svg.describe(null, 'Example mask01 - blue text masked with gradient against red background');
	var defs = svg.defs();
	svg.linearGradient(defs, 'Gradient', [[0, 'white', 0], [1, 'white', 1]], 
		0, 0, 800, 0, {gradientUnits: 'userSpaceOnUse'});
	var mask = svg.mask(defs, 'Mask', 0, 0, 800, 300, {maskUnits: 'userSpaceOnUse'});
	svg.rect(mask, 0, 0, 800, 300, {fill: 'url(#Gradient)'});
	svg.text(defs, 400, 200, 'Masked text', {id: 'Text', 
		font_family: 'Verdana', font_size: 100, text_anchor: 'middle'});
	svg.rect(null, 0, 0, 800, 300, {fill: '#FF8080'});
	svg.use(null, '#Text', {fill: 'blue', mask: 'url(#Mask)'});
	svg.use(null, '#Text', {fill: 'none', stroke: 'black', stroke_width: 2});
}

// Demonstrate SVG text rendering
function textDemo(svg) {
	var defs = svg.defs();
	var path = svg.createPath();
	svg.path(defs, path.moveTo(100, 200).curveCTo([[200, 100, 300, 0, 400, 100], 
		[500, 200, 600, 300, 700, 200], [800, 100, 900, 100, 900, 100]]), 
		{id: 'MyPath'});
	svg.describe(null, 'Example toap02 - tspan within textPath');
	svg.use(null, '#MyPath', {fill: 'none', stroke: 'red'});
	var text = svg.text(null, '', 
		{font_family: 'Verdana', font_size: '42.5', fill: 'blue'});
	var texts = svg.createText();
	svg.textpath(text, '#MyPath', texts.string('We go ').span('up', {dy: -30, fill: 'red'}).
		span(',', {dy: 30}).string(' then we go down, then up again'));
}

// Demonstrate SVG transformation support
function transformDemo(svg) {
	svg.describe(null, 'Example Skew - Show effects of skewX and skewY');
	var g1 = svg.group(null, {transform: 'translate(30,100)'});
	var g2 = svg.group(g1, {transform: 'skewX(30)'});
	var g3 = svg.group(g2, {fill: 'none', stroke: 'red', stroke_width: 3});
	svg.line(g3, 0, 0, 50, 0);
	svg.line(g3, 0, 0, 0, 50);
	svg.text(g2, 0, 0, 'ABC (skewX)', 
		{font_size: 20, font_family: 'Verdana', fill: 'blue'});
	g1 = svg.group(null, {transform: 'translate(200,100)'});
	g2 = svg.group(g1, {transform: 'skewY(30)'});
	g3 = svg.group(g2, {fill: 'none', stroke: 'red', stroke_width: 3});
	svg.line(g3, 0, 0, 50, 0);
	svg.line(g3, 0, 0, 0, 50);
	svg.text(g2, 0, 0, 'ABC (skewY)', 
		{font_size: 20, font_family: 'Verdana', fill: 'blue'});
		
	g1 = svg.group(null, {transform: 'translate(450,150)'});
	g2 = svg.group(g1, {fill: 'none', stroke: 'red', stroke_width: 3});
	svg.line(g2, 0, 0, 50, 0);
	svg.line(g2, 0, 0, 0, 50);
	svg.text(g1, 0, 0, '....Translate(1)',
		{font_size: 16, font_family: 'Verdana'});
	g2 = svg.group(g1, {transform: 'rotate(-45)'});
	g3 = svg.group(g2, {fill: 'none', stroke: 'green', stroke_width: 3});
	svg.line(g3, 0, 0, 50, 0);
	svg.line(g3, 0, 0, 0, 50);
	svg.text(g2, 0, 0, '....Rotate(2)', 
		{font_size: 16, font_family: 'Verdana'});
	g3 = svg.group(g2, {transform: 'translate(130,160)'});
	var g4 = svg.group(g3, {fill: 'none', stroke: 'blue', stroke_width: 3});
	svg.line(g4, 0, 0, 50, 0);
	svg.line(g4, 0, 0, 0, 50);
	svg.text(g3, 0, 0, '....Translate(3)', 
		{font_size: 16, font_family: 'Verdana'});
}

// Demonstrate SVG referencing and CSS styling
function useStyleDemo(svg) {
	svg.describe(null, 'Example Use04 - \'use\' with CSS styling');
	var defs = svg.defs(null, '', {style: ' /* rule 9 */ stroke-miterlimit: 10'});
	var path = svg.createPath();
	svg.path(defs, path.moveTo(100, 50).lineTo([[700, 50], [700, 250], [100, 250]]),
		{id: 'MyPath', _class: 'MyPathClass', style: ' /* rule 10 */ stroke-dasharray: 300,100'});
	svg.style(null, '/* rule 1 */ #MyUse { fill: blue } ' +
		'/* rule 2 */ #MyPath { stroke: red } ' +
		'/* rule 3 */ use { fill-opacity: .5 } ' +
		'/* rule 4 */ path { stroke-opacity: .5 } ' +
		'/* rule 5 */ .MyUseClass { stroke-linecap: round } ' +
		'/* rule 6 */ .MyPathClass { stroke-linejoin: bevel } ' +
		'/* rule 7 */ use > path { shape-rendering: optimizeQuality } ' +
		'/* rule 8 */ g > path { visibility: hidden }');
	var g = svg.group(null, {style: ' /* rule 11 */ stroke-width: 40'});
	svg.use(g, '#MyPath', {id: 'MyUse', _class: 'MyUseClass', 
		style: '/* rule 12 */ stroke-dashoffset: 50'});
}

// -----------------------------------------------------------------------------

// Add a node defined inline
function addInline() {
	var svg = svgManager.getSVGFor('#svgload');
	svg.add(null, '#svg1');
}

// Load an external document
function loadExternal() {
	var svg = svgManager.getSVGFor('#svgload');
	svg.load($('#loadURL').val());
}

// -----------------------------------------------------------------------------

// Synchronise the drawing section with user selection
function setDrawOptions() {
	showHide = function(id, show) {
		if (show) {
			$(id).show();
		}
		else {
			$(id).hide();
		}
	}
	var shape = $('#shape').val();
	showHide('#getRect', (shape == 'rect' || shape == 'roundrect'));
	showHide('#getRounded', shape == 'roundrect');
	showHide('#getCentre', (shape == 'circle' || shape == 'ellipse'));
	showHide('#getRadius', (shape == 'circle'));
	showHide('#getRadii', (shape == 'ellipse'));
	showHide('#getLine', (shape == 'line'));
	showHide('#getFill', (shape != 'line'));
}

var drawNodes = [];
var sketchpad = null;

$(document).ready(function() {
	sketchpad = $('#svgsketch')[0];
});

// Draw the selected element on the canvas
function draw() {
	var svg = svgManager.getSVGFor(sketchpad);
	var rotate = $('#rotate').val();
	var settings = $.extend({fill: $('#fill').val(), 
		stroke: $('#stroke').val(), stroke_width: $('#swidth').val()}, 
		(rotate ? {transform: 'rotate(' + rotate + ')'} : {}));
	var shape = $('#shape').val();
	var node = null;
	if (shape == 'rect') {
		node = svg.rect(null, $('#left').val(), $('#top').val(), 
			$('#width').val(), $('#height').val(), settings);
	}
	else if (shape == 'roundrect') {
		node = svg.roundrect(null, $('#left').val(), $('#top').val(), 
			$('#width').val(), $('#height').val(), 
			$('#roundX').val(), $('#roundY').val(), settings);
	}
	else if (shape == 'circle') {
		node = svg.circle(null, $('#centreX').val(), $('#centreY').val(), 
			$('#radius').val(), settings);
	}
	else if (shape == 'ellipse') {
		node = svg.ellipse(null, $('#centreX').val(), $('#centreY').val(), 
			$('#radiusX').val(), $('#radiusY').val(), settings);
	}
	else if (shape == 'line') {
		node = svg.line(null, $('#startX').val(), $('#startY').val(), 
			$('#endX').val(), $('#endY').val(), settings);
	}
	drawNodes[drawNodes.length] = node;
}

// Remove the last drawn element
function undo() {
	if (!drawNodes.length) {
		return;
	}
	var svg = svgManager.getSVGFor(sketchpad);
	svg.remove(drawNodes[drawNodes.length - 1]);
	drawNodes.splice(drawNodes.length - 1, 1);
}

// Clear the canvas
function erase(name) {
	svgManager.getSVGFor($(name)).clear();
	drawNodes = [];
}

// -----------------------------------------------------------------------------

// Initialise the graphing options
function setGraphOptions() {
	var html = '';
	var chartTypes = svgGraphing.chartTypes();
	for (var id in chartTypes) {
		html += '<option value="' + id + '">' + chartTypes[id].title() + '</option>';
	}
	$('#chartType').html(html)[0].selectedIndex = 0;
}

var firstGraph = true;
var chartArea = [[0.1, 0.1, 0.95, 0.9], [0.2, 0.1, 0.95, 0.9],
	[0.1, 0.1, 0.8, 0.9], [0.1, 0.25, 0.9, 0.9], [0.1, 0.1, 0.9, 0.8]];
var legendArea = [[0.0, 0.0, 0.0, 0.0], [0.005, 0.1, 0.125, 0.5],
	[0.875, 0.1, 0.995, 0.5], [0.2, 0.1, 0.8, 0.2], [0.2, 0.9, 0.8, 0.995]];
var fills = [['lightblue', 'url(#fadeBlue)'], ['pink', 'url(#fadeRed)'],
	['lightgreen', 'url(#fadeGreen)']];

// Draw a new graph with the selected options
function graphIt() {
	var svg = svgManager.getSVGFor('#svggraph');
	if (firstGraph) {
		var defs = svg.defs();
		svg.linearGradient(defs, 'fadeBlue', [[0, 'lightblue'], [1, 'blue']]);
		svg.linearGradient(defs, 'fadeRed', [[0, 'pink'], [1, 'red']]);
		svg.linearGradient(defs, 'fadeGreen', [[0, 'lightgreen'], [1, 'green']]);
		svg.graph.noDraw().title('Browser Usage').
			addSeries('IE', [95.97, 91.80, 88.16, 86.64], 'lightblue', 'blue', 3).
			addSeries('Netscape', [3.39, 2.83, 1.61, 0.00], 'pink', 'red', 3).
			addSeries('Firefox', [0.00, 4.06, 8.13, 9.95], 'lightgreen', 'green', 3).
			chartFormat('lightyellow', 'gray').
			gridlines({stroke: 'gray', stroke_dasharray: '2,2'}, 'gray').
			status(setStatus);
		svg.graph.xAxis.title('Year').scale(0, 3).
			ticks(1, 0).labels(['2002', '2004', '2005', '2006']);
		svg.graph.yAxis.title('Percentage').scale(-5, 105).ticks(10, 5);
		svg.graph.legend.settings({fill: 'lightgoldenrodyellow', stroke: 'gray'});
		firstGraph = false;
	}
	var chartType = $('#chartType').val();
	var legendPos = $('#legendPos').val() - 0;
	var seriesFill = ($('#seriesFill').val() == 'plain' ? 0 : 1);
	svg.graph.legend.show(legendPos).area(legendArea[legendPos]);
	for (var i = 0; i < 3; i++) {
		svg.graph.series()[i].format((fills[i])[seriesFill]);
	}
	svg.graph.noDraw().chartArea(chartArea[legendPos]).
		chartType(chartType, {explode: [2], explodeDist: 10}).redraw();
	chartType = svgGraphing.chartTypes()[chartType];
	$('#graphDesc').text(chartType.description());
	var options = '';
	for (var i = 0; i < chartType.options().length; i++) {
		options += '<li>' + chartType.options()[i] + '</li>';
	}
	$('#graphOptions').html(options || '<li>None</li>');
}

// Show the status values in a callback from the graph
function setStatus(value) {
	window.status = value;
}