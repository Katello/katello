
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
    var import_updater
    updateStatus = function(data) {
        if (data["progress"] === "finished") {
            notices.checkNotices();
            if (import_updater) {
                import_updater.stop();
            }
            window.location = KT.routes.subscriptions_path();
        }
    },
    startUpdater = function() {
        var timeout = 8000,
            provider_id;

        notices.checkNotices();

        // When the import progress element is present, start the polling for success
        provider_id = $('.import_progress').attr("provider_id");
        if (provider_id) {

            if (import_updater !== undefined) {
                import_updater.stop();
            }

            import_updater = $.PeriodicalUpdater(KT.common.rootURL()+'providers/'+provider_id+'/import_progress/', {
                method: 'get',
                type: 'json',
                global: false,
                cache: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, updateStatus);
        }

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

    // Initialize the polling for "upload in progress"
    KT.subscription.startUpdater();

    $('.edit_provider').live('submit', function(e) {
        var ajax_handler;
        var active;

        // disable submit to avoid duplicate clicks
        $('#provider_submit').val(i18n.uploading).attr("disabled", true);
        $('.edit_provider').attr("disabled", true);

        ajax_handler = function(data) {
                        if (data["progress"] === "finished") {
                            KT.subscription.updateStatus(data);
                        } else {
                            // Refresh the panel to pick up new history and show spinner while uploading
                            notices.checkNotices();
                            active = $('#new');
                            KT.panel.panelAjax(active, active.attr("data-ajax_url"), $('#panel'), false);
                        }
                    };
        e.preventDefault();
        $(this).ajaxSubmit({
            success: ajax_handler,
            error: ajax_handler
        });
    });
});
