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

KT.panel.list.registerPage('organizations', { create : 'new_organization' });

$(document).ready(function() {

    var env_scroll = KT.env_select_scroll({});
    KT.panel.set_expand_cb(function() {
        env_scroll.bind(undefined);
        KT.object.label.initialize();
        if ($('#organization_edit').length > 0) {
            notices.checkNotices();
        }
    });

    $('.environment_link').live('click', function() {
         $(this).siblings().show();
    });

    $('#debug_cert').live('click',function(){
        $('#show_debug_button').slideToggle();

        var arrow = $(this).parent().find('img');
        if (arrow.attr("src").indexOf("collapsed") === -1) {
            arrow.attr("src", KT.common.rootURL() + "images/embed/icons/expander-collapsed.png");
        } else {
            arrow.attr("src", KT.common.rootURL() + "images/embed/icons/expander-expanded.png");
        }
        return false;
    });

    $('#download_debug_cert_key').live('click', function(e) {
        e.preventDefault();  //stop the browser from following
        url = $("#download_debug_cert_key").data("url");
        window.location.href = url;
        return false;
    });

    $('#label_default_org').live('click', function(e) {
        KT.orgswitcher.checkboxChanged($('#default_org'));
    });

    $('#save_name').live('ajax:complete', function(evt, data, status, xhr) {
        // Refresh the entry in the left list
        var id = $('.left').find('.active');
        var url = id.attr('data-ajax_url');
        KT.panel.list.refresh(id.attr('id'), url);

        // Refresh the name displayed at the top of the right panel
    });

});
