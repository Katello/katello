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

  $('#new_filter').live('submit', function(e) {
    // disable submit to avoid duplicate clicks
    $('input[id^=filter_save]').attr("disabled", true);

    e.preventDefault();
    $(this).ajaxSubmit({success:KT.filters.success_create , error:KT.filters.failure_create});
  });







});


KT.filters = (function(){

    var success_create  = function(data){
        list.add(data);
        KT.panel.closePanel($('#panel'));        
    },
    failure_create = function(){
        $('input[id^=filter_save]').attr("disabled", false);

    };
    


    return {
        success_create: success_create,
        failure_create: failure_create

    };
})();