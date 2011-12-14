
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
 * This file is for use with the packages subnav within systems page.
 */

KT.package_action_types = function() {
    return {
        PKG : "pkg",
        PKG_INSTALL : "pkg_install",
        PKG_UPDATE : "pkg_update",
        PKG_REMOVE : "pkg_remove",
        PKG_GRP : "pkg_grp",
        PKG_GRP_INSTALL : "pkg_grp_install",
        PKG_GRP_UPDATE : "pkg_grp_update",
        PKG_GRP_REMOVE : "pkg_grp_remove"
    };
}();

KT.events = function() {
    var system_id = $('.events').attr('data-system_id'),
    retrievingNewContent = true,
//    total_packages = $('.packages').attr('data-total_packages'),
//    more_button = $('#more'),
//    sort_button = $('#package_sort'),
//    loaded_summary = $('#loaded_summary'),
    add_row_shading = false,
    actions_in_progress = {},
    packages_in_progress = {},
    groups_in_progress = {},
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
                if (data.length == 0) {
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
/*
    registerCheckboxEvents = function() {
        var checkboxes = $('input[type="checkbox"]');
        checkboxes.unbind('change');
        checkboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    selected_checkboxes++;
                    enableButtons();
                    disableUpdateAll();
                }else{
                    selected_checkboxes--;
                    if(selected_checkboxes == 0){
                        disableButtons();
                        enableUpdateAll();
                    }
                }
            });
        });
    },
*/
    updateStatus = function(data) {
        // For each action that the user has initiated, update the status.
        $.each(data, function(index, status) {
            var action = actions_in_progress[status["uuid"]],
                action_row = $('tr[data-uuid="'+status["uuid"]+'"]'),
                action_status_col = action_row.find('td.package_action_status');

            if(status["state"] !== "waiting" || status["state"] !== "error") {
                action_status_col.html(KT.event_types[action]["event_messages"][status["state"]]);
                clearAction(status["uuid"], status["parameters"], KT.event_types[action]["type"]);
            }
        });
    },
    clearAction = function(action_id, content, content_type) {
        // clear/remove the details associated with the action....
        noLongerMonitorStatus(action_id);

        // clear the package and group names associated with the action
        $.each(content, function(index, content_item) {
            var names = content_item.toString().split(',');
            $.each(names, function(index, name) {
                if (content_type ==="package") {
                    delete packages_in_progress[name];
                } else if (content_type === "package_group") {
                    delete groups_in_progress[name];
                }
            });
        });
    },
    startUpdater = function () {
        var timeout = 8000;
        actions_updater = $.PeriodicalUpdater(KT.routes.status_system_events_path(system_id), {
            method: 'get',
            type: 'json',
            data: function() {return {uuid: Object.keys(actions_in_progress)};},
            global: false,
            minTimeout: timeout,
            maxTimeout: timeout
        }, updateStatus);
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
        enableUpdateAll();
        //updateLoadedSummary();
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
    }
}();

$(document).ready(function() {
    KT.packages.initEvents();
});
