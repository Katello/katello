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
 * Created by .
 * User: jrist
 * Date: 7/13/11
 * Time: 2:27 PM
 *
 * This file is for use with the packages subnav within systems page.
 */

/*jshint loopfunc: true */

KT.package_action_types = (function() {
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
})();

KT.system_packages = (function() {
    var system_id = $('.packages').attr('data-system_id'),
    retrievingNewContent = true,
    total_packages = $('.packages').attr('data-total_packages'),
    more_button = $('#more'),
    sort_button = $('#package_sort'),
    packages_form = $('#packages_form'),
    packages_top = $('.packages').find('tbody'),
    remove_button = $('#remove_packages'),
    update_button = $('#update_packages'),
    update_all_button = $('#update_all_packages'),
    packages_tabindex = $('input[type="checkbox"]').last().attr('tabindex'),
    content_form = $('#content_form'),
    content_input = $('#content_input'),
    add_content_button = $('#add_content'),
    remove_content_button = $('#remove_content'),
    loaded_summary = $('#loaded_summary'),
    error_message = $('#error_message'),
    add_row_shading = true,
    selected_checkboxes = 0,
    actions_in_progress = {},
    packages_in_progress = {},
    groups_in_progress = {},
    actions_updater,

    disableButtons = function() {
        remove_button.attr('disabled', 'disabled');
        update_button.attr('disabled', 'disabled');

        remove_button.addClass('disabled');
        update_button.addClass('disabled');
    },
    enableButtons = function() {
        remove_button.removeAttr('disabled');
        update_button.removeAttr('disabled');

        remove_button.removeClass('disabled');
        update_button.removeClass('disabled');
    },
    disableUpdateAll = function() {
        update_all_button.attr('disabled', 'disabled');
        update_all_button.addClass('disabled');
    },
    enableUpdateAll = function() {
        update_all_button.removeAttr('disabled');
        update_all_button.removeClass('disabled');
    },
    disableLinks = function() {
        add_content_button.unbind();
        remove_content_button.unbind();

        add_content_button.attr('disabled', 'disabled');
        remove_content_button.attr('disabled', 'disabled');

        add_content_button.addClass('disabled');
        remove_content_button.addClass('disabled');
    },
    enableLinks = function() {
        if (add_content_button.hasClass('disabled')) {
            add_content_button.bind('click', addContent);
            add_content_button.bind('keypress', function(event) {
                if( event.which === 13) {
                    event.preventDefault();
                    KT.system_packages.addContent(event);
                }
            });

            add_content_button.removeAttr('disabled');
            add_content_button.removeClass('disabled');
        }
        if (remove_content_button.hasClass('disabled')) {
            remove_content_button.bind('click', removeContent);
            remove_content_button.bind('keypress', function(event) {
                if( event.which === 13) {
                    event.preventDefault();
                    KT.system_packages.removeContent(event);
                }
            });
            remove_content_button.removeAttr('disabled');
            remove_content_button.removeClass('disabled');
        }
    },
    getActionType = function(item) {
        var action_type;

        if (item.find('td.package_action_status:contains("'+i18n.adding_package+'")').length > 0) {
            action_type = KT.package_action_types.PKG_INSTALL;
        } else if (item.find('td.package_action_status:contains("'+i18n.updating_package+'")').length > 0) {
            action_type = KT.package_action_types.PKG_UPDATE;
        } else if (item.find('td.package_action_status:contains("'+i18n.removing_package+'")').length > 0) {
            action_type = KT.package_action_types.PKG_REMOVE;
        } else if (item.find('td.package_action_status:contains("'+i18n.adding_group+'")').length > 0) {
            action_type = KT.package_action_types.PKG_GRP_INSTALL;
        } else if (item.find('td.package_action_status:contains("'+i18n.removing_group+'")').length > 0) {
            action_type = KT.package_action_types.PKG_GRP_REMOVE;
        }

        return action_type;
    },
    morePackages = function() {
        var list = $('table.packages');
        var currentCount = list.attr('data-packageCount');
        var newCount = Number(currentCount) + Number(25);

        list.find('tbody tr').hide();
        list.find('tbody tr:lt('+newCount+')').show();
        list.find('tbody tr:visible').removeClass('alt');
        list.find('tbody tr:visible:odd').addClass('alt');

        list.attr('data-packageCount', newCount);

        updateLoadedSummary();
        registerCheckboxEvents();
    },
    sortOrder = function() {
        var packageSortOrder = sort_button.attr("data-sort");
        if (sort_button.attr("data-sort") === "asc"){
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

        dataScrollURL = dataScrollURL + "?reverse=" + reverse + "&pkg_order=" + KT.system_packages.sortOrder() + "&";
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
                if (data.length === 0) {
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
    registerCheckboxEvents = function() {
        var checkboxes = $('input[type="checkbox"]');

        checkboxes.unbind('change');
        checkboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    selected_checkboxes += 1;
                    enableButtons();
                    disableUpdateAll();
                }else{
                    selected_checkboxes -= 1;
                    if(selected_checkboxes === 0){
                        disableButtons();
                        enableUpdateAll();
                    }
                }
            });
        });
    },
    updateStatus = function(data) {
        // For each action that the user has initiated, update the status.
        $.each(data, function(index, status) {
            var event_id = status["id"],
                action = actions_in_progress[event_id],
                action_row = $('tr[data-pending-action-id="'+event_id+'"]'),
                action_status_col = action_row.find('td.package_action_status');

            switch (status["overall_status"]) {
                case "waiting":
                case "running":
                    // do nothing, no change to status needed
                    break;
                case "error":
                    switch (action) {
                        case KT.package_action_types.PKG_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_package_failed));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_UPDATE:
                            action_status_col.html(get_status_block(event_id, i18n.updating_package_failed));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_package_failed));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_GRP_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_group_failed));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                        case KT.package_action_types.PKG_GRP_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_group_failed));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                    }
                    break;
                case "finished":
                    switch (action) {
                        case KT.package_action_types.PKG_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_package_success));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_UPDATE:
                            action_status_col.html(get_status_block(event_id, i18n.updating_package_success));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_package_success));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_GRP_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_group_success));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                        case KT.package_action_types.PKG_GRP_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_group_success));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                    }
                    break;
                case "canceled":
                    switch (action) {
                        case KT.package_action_types.PKG_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_package_canceled));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_UPDATE:
                            action_status_col.html(get_status_block(event_id, i18n.updating_package_canceled));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_package_canceled));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_GRP_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_group_canceled));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                        case KT.package_action_types.PKG_GRP_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_group_canceled));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                    }
                    break;
                case "timed_out":
                    switch (action) {
                        case KT.package_action_types.PKG_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_package_timeout));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_UPDATE:
                            action_status_col.html(get_status_block(event_id, i18n.updating_package_timeout));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_package_timeout));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG);
                            break;
                        case KT.package_action_types.PKG_GRP_INSTALL:
                            action_status_col.html(get_status_block(event_id, i18n.adding_group_timeout));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                        case KT.package_action_types.PKG_GRP_REMOVE:
                            action_status_col.html(get_status_block(event_id, i18n.removing_group_timeout));
                            clearAction(status["id"], status["parameters"], KT.package_action_types.PKG_GRP);
                            break;
                    }
                    break;
            }
        });
    },
    get_status_block = function(event_id, status){
        var event_url = KT.routes.system_event_path(system_id, event_id);

        var html = '<a data-url="' + event_url + '" class="subpanel_element">' + status + '</a>';
        return html;
    },
    clearAction = function(action_id, content, content_type) {
        // clear/remove the details associated with the action....
        noLongerMonitorStatus(action_id);

        // clear the package and group names associated with the action
        $.each(content, function(index, content_item) {
            var names = content_item.toString().split(',');
            $.each(names, function(index, name) {
                if (content_type === KT.package_action_types.PKG) {
                    delete packages_in_progress[name];
                } else if (content_type === KT.package_action_types.PKG_GRP) {
                    delete groups_in_progress[name];
                }
            });
        });
    },
    startUpdater = function () {
        var timeout = 8000;
        actions_updater = $.PeriodicalUpdater(KT.routes.status_system_system_packages_path(system_id), {
            method: 'get',
            type: 'json',
            data: function() {return {id: Object.keys(actions_in_progress)};},
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
    initPackages = function() {
        initProgress();
        registerEvents();
        disableButtons();
        enableUpdateAll();
        updateLoadedSummary();
    },
    initProgress = function() {
        // when the page loads, we need to initialize the 'in progress' structures, to support monitoring
        // the status of any actions currently in progress...

        // if we are currently polling for status, temporarily stop the updater while we initialize the structures
        if (actions_updater !== undefined) {
            actions_updater.stop();
        }

        $('tr.content_package').each( function() {
            actions_in_progress[$(this).attr('data-pending-action-id')] = getActionType($(this));
            packages_in_progress[$.trim($(this).find('td.package_name').html())] = true;
        });
        $('tr.content_group').each( function() {
            actions_in_progress[$(this).attr('data-pending-action-id')] = getActionType($(this));
            packages_in_progress[$.trim($(this).find('td.package_name').html())] = true;
        });

        // start the updater, if there are any actions in progress
        if (Object.keys(actions_in_progress).length > 0) {
            if (actions_updater === undefined){
                startUpdater();
            } else {
                actions_updater.restart();
            }
        }
    },
    registerEvents = function() {
        content_input.bind('change, keyup', updateContentLinks);
        content_input.bind('keypress', function(event) {
            // if the user presses enter, ignore it... do not submit the form...
            if( event.which === 13) {
                event.preventDefault();
            }
        });
        more_button.bind('click', morePackages);
        more_button.bind('keypress', function(event) {
            if( event.which === 13) {
                event.preventDefault();
                morePackages();
            }
        });

        sort_button.bind('click', reverseSort);
        remove_button.bind('click', removePackages);
        update_button.bind('click', updatePackages);
        update_all_button.bind('click', updateAllPackages);

        KT.tipsy.custom.system_packages_tooltips();
        registerCheckboxEvents();
    },
    updateContentLinks = function(data) {
        if ($.trim($(this).val()).length === 0) {
            // the user cleared the content box, so disable the add/remove links
            disableLinks();

        } else {
            // the user has entered content in the content box, so enable the add/remove links
            enableLinks();
        }
    },
    addContent = function(data) {
        data.preventDefault();

        var selected_action = $("input[name=perform_action]:checked").attr('id'),
            content_string = content_form.find('#content_input').val(),
            content_array = content_string.split(/ *, */),
            validation_error;

        if (selected_action === 'perform_action_packages') {
            validation_error = validate_action_requested(content_array, KT.package_action_types.PKG);
            if (validation_error === undefined) {
                disableLinks();
                $.ajax({
                    url: KT.routes.add_system_system_packages_path(system_id),
                    type: 'PUT',
                    data: {'packages' : content_string},
                    cache: false,
                    success: function(data) {
                        monitorStatus(data, KT.package_action_types.PKG_INSTALL);

                        for (var i = 0; i < content_array.length; i += 1) {
                            var pkg_name = $.trim(content_array[i]), already_exists = false;
                            packages_in_progress[pkg_name] = true;

                            $('tr.content_package').find('td.package_name').each( function() {
                                if ($.trim($(this).html()) === pkg_name) {
                                    already_exists = true;
                                    $(this).parent().attr('data-pending-action-id', data);
                                    $(this).parent().find('td.package_action_status').html('<img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.adding_package);
                                }
                            });
                            // if row already existed... skip...
                            if (already_exists === false) {
                                if (add_row_shading) {
                                    add_row_shading = false;
                                    packages_top.prepend('<tr class="alt content_package" data-pending-action-id='+data+'><td></td><td class="package_name">' + pkg_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.adding_package + '</td></tr>');
                                } else {
                                    add_row_shading = true;
                                    packages_top.prepend('<tr class="content_package" data-pending-action-id='+data+'><td></td><td class="package_name">' + pkg_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.adding_package + '</td></tr>');
                                }
                            }
                        }
                        enableLinks();
                        show_validation_error(false);
                    },
                    error: function() {
                        enableLinks();
                    }
                });
            } else {
                show_validation_error(true, validation_error);
            }
        } else {
            validation_error = validate_action_requested(content_array, KT.package_action_types.PKG_GRP);
            if (validation_error === undefined) {
                disableLinks();
                $.ajax({
                    url: KT.routes.add_system_system_packages_path(system_id),
                    type: 'PUT',
                    data: {'groups' : content_string},
                    cache: false,
                    success: function(data) {
                        monitorStatus(data, KT.package_action_types.PKG_GRP_INSTALL);

                        for (var i = 0; i < content_array.length; i += 1) {
                            var group_name = $.trim(content_array[i]), already_exists = false;
                            groups_in_progress[group_name] = true;

                            $('tr.content_group').find('td.package_name').each( function() {
                                if ($.trim($(this).html()) === group_name) {
                                    already_exists = true;
                                    $(this).parent().attr('data-pending-action-id', data);
                                    $(this).parent().find('td.package_action_status').html('<img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.adding_group);
                                }
                            });
                            // if row already existed... skip...
                            if (already_exists === false) {
                                if (add_row_shading) {
                                    add_row_shading = false;
                                    packages_top.prepend('<tr class="alt content_group" data-pending-action-id='+data+'><td></td><td class="package_name">' + group_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.adding_group + '</td></tr>');
                                } else {
                                    add_row_shading = true;
                                    packages_top.prepend('<tr class="content_group" data-pending-action-id='+data+'><td></td><td class="package_name">' + group_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.adding_group + '</td></tr>');
                                }
                            }
                        }
                        enableLinks();
                        show_validation_error(false);
                    },
                    error: function() {
                        enableLinks();
                    }
                });
            } else {
                show_validation_error(true, validation_error);
            }
        }
    },
    removeContent = function(data) {
        data.preventDefault();

        var selected_action = $("input[name=perform_action]:checked").attr('id'),
            content_string = content_form.find('#content_input').val(),
            content_array = content_string.split(/ *, */),
            validation_error;

        if (selected_action === 'perform_action_packages') {
            validation_error = validate_action_requested(content_array, KT.package_action_types.PKG);
            if (validation_error === undefined) {
                disableLinks();
                $.ajax({
                    url: KT.routes.remove_system_system_packages_path(system_id),
                    type: 'POST',
                    data: {'packages' : content_string},
                    cache: false,
                    success: function(data) {
                        monitorStatus(data, KT.package_action_types.PKG_REMOVE);

                        for (var i = 0; i < content_array.length; i += 1) {
                            var pkg_name = $.trim(content_array[i]), already_exists = false;
                            packages_in_progress[pkg_name] = true;

                            $('tr.content_package').find('td.package_name').each( function() {
                                if ($.trim($(this).html()) === pkg_name) {
                                    already_exists = true;
                                    $(this).parent().attr('data-pending-action-id', data);
                                    $(this).parent().find('td.package_action_status').html('<img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.removing_package);
                                }
                            });
                            // if row already existed... skip...
                            if (already_exists === false) {
                                if (add_row_shading) {
                                    add_row_shading = false;
                                    packages_top.prepend('<tr class="alt content_package" data-pending-action-id='+data+'><td></td><td class="package_name">' + pkg_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.removing_package + '</td></tr>');
                                } else {
                                    add_row_shading = true;
                                    packages_top.prepend('<tr class="content_package" data-pending-action-id='+data+'><td></td><td class="package_name">' + pkg_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.removing_package + '</td></tr>');
                                }
                            }
                        }
                        enableLinks();
                        show_validation_error(false);
                    },
                    error: function() {
                        enableLinks();
                    }
                });
            } else {
                show_validation_error(true, validation_error);
            }
        } else {
            validation_error = validate_action_requested(content_array, KT.package_action_types.PKG_GRP);
            if (validation_error === undefined) {
                disableLinks();
                $.ajax({
                    url: KT.routes.remove_system_system_packages_path(system_id),
                    type: 'POST',
                    data: {'groups' : content_string},
                    cache: false,
                    success: function(data) {
                        monitorStatus(data, KT.package_action_types.PKG_GRP_REMOVE);

                        for (var i = 0; i < content_array.length; i += 1) {
                            var group_name = $.trim(content_array[i]), already_exists = false;
                            groups_in_progress[group_name] = true;

                            $('tr.content_group').find('td.package_name').each( function() {
                                if ($.trim($(this).html()) === group_name) {
                                    already_exists = true;
                                    $(this).parent().attr('data-pending-action-id', data);
                                    $(this).parent().find('td.package_action_status').html('<img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.removing_group);
                                }
                            });
                            // if row already existed... skip...
                            if (already_exists === false) {
                                if (add_row_shading) {
                                    add_row_shading = false;
                                    packages_top.prepend('<tr class="alt content_group" data-pending-action-id='+data+'><td></td><td class="package_name">' + group_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.removing_group + '</td></tr>');
                                } else {
                                    add_row_shading = true;
                                    packages_top.prepend('<tr class="content_group" data-pending-action-id='+data+'><td></td><td class="package_name">' + group_name + '</td><td class="package_action_status"><img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.removing_group + '</td></tr>');
                                }
                            }
                        }
                        enableLinks();
                        show_validation_error(false);
                    },
                    error: function() {
                        enableLinks();
                    }
                });
            } else {
                show_validation_error(true, validation_error);
            }
        }
    },
    removePackages = function(data) {
        data.preventDefault();
        disableButtons();
        packages_form.ajaxSubmit({
            url: remove_button.attr('data-url'),
            type: 'POST',
            success: function(data) {
                // locate the selected packages and update the status column to indicate the action being performed
                $(':checkbox:checked').each( function() {
                    var pkg = $(this).closest('.package');
                    pkg.attr('data-pending-action-id', data);
                    pkg.find('.package_action_status').html('<img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.removing_package);
                });
                monitorStatus(data, KT.package_action_types.PKG_REMOVE);

                enableButtons();
            },
            error: function() {
                enableButtons();
            }
        });
    },
    updatePackages = function(data) {
        data.preventDefault();
        disableButtons();
        packages_form.ajaxSubmit({
            url: update_button.attr('data-url'),
            type: 'POST',
            success: function(data) {
                // locate the selected packages and update the status column to indicate the action being performed
                $(':checkbox:checked').each( function() {
                    var pkg = $(this).closest('.package');
                    pkg.attr('data-pending-action-id', data);
                    pkg.find('.package_action_status').html('<img style="padding-right:8px;" src="icons/spinner.gif">' + i18n.updating_package);
                });
                monitorStatus(data, KT.package_action_types.PKG_UPDATE);

                enableButtons();
            },
            error: function() {
                enableButtons();
            }
        });
    },
    updateAllPackages = function(data) {
        data.preventDefault();
        disableButtons();
        $.ajax({
            url: update_button.attr('data-url'),
            type: 'POST',
            cache: false,
            success: function() {
                enableUpdateAll();
            },
            error: function() {
                enableUpdateAll();
            }
        });
    },
    updateLoadedSummary = function() {
        var total_loaded = $('tr.package:visible').length,
            message = i18n.x_of_y_packages(total_loaded, total_packages);
        loaded_summary.html(message);

        if (total_loaded >= total_packages) {
            more_button.remove();
        }
    },
    validate_action_requested = function(content, content_type) {
        // validate the action being requested and return a validation error, if an error is found
        var validation_error;

        // validate the package list format
        if ((content_type === KT.package_action_types.PKG) && !KT.packages.valid_package_list_format(content)) {
            validation_error = i18n.validation_error_name_format;

        // validate that no actions pending on same package or group
        } else {
            var item;
            $.each(content, function(index, content_item) {
                item = $.trim(content_item);
                switch (content_type) {
                    case KT.package_action_types.PKG:
                        if (packages_in_progress[item] === true) {
                            validation_error = i18n.validation_error_package_pending;
                            break;
                        }
                        break;
                    case KT.package_action_types.PKG_GRP:
                        if (groups_in_progress[item] === true) {
                            validation_error = i18n.validation_error_group_pending;
                            break;
                        }
                        break;
                }
            });
        }
        return validation_error;
    },
    show_validation_error = function(show, validation_error){
        var input = content_form.find('#content_input');

        if( show ){
            input.addClass('validation_error_input');
            error_message.html(validation_error);
            error_message.show();
        } else {
            input.removeClass('validation_error_input');
            error_message.hide();
        }
    };

    return {
        morePackages: morePackages,
        sortOrder: sortOrder,
        reverseSort: reverseSort,
        initPackages: initPackages,
        addContent: addContent,
        removeContent: removeContent,
        removePackages: removePackages,
        updatePackages: updatePackages,
        updateAllPackages: updateAllPackages
    };
})();

$(document).ready(function() {
    KT.system_packages.initPackages();
});
