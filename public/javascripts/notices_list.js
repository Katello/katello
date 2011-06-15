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

function retrieve_details(notice_id) {
  // invoke the request to the server as defined in kalpana_client.js
  notice.details(notice_id,
      function(data, status, xhr) {
        $('#dialog_content').html(data).dialog('open');
      },
      function(data, status, xhr) {
        alert("failure");
      });
}

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
    var notice_id = $(this).attr('id');
    retrieve_details(notice_id);
  });

  $('.search').fancyQueries();
});

