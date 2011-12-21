
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
/**
 * This file is for use with the events subnav within systems page.
 */


KT.events = function() {

    var system_id = $('.events').attr('data-system_id'),
    add_row_shading = false,
    actions_updater = undefined,
    more_button = $('#more'),
    moreEvents = function() {
        var list = $('.events');
        var spinner = $('#list-spinner');
        var dataScrollURL = more_button.data("scroll_url");

        var offset = parseInt(more_button.data("offset"),0);
        dataScrollURL = dataScrollURL + "?offset=" + offset +"&";
        //console.log(dataScrollURL + ", page_size: " + offset);
        spinner.fadeIn();
        $.ajax({
            type: "GET",
            url: dataScrollURL,
            cache: false,
            success: function(data) {
                spinner.fadeOut();
                list.append(data);
                $('#filter').keyup();
                $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                if (data.trim().length === 0) {
                    more_button.empty().remove();
                }else{
                    more_button.data("offset", offset + parseInt(more_button.data("page_size"),25));
                }
            },
            error: function() {
                spinner.fadeOut();
            }
        });
    },
    updateStatus = function(data) {
        // For each action that the user has initiated, update the status.
        $.each(data, function(index, status) {
            var node = undefined,
                msg = undefined;
            if(!status["pending?"]) {
                node = $('.event_name[data-pending-task-id=' + status['id'] + ']');
                if(node !== undefined) {
                    node.parent().html(status["status_html"]);
                }
            }
        });
        if ($('.event_name[data-pending-task-id]').length === 0) {
            actions_updater.stop();
        }
    },
    startUpdater = function () {
        var timeout = 8000,
            pending_items = [];
        $('.event_name[data-pending-task-id]').each(function(i) {
            pending_items[i] = $(this).data("pending-task-id");
        });
        if(pending_items.length > 0) {
            actions_updater = $.PeriodicalUpdater(KT.routes.status_system_events_path(system_id), {
                method: 'get',
                type: 'json',
                data: function() {return {id: pending_items};},
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, updateStatus);
        }
    },

    initEvents = function() {
        more_button.bind('click', moreEvents);
        if($('.event_name[data-pending-task-id]').length > 0) {
            startUpdater();
        }
    },
    updateLoadedSummary = function() {
        var total_loaded = $('tr.package').length,
            message = i18n.x_of_y_packages(total_loaded, total_packages);
        loaded_summary.html(message);
    };
    return {
        moreEvents: moreEvents,
        initEvents: initEvents
    };
}();

$(document).ready(function() {
    KT.events.initEvents();
});
