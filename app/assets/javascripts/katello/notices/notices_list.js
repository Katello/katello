KT.notices_list = (function() {
    var deleteAll = function(e) {
        $('#notification_list').empty();
    };
    return {
        deleteAll: deleteAll
    };
})();

$(document).ready(function() {
  $('#dialog_content').dialog({
    resizable: false,
    autoOpen: false,
    height: 400,
    width: 700,
    maxWidth: 700,
    modal: true,
    title: 'Additional Details'
  });

  $('.details').bind('click', function(){
    var button = $(this);
    $.ajax({
        type: "GET",
        url: button.attr('data-url'),
        cache: false,
        success: function(data, status, xhr) {
            $('#dialog_content').html('<pre style="text-indent:0;">' + data + '</pre>').dialog('open');
        },
        error: function(data, status, xhr) {
           alert("failure");
        }
    });
  });

  $('.search').fancyQueries();
});
