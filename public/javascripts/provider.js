/**
 Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

KT.panel.list.registerPage('providers', { create : 'new_provider' });

$(document).ready(function() {

  $("#redhatSubscriptionTable").treeTable({
    expandable: true,
    initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: function(){$.sparkline_display_visible()}
  });

  $('#upload_button').live('submit', function(e) {
    // disable submit to avoid duplicate clicks
    $('input[id^=provider_submit]').attr("disabled", true);

    e.preventDefault();
    $(this).ajaxSubmit({success:subscription.successUpload});
  });

  $('form#edit_provider_2').live('submit', function(){
    $('#provider_submit').val("Uploading...").attr("disabled", true);
  });

  $('.repo_create').live('click', function(event) {
    var button = $(this);
    button.addClass("disabled");

    event.preventDefault();
    var form = $(this).closest("form");
    var url = form.attr('action');
    var dataToSend = form.serialize();
    // send a request to create the repo
    client_common.create(dataToSend, url, function() {
        KT.panel.panelAjax('', button.attr("data-url") ,$('#panel'));
        KT.panel.closeSubPanel($('#subpanel'));
      },
      function() {button.removeClass("disabled")
    });
  });
  $('#provider_contents').attr('size', '17');
  //end doc ready
});

var provider = (function() {
    return {
        toggleFields : function() {
          	var val = $('#provider_provider_type option:selected').val();
          	var fields = "#repository_url_field"; 
          	if (val == "Custom") {
          		$(fields).attr("disabled", true);			
          	}
          	else {
          		$(fields).removeAttr("disabled");
          	}
        }
    }
})();

var subscription = (function(){
    return {
        successUpload: function(data) {

            if (data.length != 0) {
                $(".panel-content").html(data);

            } else {
                // the response data came back empty.  this only occurs on an error, so do not replace the
                // content of the pane...

                // enable the submit, so user can try again
                $('input[id^=provider_submit]').removeAttr("disabled");

            }

            notices.checkNotices();

            // after file upload, the ajaxComplete isn't being called (which stops the spinners).
            // as a result, we'll manually trigger the event.
            $('#loading').trigger('ajaxComplete');
        }
    };
})();
