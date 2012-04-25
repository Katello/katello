
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
    total_events = 0,
    total_loaded = 0,
    actions_updater = undefined,
    loaded_summary = $('#loaded_summary'),
    more_button = $('#more'),
    page_size = 0,
    moreEvents = function() {
        var list = $('.events'),
        spinner = $('#list-spinner'),
        dataScrollURL = more_button.data("scroll_url") + "?offset=" + total_loaded +"&";
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
                updateLoadedSummary();

                if (total_loaded === total_events) {
                    more_button.empty().remove();
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
        total_events = $('.events').data('total_events');
        if(total_events !== undefined) {
            total_events = parseInt(total_events, 10);
        } else {
            total_events = 0;
        }
        if(total_events > 0) {
            if(more_button !== undefined) {
                page_size = parseInt(more_button.data("page_size"),10);
                more_button.bind('click', moreEvents);
            } else {
                page_size = 0;
            }

            updateLoadedSummary();
            if($('.event_name[data-pending-task-id]').length > 0) {
                startUpdater();
            }

            var  search_button = $('#event_filter_button'),
                    search_field = $('#event_search_filter'),
                spinner = $('#list-spinner');

            search_button.bind('click', function(evt){
                evt.preventDefault();
                $.ajax({
                    type: "GET",
                    url: search_field.data('search_url'),
                    data: {search: search_field.val()},
                    cache: false,
                    success: function(data) {
                        spinner.fadeOut();
                        $("#event_items").html(data["html"]);
                        $('#filter').keyup();
                        $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                        updateLoadedSummary();
                        if (total_loaded === total_events) {
                            more_button.empty().remove();
                        }
                    },
                    error: function() {
                        spinner.fadeOut();
                    }
                });
            });

        }




    },
    updateLoadedSummary = function() {
        var more_size = page_size;
        total_loaded = $('tr.tasks').length;
        loaded_summary.html(i18n.x_of_y_events(total_loaded, total_events));

        if(more_size > (total_events - total_loaded)) {
           more_size = total_events - total_loaded;
        }
        more_button.text(i18n.x_more_events(more_size));
    };
    return {
        initEvents: initEvents
    };
}();

$(document).ready(function() {
    KT.events.initEvents();
});
