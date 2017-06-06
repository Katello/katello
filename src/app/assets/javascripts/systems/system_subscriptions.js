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


/*
 * A small javascript file needed to load system subscription related stuff
 *
 */

$(document).ready(function() {
  KT.subs.unsubSetup();
  KT.subs.subSetup();
  KT.subs.spinnerSetup();
  KT.subs.autohealSetup();
  KT.subs.matchsystemSetup();

  $("#unsubscribeTable").treeTable({
    expandable: true,
    initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: function(){$.sparkline_display_visible()}
  });

  $("#subscribeTable").treeTable({
    expandable: true,
    initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: function(){$.sparkline_display_visible()}
  });

    // Auto-heal with service level used in systems/_subscriptions.html.haml
    $('.edit_select_system_servicelevel').each(function(){
        var common_settings = {
                method          :  'PUT',
                cancel          :  i18n.cancel,
                submit          :  i18n.save,
                indicator       :  i18n.saving,
                tooltip         :  i18n.clickToEdit,
                placeholder     :  i18n.systemSelectAutoheal,
                submitdata      :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
                onerror         :  function(settings, original, xhr) {
                    original.reset();
                    $("#notification").replaceWith(xhr.responseText);
                    notices.checkNotices();
                }
        };
        var element = $(this),
            settings = {
                type            :  'select',
                name            :  element.attr('name'),
                data            :  element.data('options'),
                onsuccess       :  function(result, status, xhr){
                    element.select(xhr.responseText);
                    notices.checkNotices();
                }
            };
        $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
    });


});
