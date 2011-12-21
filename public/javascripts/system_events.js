
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
//    total_packages = $('.packages').attr('data-total_packages'),
//    more_button = $('#more'),
//    sort_button = $('#package_sort'),
//    loaded_summary = $('#loaded_summary'),

    var system_id = $('.events').attr('data-system_id'),
    retrievingNewContent = true,
    add_row_shading = false,
    actions_in_progress = {},
    actions_updater = undefined,

    moreEvents = function() {
        var list = $('.events');
        var spinner = $('#list-spinner');
        var dataScrollURL = more_button.attr("data-scroll_url");

        var offset = parseInt(more_button.attr("data-offset"), 10) + parseInt(more_button.attr("data-page_size"), 10);
        dataScrollURL = dataScrollURL + "?offset=" + offset + "&pkg_order="+ sort_button.attr("data-sort") +"&";
        //console.log(dataScrollURL + ", page_size: " + offset);
        spinner.fadeIn();
        $.ajax({
            type: "GET",
            url: dataScrollURL,
            cache: false,
            success: function(data) {
                retrievingNewContent = false;
                spinner.fadeOut();
                list.append(data);
                $('#filter').keyup();
                $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                updateLoadedSummary();
                if (data.length === 0) {
                    more_button.empty().remove();
                }else{
                    more_button.attr("data-offset", offset);
                }
            },
            error: function() {
                spinner.fadeOut();
                retrievingNewContent = false;
            }
        });
    },
/*
    sortOrder = function() {
        var packageSortOrder = sort_button.attr("data-sort");
        if (sort_button.attr("data-sort") == "asc"){
            packageSortOrder = "desc";
            sort_button.removeClass("ascending").addClass("descending");
        } else {
            packageSortOrder = "asc";
            sort_button.removeClass("descending").addClass("ascending");
        }
        sort_button.attr("data-sort", packageSortOrder);
        return packageSortOrder;
    },
    reverseSort = function() {
        var list = $('.packages');
        var spinner = $('#list-spinner');
        var dataScrollURL = more_button.attr("data-scroll_url");
        var reverse = parseInt(more_button.attr("data-offset"), 10);

        dataScrollURL = dataScrollURL + "?reverse=" + reverse + "&pkg_order=" + KT.packages.sortOrder() + "&";
        spinner.fadeIn();
        list.find('tbody > tr.package').empty().remove();
        $.ajax({
            type: "GET",
            url: dataScrollURL,
            cache: false,
            success: function(data) {
                retrievingNewContent = false;
                spinner.fadeOut();
                list.append(data);
                registerCheckboxEvents();
                $('#filter').keyup();
                $('.scroll-pane').jScrollPane().data('jsp').reinitialise();
                updateLoadedSummary();
                if (data.length == 0) {
                    more_button.empty().remove();
                }else{
                    more_button.attr("data-offset", reverse);
                }
            },
            error: function() {
                spinner.fadeOut();
                retrievingNewContent = false;
            }
        });
    },
*/
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
    monitorStatus = function(task_id, task_type) {
        actions_in_progress[task_id] = task_type;

        if (actions_updater === undefined){
            startUpdater();
        } else {
            actions_updater.restart();
        }
    },
    noLongerMonitorStatus = function(task_id) {
        delete actions_in_progress[task_id];

        if (Object.keys(actions_in_progress).length === 0) {
            actions_updater.stop();
        }
    },
    initEvents = function() {
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
//        morePackages: morePackages,
//        sortOrder: sortOrder,
//        reverseSort: reverseSort,
        initEvents: initEvents
    };
}();

$(document).ready(function() {
    KT.events.initEvents();
});
