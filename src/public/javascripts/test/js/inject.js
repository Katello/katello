(function(){

	var DEBUG = false;
        // hold each test run as row 
        var testresults = [];

	var doPost = false;

	try {
		doPost = !!window.top.postMessage;
	} catch(e){}

	var search = window.location.search,
		url, index;
	if( ( index = search.indexOf( "swarmURL=" ) ) != -1 )
		url = decodeURIComponent( search.slice( index + 9 ) );

	if ( !DEBUG && (!url || url.indexOf("http") !== 0) ) {
		return;
	}

	var submitTimeout = 5;

	var curHeartbeat;
	var beatRate = 20;

	// Expose the TestSwarm API
	window.TestSwarm = {
		submit: submit,
		heartbeat: function(){
			if ( curHeartbeat ) {
				clearTimeout( curHeartbeat );
			}

			curHeartbeat = setTimeout(function(){
				submit({ fail: -1, total: -1 });
			}, beatRate * 1000);
		},
		serialize: function(){
			return trimSerialize();
		}
	};

	// Prevent careless things from executing
	window.print = window.confirm = window.alert = window.open = function(){};

	window.onerror = function(e){
		document.body.appendChild( document.createTextNode( "ERROR: " + e ));
		submit({ fail: 0, error: 1, total: 1 });
		return false;
	};

	// QUnit callbacks - shughes 
        if ( typeof QUnit !== "undefined" ) {
	QUnit.done = function(results){
	  submit({
		  fail: results.failed,
		  error: 0,
                  time: results.runtime,
		  total: results.total,
                  results: JSON.stringify(testresults)
		 });
	};
	QUnit.testDone = function(results){
          testresults.push(results);
	};

	QUnit.log = window.TestSwarm.heartbeat;
	window.TestSwarm.heartbeat();

	window.TestSwarm.serialize = function(){
	  // Clean up the HTML (remove any un-needed test markup)
	  remove("nothiddendiv");
	  remove("loadediframe");
	  remove("dl");
	  remove("main");

		// Show any collapsed results
		var ol = document.getElementsByTagName("ol");
		for ( var i = 0; i < ol.length; i++ ) {
			ol[i].style.display = "block";
		}

		return trimSerialize();
	};
        }

	function trimSerialize(doc) {
		doc = doc || document;

		var scripts = doc.getElementsByTagName("script");
		while ( scripts.length ) {
			remove( scripts[0] );
		}

		var root = window.location.href.replace(/(https?:\/\/.*?)\/.*/, "$1");
		var cur = window.location.href.replace(/[^\/]*$/, "");

		var links = doc.getElementsByTagName("link");
		for ( var i = 0; i < links.length; i++ ) {
			var href = links[i].href;
			if ( href.indexOf("/") === 0 ) {
				href = root + href;
			} else if ( !/^https?:\/\//.test( href ) ) {
				href = cur + href;
			}
			links[i].href = href;
		}

		return ("<html>" + doc.documentElement.innerHTML + "</html>")
			.replace(/\s+/g, " ");
	}

	function remove(elem){
		if ( typeof elem === "string" ) {
			elem = document.getElementById( elem );
		}

		if ( elem ) {
			elem.parentNode.removeChild( elem );
		}
	}

	function submit(params){
		if ( curHeartbeat ) {
			clearTimeout( curHeartbeat );
		}

		var paramItems = (url.split("?")[1] || "").split("&");

		for ( var i = 0; i < paramItems.length; i++ ) {
			if ( paramItems[i] ) {
				var parts = paramItems[i].split("=");
				if ( !params[ parts[0] ] ) {
					params[ parts[0] ] = parts[1];
				}
			}
		}

		if ( !params.state ) {
			params.state = "saverun";
		}

		if ( !params.results ) {
			params.results = window.TestSwarm.serialize();
		}

		if ( doPost ) {
			// Build Query String
			var query = "";

			for ( var i in params ) {
				query += ( query ? "&" : "" ) + i + "=" +
					encodeURIComponent(params[i]);
			}

			if ( DEBUG ) {
				alert( query );
			} else {
				window.top.postMessage( query, "*" );
			}

		} else {
			var form = document.createElement("form");
			form.action = url;
			form.method = "POST";

			for ( var i in params ) {
				var input = document.createElement("input");
				input.type = "hidden";
				input.name = i;
				input.value = params[i];
				form.appendChild( input );
			}

			if ( DEBUG ) {
				alert( form.innerHTML );
			} else {

				// Watch for the result submission timing out
				setTimeout(function(){
					submit( params );
				}, submitTimeout * 1000);

				document.body.appendChild( form );
				form.submit();
			}
		}
	}

})();
