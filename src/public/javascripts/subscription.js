$(document).ready(function() {

  $("#subscriptionTable").treeTable({
  	initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: function(){$.sparkline_display_visible()}  	
  });

});
