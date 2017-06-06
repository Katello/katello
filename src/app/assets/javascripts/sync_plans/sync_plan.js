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

KT.panel.list.registerPage('sync_plans', { create : 'new_sync_plan' });

$(document).ready(function() {
  //set the date picker and time picker to only initialize on callback of the panel expansion
  KT.panel.set_expand_cb(function(){
      $("#datepicker").datepicker({
          changeMonth: true,
          changeYear: true
      });

       $("#timepicker").timepickr({
          convention: 12,
          trigger: "focus"
       });
  });

});
