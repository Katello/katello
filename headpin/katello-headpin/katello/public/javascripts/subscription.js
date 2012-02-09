$(document).ready(function() {

  $("#subscriptionTable").treeTable({
    expandable: true,
  	initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: function(){$.sparkline_display_visible()}  	
  });

  $('#toggle_all').toggle(
          function(){$('.collapsed td:first-child').click(); return false;},
          function(){$('.expanded td:first-child').click(); return false;}
    );

});
