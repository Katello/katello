/** Copyright 2011 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

 * User: jrist
 * Date: 3/8/12
 * Time: 10:28 AM
 */
$(document).ready(function(){
  var new_env = $('#new_environment');
  var new_env_submit = new_env.find('.environment_create');
  new_env.bind('ajax:beforeSend', function(){
     new_env_submit.addClass('disabled');
  }).bind("ajax:complete", function(){
     new_env_submit.removeClass('disabled');
  }).bind("ajax:success", function(){
      KT.panel.closeSubPanel($('#subpanel'));
      KT.panel.refreshPanel();
  }).bind("ajax:error", function(){
     //validation notice appears
  });
});