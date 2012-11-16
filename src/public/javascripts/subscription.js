
/**
 Copyright 2012 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

KT.subscription = (function() {
    var manifest_updater

    // Data that is unchanged from previous will come in as ""
    updateStatus = function(data) {
        if (data !== "" && $('.manifest_progress_message')) {
            $(".manifest_progress_message").html(i18n.import_in_progress(data["state"]));
        }
        if (data !== "" && data["state"] !== "running" && data["state"] !== "waiting") {
            notices.checkNotices();
            if (manifest_updater) {
                manifest_updater.stop();
            }

            active = $('#new');
            KT.panel.list.refresh_list();
            KT.panel.panelAjax(active, active.attr("data-ajax_url"), $('#panel'), false);
        }
    },
    startUpdater = function() {
        var timeout = 6000,
            provider_id;

        if (manifest_updater !== undefined) {
            manifest_updater.stop();
        }

        // When the manifest progress element is present, start the polling for success
        provider_id = $('.manifest_progress').attr("provider_id");
        if (provider_id) {
            manifest_updater = $.PeriodicalUpdater(KT.common.rootURL()+'providers/'+provider_id+'/manifest_progress/', {
                method: 'get',
                type: 'json',
                cache: false,
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, updateStatus);
        }

        notices.checkNotices();
    },
    initSubscription = function initSubscription() {
        startUpdater();
    };

    return {
        startUpdater: startUpdater,
        updateStatus: updateStatus
    };
}());

$(document).ready(function() {

    var options = { };
    KT.panel.list.registerPage('subscriptions', options);

    $('#upload_manifest').live('submit', function(e) {
        var ajax_handler;
        var active;

        // disable submit to avoid duplicate clicks
        $('#upload_form_button').val(i18n.uploading).attr("disabled", true);
        $('#upload_manifest').attr("disabled", true);

        ajax_handler = function(data) {
            // Refresh the "new" panel
            active = $('#new');
            KT.panel.panelAjax(active, active.attr("data-ajax_url"), $('#panel'), false);

            // Initialize the polling for "upload in progress"
            KT.subscription.startUpdater();
        };
        e.preventDefault();
        $(this).ajaxSubmit({
            success: ajax_handler,
            error: ajax_handler
        });
    });

    var delete_manifest_callback = function(evt, data, status, xhr){
        var active = $('#new');
        notices.checkNotices();
        KT.panel.list.refresh_list();
        KT.panel.panelAjax(active, active.attr("data-ajax_url"), $('#panel'), false);
    };
    $('#delete_manifest').live('ajax:success', delete_manifest_callback);
    $('#delete_manifest').live('ajax:error', delete_manifest_callback);
});
