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


/*
 * A small javascript file needed to load system subscription related stuff
 *
 */

$(document).ready(function() {
  KT.subs.unsubSetup();
  KT.subs.subSetup();
  KT.subs.spinnerSetup();
  KT.subs.autohealSetup();

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
/*
    $('#unsubscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('#panel_element_id');
        console.log("#unsubscribe ajax:complete " + id.attr('id'));
        KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
    });
    $('#subscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left').find('.active');
        console.log("#subscribe ajax:complete " + id.attr('id'));
        KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
    });
*/
    /*
    $('#unsubscribe').live('ajax:success', function(evt, data, status, xhr){
        console.log("#unsubscribe ajax:success");
        var id = $('#panel_element_id');
        KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
    });
    $('#unsubscribe').live('ajax:failure', function(evt, data, status, xhr){
        console.log("#unsubscribe ajax:failure");
        var id = $('#panel_element_id');
        KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
    });
    $('#subscribe').live('ajax:success', function(evt, data, status, xhr){
        console.log("#subscribe ajax:success");
        var id = $('#panel_element_id');
        KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
    });
    $('#subscribe').live('ajax:failure', function(evt, data, status, xhr){
        console.log("#subscribe ajax:failure");
        var id = $('#panel_element_id');
        KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
    });
    */
    /*
    $('#unsubscribe').unbind('submit');
    $('#unsubscribe').bind('submit', function(e) {
        e.preventDefault();
        var unsubform = $('#unsubscribe');
        var button = unsubform.find('input[type|="submit"]');
        button.attr("disabled","disabled");
        unsubform.ajaxSubmit({
            success: function(data) {
                button.removeAttr('disabled');
                notices.checkNotices();
                var id = $('#panel_element_id')
                KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
            }, error: function(e) {
                button.removeAttr('disabled');
                notices.checkNotices();
            }
        });
    });

    $('#subscribe').unbind('submit');
    $('#subscribe').bind('submit', function(e) {
        e.preventDefault();
        var subform = $('#subscribe');
        var button = subform.find('input[type|="submit"]');
        button.attr("disabled","disabled");
        subform.ajaxSubmit({
            success: function(data) {
                button.removeAttr('disabled');
                notices.checkNotices();
                var id = $('#panel_element_id')
                KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
            }, error: function(e) {
                button.removeAttr('disabled');
                notices.checkNotices();
            }
        });
    });
    */

/*
  $('#unsubscribe').live('submit', function(e) {
    e.preventDefault();
    var button = $(this).find('input[type|="submit"]');
    button.attr("disabled","disabled");
    $(this).ajaxSubmit({
         success: function(data) {
             button.removeAttr('disabled');
             notices.checkNotices();
             var id = $('#panel_element_id')
             KT.panel.list.refresh(id.attr('value'), id.attr('data-ajax_url'));
         }, error: function(e) {
             button.removeAttr('disabled');
             notices.checkNotices();
         }
     });
  });
*/
});