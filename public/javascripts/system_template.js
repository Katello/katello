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

$(document).ready(function() {

    var sync_plan = (function() {
        return {
          successCreate : function(data) {
            //panel.js calls
            list.add(data);
            panel.closePanel($('#panel'));
          },
          errorCreate : function(data) {
            $('#template_save').removeAttr("disabled");
          }
        }

    })();


    $('form[id^=new_system_template]').live('submit', function(e) {
        //disable submit
        e.preventDefault();
        $('#template_save').attr('disabled', 'disabled');

        $(this).ajaxSubmit({success:sync_plan.successCreate, error:sync_plan.errorCreate});
    });


});