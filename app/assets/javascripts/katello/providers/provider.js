/**
 Copyright 2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

KT.panel.list.registerPage('providers', { create : 'new_katello_provider' });

$(document).ready(function() {

    KT.panel.set_expand_cb(function() {
        KT.object.label.initialize();
        if ($('#providers').length > 0) {
            notices.checkNotices();
        }

        if ($('#discovered_repos').length > 0){
            KT.repo_discovery.page_load();
        }
        else {
            KT.repo_discovery.page_close();
        }
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
      function() {
          button.removeClass("disabled");
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
              if (val === "Custom") {
                  $(fields).attr("disabled", true);
              }
              else {
                  $(fields).removeAttr("disabled");
              }
        }
    };
})();
