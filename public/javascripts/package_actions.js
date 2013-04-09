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

KT.package_actions = (function() {
    var packages_container,
    content_add_url,
    content_update_url,
    content_remove_url,
    status_url,
    packages_top,
    content_form,
    content_input,
    add_content_button,
    update_content_button,
    remove_content_button,
    error_message,
    add_row_shading = true,
    actions_updater,
    actions_updater_running = false,

    disableContentButtons = function() {
        add_content_button.unbind();
        update_content_button.unbind();
        remove_content_button.unbind();

        add_content_button.attr('disabled', 'disabled');
        update_content_button.attr('disabled', 'disabled');
        remove_content_button.attr('disabled', 'disabled');

        add_content_button.addClass('disabled');
        update_content_button.addClass('disabled');
        remove_content_button.addClass('disabled');
    },
    enableContentButtons = function() {
        if (add_content_button.hasClass('disabled')) {
            add_content_button.bind('click', addContent);
            add_content_button.bind('keypress', function(event) {
                if( event.which === 13) {
                    event.preventDefault();
                    KT.package_actions.addContent(event);
                }
            });
            add_content_button.removeAttr('disabled');
            add_content_button.removeClass('disabled');
        }
        if (update_content_button.hasClass('disabled')) {
            update_content_button.bind('click', updateContent);
            update_content_button.bind('keypress', function(event) {
                if( event.which === 13) {
                    event.preventDefault();
                    KT.package_actions.updateContent(event);
                }
            });
            update_content_button.removeAttr('disabled');
            update_content_button.removeClass('disabled');
        }
        if (remove_content_button.hasClass('disabled')) {
            remove_content_button.bind('click', removeContent);
            remove_content_button.bind('keypress', function(event) {
                if( event.which === 13) {
                    event.preventDefault();
                    KT.package_actions.removeContent(event);
                }
            });
            remove_content_button.removeAttr('disabled');
            remove_content_button.removeClass('disabled');
        }
    },
    init = function(editable, page) {
        packages_container = $('#packages_container');
        packages_top = $('.packages').find('tbody');
        content_form = $('#content_form');
        content_input = $('#content_input');
        add_content_button = $('#add_content');
        update_content_button = $('#update_content');
        remove_content_button = $('#remove_content');
        error_message = $('#error_message');

        // This component could be shared by multiple pages (e.g. systems & system groups); however, some of the
        // behavior is different depending on the page.  For example, the URLs to interact with the server.
        packages_for = page;
        var id = packages_container.data('parent_id');
        if (packages_for === 'system') {
            // TODO: update for system packages when it is used
        } else {
            // packages_for === 'system_group'
            content_add_url = KT.routes.add_system_group_packages_path(id);
            content_update_url = KT.routes.system_group_packages_path(id);
            content_remove_url = KT.routes.remove_system_group_packages_path(id);
            status_url = KT.routes.status_system_group_packages_path(id);
        }

        disableContentButtons();

        content_input.bind('change, keyup', updateContentLinks);
        content_input.bind('keypress', function(event) {
            // if the user presses enter, ignore it... do not submit the form...
            if( event.which === 13) {
                event.preventDefault();
            }
        });
        KT.tipsy.custom.system_packages_tooltips();
    },
    updateContentLinks = function(data) {
        if ($.trim($(this).val()).length == 0) {
            // the user cleared the content box, so disable the add/remove links
            disableContentButtons();

        } else {
            // the user has entered content in the content box, so enable the add/remove links
            enableContentButtons();
        }
    },
    addContent = function(data) {
        data.preventDefault();
        performAction(content_add_url);
    },
    updateContent = function(data) {
        data.preventDefault();
        performAction(content_update_url);
    },
    removeContent = function(data) {
        data.preventDefault();
        performAction(content_remove_url);
    },
    performAction = function(url) {
        var selected_action = $("input[name=perform_action]:checked").attr('id'),
            content_string = content_form.find('#content_input').val(),
            content_array = content_string.split(/ *, */),
            content,
            validation_error;

        if (selected_action == 'perform_action_packages') {
            validation_error = validate_action_requested(content_array, KT.package_action_types.PKG);
            content = {'packages':content_string};
        } else {
            // perform_action_package_groups
            validation_error = validate_action_requested(content_array, KT.package_action_types.PKG_GRP);
            content = {'groups':content_string};
        }

        if (validation_error === undefined) {
            disableContentButtons();
            $.ajax({
                url: url,
                type: 'PUT',
                data: content,
                cache: false,
                success: function(data) {
                    $(data).each( function(index, element) {
                        // The response will have the html to be rendered for the action scheduled, which
                        // includes 1 row for each package or group included in the action.
                        if ($(element).is('tr')) {
                            var name = $(element).find('td').data('name'),
                                existing;

                            // check to see if there was an previous/existing action for the package or group
                            if ($(element).hasClass('package')) {
                                existing = $("tr.package > td[data-name='"+name+"']");
                            } else {
                                existing = $("tr.group > td[data-name='"+name+"']");
                            }

                            if (existing.length > 0) {
                                // there was an action, so just update the status on the existing row
                                existing.next('td.status').replaceWith($(element).find('td.status'));
                            } else {
                                // there was no action, so render the new row
                                if (add_row_shading) {
                                    add_row_shading = false;
                                    $(element).addClass('alt');
                                } else {
                                    add_row_shading = true;
                                }
                                packages_top.prepend(element);
                            }
                        }
                    });
                    enableContentButtons();
                    show_validation_error(false);
                    startUpdater();  // ensure polling is enabled for updates on the action
                },
                error: function() {
                    enableContentButtons();
                }
            });
        } else {
            show_validation_error(true, validation_error);
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
                        // look for an existing node for the package, where there is an action pending
                        var status = $("tr.package > td[data-name='"+item+"'] + td.status[data-pending-action-id]");
                        if (status.length > 0) {
                            validation_error = i18n.validation_error_package_pending;
                        }
                        break;
                    case KT.package_action_types.PKG_GRP:
                        // look for an existing node for the group, where there is an action pending
                        var status = $("tr.group > td[data-name='"+item+"'] + td.status[data-pending-action-id]");
                        if (status.length > 0) {
                            validation_error = i18n.validation_error_group_pending;
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
    },
    startUpdater = function () {
        if (!actions_updater_running) {
            var timeout = 8000;

            actions_updater = $.PeriodicalUpdater(status_url, {
                method: 'get',
                type: 'json',
                data: function() {return {id: getActionsInProgress()};},
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, updateStatus);

            actions_updater_running = true;
        }
    },
    updateStatus = function(data) {
        // update the status for each action retrieved
        $.each(data, function(index, status) {
            var node = $('td.status[data-pending-action-id=' + status['id'] + ']');
            if(node !== undefined) {
                if (status['status_html'] !== undefined) {
                    node.replaceWith(status['status_html']);
                }
            }
        });
        if (getActionsInProgress().length === 0) {
            actions_updater.stop();
            actions_updater_running = false;
        }
    },
    getActionsInProgress = function() {
        var pending_actions = [];
        $('td.status[data-pending-action-id]').each(function(i, element) {
            pending_actions[i] = $(element).data("pending-action-id");
        });
        return pending_actions;
    };
    return {
        init: init,
        addContent: addContent,
        removeContent: removeContent,
        updateContent: updateContent
    }
})();

