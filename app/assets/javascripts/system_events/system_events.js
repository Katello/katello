
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
/**
 * This file is for use with the events subnav within systems page.
 * It is also used on the events subnav of the distributors page.
 */


KT.events = (function() {

    var total_events = 0,
    total_loaded = 0,
    actions_updater,
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
        var jobs = data["jobs"],
            tasks = data["tasks"];

        if (tasks) {
            $.each(tasks, function(index, status) {
                var node,
                    msg;

                if(!status["pending?"]) {
                    node = $('.event_name[data-pending-task-id=' + status['id'] + ']');
                    if(node !== undefined) {
                        node.parent().html(status["status_html"]);
                    }
                }
            });
        }

        if (jobs) {
            $.each(jobs, function(index, status) {
                var node,
                    msg;

                if(!status["pending?"]) {
                    node = $('.event_name[data-pending-job-id=' + status['id'] + ']');
                    if(node !== undefined) {
                        node.parent().html(status["status_html"]);
                    }
                }
            });
        }

        if(($('.event_name[data-pending-task-id]').length === 0) && ($('.event_name[data-pending-job-id]').length === 0)) {
            actions_updater.stop();
        }
    },
    startUpdater = function () {
        var timeout = 8000,
            pending_jobs = [],
            pending_tasks = [];

        $('.event_name[data-pending-job-id]').each(function(i) {
            pending_jobs[i] = $(this).data("pending-job-id");
        });
        $('.event_name[data-pending-task-id]').each(function(i) {
            pending_tasks[i] = $(this).data("pending-task-id");
        });

        if(pending_jobs.length > 0 || pending_tasks.length > 0) {
            if (actions_updater !== undefined) {
                actions_updater.stop();
            }
            actions_updater = $.PeriodicalUpdater($('.events').data('url'), {
                method: 'get',
                type: 'json',
                data: function() {return {task_id: pending_tasks, job_id: pending_jobs};},
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

            var  search_button = $('#event_filter_button'),
                    search_field = $('#event_search_filter'),
                spinner = $('#list-spinner');

            search_button.live('click', function(evt){
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
        if(($('.event_name[data-pending-task-id]').length > 0) || ($('.event_name[data-pending-job-id]').length > 0)) {
            startUpdater();
        }
    },
    updateLoadedSummary = function() {
        var more_size = page_size;
        total_loaded = $('tr.tasks').length;
        loaded_summary.html(i18n.x_of_y(total_loaded, total_events));

        if(more_size > (total_events - total_loaded)) {
           more_size = total_events - total_loaded;
        }
        more_button.text(i18n.x_more(more_size));
    };
    return {
        initEvents: initEvents
    };
})();

$(document).ready(function() {
    KT.events.initEvents();
});
