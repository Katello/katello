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

KT.panel.list.registerPage('content_view_definitions', { create : 'new_content_view_definition' });

KT.panel.set_expand_cb(function() {
    $('a.remove.disabled').tipsy({ fade:true, gravity:'s', delayIn:500, html:true, className:'content_definition-tipsy',
        title:function() { return $('.hidden-text.hidden').html();} });

    KT.object.label.initialize();
    KT.content_view_definition.initialize();
    KT.content_view_definition.initialize_views();
    KT.content_view_definition.initialize_composite_content();
    KT.content_view_definition.initialize_create();
    KT.content_view_definition_filters.initialize();
});

KT.content_view_definition = (function(){
    var status_updater,
        view_repos,
        view_conflicts = [],

    initialize = function() {
        $("#view_definitions").treeTable({
            expandable: true,
            initialState: "expanded",
            clickableNodeNames: true,
            onNodeShow: function(){$.sparkline_display_visible();}
        });
    },
    initialize_create = function() {
        var pane = $("#content_view_definition_create");
        if (pane.length === 0) {
            return;
        }
        $("#content_view_definition_composite").change(function() {
            // If the definition is a composite, show the list of views; otherwise, do not.
            if ($(this).is(":checked")) {
                $("#select_views").show();
            } else {
                $("#select_views").hide();
            }
        });
        initialize_view_checkboxes();
    },
    initialize_composite_content = function() {
        var pane = $("#composite_definition_content");
        if (pane.length === 0) {
            return;
        }
        enable_component_view_content_save();
        initialize_view_checkboxes();
    },
    initialize_views = function() {
        var pane = $("#content_view_definition_views");
        if (pane.length === 0) {
            return;
        }

        $('.repo_conflict').tipsy({fade : true, gravity : 'e', live : true, delayIn : 500,
                                   hoverable : true, delayOut : 50 });
        $('.repo_conflict').click(function(e) {e.preventDefault();});

        enable_remove_view();
        enable_refresh();
        initialize_views_treetable();
        start_updater();
    },
    initialize_view_checkboxes = function() {
        $('.view_checkbox').tipsy({fade : true, gravity : 'e', live : true, delayIn : 500,
                                  html: true, hoverable : true, delayOut : 50 });

        view_conflicts = [];

        $("input[id^='content_views_']").change(function() {
            var clicked_view_id = $(this).data('view_id').toString();

            if ($(this).is(":checked")) {
                // if the user selected a view, look to see if it has at least 1 repo in common
                // with the other enabled views and if so, disable the checkboxes on those views
                var enabled_views = $("input[id^='content_views_']:not(disabled)");
                KT.utils.each(enabled_views, function(enabled_view) {
                    var enabled_view_id = $(enabled_view).data('view_id').toString();
                    if (enabled_view_id !== clicked_view_id) {
                        if (repo_in_common(clicked_view_id, enabled_view_id)) {
                            $(enabled_view).attr("disabled", "true");
                            $(enabled_view).parent().attr("original-title", i18n.repos_in_common);
                        }
                    }
                });

            } else {
                // if the user unselected a view, look to see if it has at least 1 repo in common
                // with any disabled views and if so, enable the checkboxes on those views
                // (if they do not have a repo in common with any other selected view)
                var disabled_views = $("input[id^='content_views_']:disabled");
                KT.utils.each(disabled_views, function(disabled_view) {
                    var disabled_view_id = $(disabled_view).data('view_id').toString();
                    if (disabled_view_id !== clicked_view_id) {
                        // does the clicked view have any repos in common with the disabled view?
                        if (repo_in_common(clicked_view_id, disabled_view_id)) {
                            // does the disabled view have any repos in common with other selected views?
                            var selected_views = $("input[id^='content_views_']:checked"),
                                common_with_selected = false;

                            common_with_selected = KT.utils.find(selected_views, function(selected_view) {
                                var selected_view_id = $(selected_view).data('view_id').toString();
                                return repo_in_common(disabled_view_id, selected_view_id);
                            });
                            if (!common_with_selected) {
                                $(disabled_view).parent().removeAttr("original-title");
                                $(disabled_view).removeAttr("disabled");
                            }
                        }
                    }
                });

                remove_view_conflicts($(this));
            }
        });

        // As part of initializing, we need to determine if there are any views
        // with repos in common.  If there are and if more than one of the views is
        // selected, the views need to be highlighted as errors for the user to
        // address; otherwise, if only one of the views is selected, the others
        // should be disabled to avoid errors.
        var selected_views = $("input[id^='content_views_']:checked"),
            enabled_views = $("input[id^='content_views_']:not(disabled)");

        KT.utils.each(selected_views, function(selected_view) {
            var selected_view_id = $(selected_view).data('view_id').toString();
            KT.utils.each(enabled_views, function(enabled_view) {
                var enabled_view_id = $(enabled_view).data('view_id').toString();
                if (enabled_view_id !== selected_view_id) {
                    if (repo_in_common(selected_view_id, enabled_view_id)) {
                        if ($(enabled_view).is(":checked")) {
                            // both views are selected, so we've got a conflict that needs to be resolved
                            disable_component_view_content_save();

                            add_view_conflict(enabled_view, selected_view);
                            add_view_conflict(selected_view, enabled_view);

                            display_view_conflict(enabled_view_id, $(enabled_view).parent());
                            display_view_conflict(selected_view_id, $(selected_view).parent());
                        } else {
                            $(enabled_view).attr("disabled", "true");
                            $(enabled_view).parent().attr("original-title", i18n.repos_in_common);
                        }
                    }
                }
            });
        });
    },
    disable_component_view_content_save = function() {
        var saveButton = $("#update_component_views");
        saveButton.addClass("disabled");
        saveButton.unbind("click");
    },
    enable_component_view_content_save = function() {
        var saveButton = $("#update_component_views");
        saveButton.click(function(){
            var btn = $(this);
            if(btn.hasClass("disabled")){
                return;
            }
            btn.addClass("disabled");

            $("#component_views_form").ajaxSubmit({
                type: "POST",
                url: btn.data("url"),
                cache: false,
                success: function(){
                    $("#update_component_views").removeClass("disabled");
                },
                error: function(){
                    $("#update_component_views").removeClass("disabled");
                }
            });
        });
        saveButton.removeClass("disabled");
    },
    add_view_conflict = function(view, conflict_view) {
        var view_id = $(view).data('view_id').toString(),
            conflict_view_id = $(conflict_view).data('view_id').toString();

        if (view_conflicts[view_id] === undefined) {
            view_conflicts[view_id] = [];
        }
        if (KT.utils.indexOf(view_conflicts[view_id], view_repos[conflict_view_id]['name']) === -1) {
            view_conflicts[view_id].push(view_repos[conflict_view_id]['name']);
        }
        $(view).closest("tr").addClass("error");
    },
    remove_view_conflicts = function(unselected_view) {
        var rows_with_error = $("tr.error"),
            unselected_view_id = $(unselected_view).data('view_id').toString();

        KT.utils.each(rows_with_error, function(row) {
            var conflicted_view = $(row).find("input[id^='content_views_']"),
                conflicted_view_id = conflicted_view.data('view_id').toString(),
                unselected_index;

            if (view_conflicts[conflicted_view_id].length > 0) {
                if (unselected_view_id === conflicted_view_id) {
                    // the current element is the one that was unselected... so we can clear
                    // conflicts completely from that view
                    view_conflicts[unselected_view_id] = [];
                    $(unselected_view).closest("tr").removeClass("error");

                    $(unselected_view).attr("disabled", "true");
                    $(unselected_view).parent().attr("original-title", i18n.repos_in_common);

                } else {
                    // the current element has conflicts, but let's see if it has the
                    // unselected element as a conflict...
                    unselected_index = KT.utils.indexOf(view_conflicts[conflicted_view_id],
                                                        view_repos[unselected_view_id]['name']);
                    if (unselected_index !== -1) {
                        view_conflicts[conflicted_view_id].splice(unselected_index, 1);
                    }

                    if (view_conflicts[conflicted_view_id].length === 0) {
                        $(conflicted_view).closest("tr").removeClass("error");
                        $(conflicted_view).parent().removeAttr("original-title");
                    }
                }
            }
        });

        if ($("tr.error").length === 0) {
            enable_component_view_content_save();
        }

    },
    display_view_conflict = function(view_id, element) {
        element.attr("original-title", i18n.view_conflicts(view_conflicts[view_id].join(", ")));
    },
    repo_in_common = function(view_id_1, view_id_2) {
        // Does view 1 have any repos in common with view 2?
        var in_common = false,
            view_1_repos = view_repos[view_id_1]['repos'],
            view_2_repos = view_repos[view_id_2]['repos'];

        KT.utils.each(view_1_repos, function(view_1_repo) {
            if (KT.utils.contains(view_2_repos, view_1_repo)) {
                in_common = true;
            }
        });
        return in_common;
    },
    initialize_views_treetable = function() {
        $("#content_views").treeTable({
            expandable: true,
            initialState: "expanded",
            clickableNodeNames: false,
            onNodeShow: function(){$.sparkline_display_visible();}
        });
    },
    start_updater = function () {
        var timeout = 8000,
            pending_tasks = [];

        $('.view_version[data-pending_task_id]').each(function(i) {
            pending_tasks[i] = $(this).data("pending_task_id");
        });

        if (pending_tasks.length > 0) {
            if (status_updater !== undefined) {
                status_updater.stop();
            }
            status_updater = $.PeriodicalUpdater($('#content_view_definition_views').data('status_url'), {
                method: 'get',
                type: 'json',
                data: function() {return {task_ids: pending_tasks};},
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            }, update_status);
        }
    },
    update_status = function(data) {
        // For each action that the user has initiated (e.g. refresh), update the status.
        var task_statuses = data["task_statuses"] || [],
            status_updated = false;

        $.each(task_statuses, function(index, status) {
            var node;

            if(!status["pending?"]) {
                node = $('.view_version[data-pending_task_id=' + status['id'] + ']');
                if(node !== undefined) {
                    node.prevAll('.parent:first').removeClass('initialized');
                    node.replaceWith(status["status_html"]);
                    status_updated = true;
                }
            }
        });

        if (status_updated === true) {
            initialize_views_treetable();
        }

        if($('.view_version[data-pending_task_id]').length === 0) {
            status_updater.stop();
            enable_refresh();
            enable_remove_view();
        }
    },
    disable = function(element) {
        element.attr('disabled', 'disabled');
        element.addClass('disabled');
    },
    enable = function(element) {
        element.removeAttr('disabled');
        element.removeClass('disabled');
    },
    disable_remove_view = function(view_id) {
        var view = $('tr#' + view_id),
            remove_link = view.find('a.remove_view');

        remove_link.unbind('click').click(function(event){event.preventDefault();});
        disable(remove_link);
    },
    enable_remove_view = function(view_id) {
        // This will enable the 'remove' for views that do not have a pending task
        // (e.g. publish, refresh).  If the user provides a view_id, only that view
        // will be evaluated; otherwise, if view_id is undefined, all views will be
        // evaluated.
        var views;
        if (view_id === undefined) {
            views = $('tr.view');
        } else {
            views = $('tr#' + view_id);
        }

        views.each(function() {
            // only enable remove, if the view does not have a task pending
            var view = $(this),
                task_pending = $('tr.child-of-' + view.attr('id')).data('pending_task_id');

            if (task_pending === undefined) {
                var remove_links = view.find('a.remove_view');

                remove_links.unbind('click').click(function(event){
                    event.preventDefault();
                    var remove_link = $(this),
                        view = remove_link.closest('tr');

                    KT.common.customConfirm({
                        message: i18n.confirm_request,
                        yes_callback: function(){

                            var view_id = view.attr('id'),
                                view_versions = $('tr.child-of-' + view_id);

                            // disable links associated with the view
                            disable_remove_view(view_id);
                            disable_refresh(view_id);

                            $.ajax({
                                type: "DELETE",
                                url: remove_link.data("url"),
                                cache: false,
                                success: function(){
                                    // on success, remove all rows associated w/ the view from the pane
                                    view_versions.remove();
                                    view.remove();
                                },
                                error: function(){
                                    // enable links associated with the view
                                    enable_remove_view(view_id);
                                    enable_refresh(view_id);
                                }
                            });
                        }
                    });
                    return false;
                });
                enable(remove_links);
            }
        });
    },
    disable_refresh = function(view_id) {
        var view_versions = $('tr.child-of-' + view_id),
            refresh_links = view_versions.find('a.refresh_action');

        refresh_links.unbind('click').click(function(event){event.preventDefault();});
        disable(refresh_links);
    },
    enable_refresh = function(view_id) {
        // If the user provides a view_id, enable the refresh for only that view; however,
        // if view_id is undefined, enable the refresh for all views.
        var refresh_links;
        if (view_id === undefined) {
            refresh_links = $('a.refresh_action');
        } else {
            refresh_links = $('tr.child-of-' + view_id).find('a.refresh_action');
        }

        refresh_links.unbind('click').bind('click', function(event) {
            event.preventDefault();
            var view_id = $(this).closest('tr.view_version').prev('tr.view').attr('id');
            disable_remove_view(view_id);

            $.ajax({
                type: 'POST',
                url: $(this).data('url'),
                cache: false,
                success: function(response) {
                    // the response contains the html for the view and all versions
                    var view_id = $(response).first('tr').attr('id');

                    $('.child-of-'+view_id).remove();
                    $('#'+view_id).replaceWith(response);

                    initialize_views_treetable();
                    disable_remove_view(view_id);
                    start_updater();
                },
                error: function() {
                    KT.panel.panelAjax('', $('#content_view_definition_views').data('views_url'), $('#panel'), false);
                }
            });
        });

        enable(refresh_links);
    };
    return {
        initialize                   : initialize,
        initialize_composite_content : initialize_composite_content,
        initialize_create            : initialize_create,
        initialize_views             : initialize_views,
        set_view_repos               : function(vp) {view_repos = vp;}
    };
}());

KT.content_view_definition_filters = (function(){
    var initialize = function() {
        initialize_filters();
        initialize_filter();
        initialize_rule();
    },
    initialize_filters = function() {
        var pane = $("#filters");
        if (pane.length === 0) {
            return;
        }
        register_remove($("#filters_form"));
        initialize_checkboxes($("#filters_form"));
    },
    initialize_filter = function() {
        var pane = $("#filter");
        if (pane.length === 0) {
            return;
        }
        $("#filter_tabs").tabs().show();
        register_remove($("#rules_form"));
        initialize_checkboxes($("#rules_form"));
    },
    initialize_rule = function() {
        var pane = $("#rule");
        if (pane.length === 0) {
            return;
        }
        $('.inclusion').unbind('change').change(function(){
            $('#update_form').ajaxSubmit({
                type: "PUT",
                cache: false,
                success: function(new_value) {
                    // Update the "Specifying included/excluded" statement on the pane
                    var element = $('#inclusion');
                    element.html(element.html().replace(element.data('initial_value'), new_value));
                    element.data('initial_value', new_value);
                }
            });
        });

        $('.filter_method').unbind('change').change(function() {
            $.ajax({
                type: 'GET',
                url: $(this).data('url'),
                cache: false,
                success: function(html) {
                    $('.rule_parameters').html(html);
                    initialize_common_rule_params();
                    initialize_errata_rule_params();
                }
            });
        });

        initialize_version_save($('.save_version'));
        initialize_version_select($('.version_type'));
        initialize_version_input($('.input.input'));

        initialize_common_rule_params();
        initialize_errata_rule_params();
    },
    initialize_version_save = function(version_save_button) {
        version_save_button.unbind('click').click(function(e) {
            // user clicked save to commit some changes to a pkg filter rule
            e.preventDefault();
            var parameter_name,
                version_selector = $(this).parent('.version_selector'),
                version,
                min_version,
                max_version,
                range_inputs;

            parameter_name = $(this).closest('tr').find('td.parameter_name').find('.parameter_checkbox').data('id');

            type = version_selector.find('.version_type').val();
            if (type === 'version') {
                version = version_selector.find('input.version').val();
            } else if (type === 'min_version') {
                min_version = version_selector.find('input.version').val();
            } else if (type === 'max_version') {
                max_version = version_selector.find('input.version').val();
            } else if (type === 'version_range') {
                range_inputs = version_selector.find('input.range');
                min_version = range_inputs.first().val();
                max_version = range_inputs.last().val();
            }

            disable_version_selector(version_selector);

            $.ajax({
                type: 'PUT',
                url: $(this).attr('href'),
                data:
                { 'parameter':
                    { 'unit' :
                        { 'name' : $(this).closest('tr').find('td.parameter_name').find('.parameter_checkbox').data('id'),
                          'version' : version,
                          'min_version' : min_version,
                          'max_version' : max_version
                        }
                    }
                },
                cache: false,
                success: function(html) {
                    version_selector.find('.save_version').hide();
                    if (type === 'all_versions') {
                        version_selector.find('input.input').val('');
                    } else if (type === 'version_range') {
                        version_selector.find('input.version').val('');
                    } else {
                        version_selector.find('input.range').val('');
                    }
                    enable_version_selector(version_selector);
                },
                error: function() {
                    enable_version_selector(version_selector);
                }
            });
        });
    },
    initialize_version_select = function(version_select) {
        version_select.unbind('change').change(function() {
            // user changed the version type (e.g. all, older than..) on a pkg filter rule
            var version_selector = $(this).parent('.version_selector');

            if ($(this).val() === 'all_versions') {
                version_selector.find('.input').hide();
            } else if ($(this).val() === 'version_range') {
                version_selector.find('.version').hide();
                version_selector.find('.range').show();
            } else {
                version_selector.find('.range').hide();
                version_selector.find('.version').show();
            }
            version_selector.find('.save_version').show();
        });
    },
    initialize_version_input = function(version_input) {
        version_input.unbind('keypress').keypress(function() {
            var version_selector = $(this).parent('.version_selector');
            version_selector.find('.save_version').show();
        });
    },
    initialize_common_rule_params = function() {
        var pane = $("#parameter_list");
        if (pane.length === 0) {
            return;
        }

        $('#add_rule').unbind('click').click(function() {
            var rule_input = $('input#rule_input').val(),
                data;

            if ($(this).data('rule_type') === 'erratum') {
                data = {'parameter[unit][id]': rule_input};
            } else {  // this is for a package or package group rule
                data = {'parameter[unit][name]': rule_input};
            }
            if (rule_input.length > 0) {
                $.ajax({
                    type: 'PUT',
                    url: $(this).data('url'),
                    data: data,
                    cache: false,
                    success: function(html) {
                        var empty_row = $("tr#empty_row");
                        empty_row.after(html);
                        empty_row.hide();
                        initialize_checkboxes($("#parameters_form"));

                        var new_parameter = $('.parameter_checkbox[data-id=' + rule_input + ']').closest('tr');
                        initialize_version_save(new_parameter.find('.save_version'));
                        initialize_version_select(new_parameter.find('.version_type'));
                        initialize_version_input(new_parameter.find('.input.input'));
                    }
                });
            }
        });
        register_remove_filter_rule_param($("#parameters_form"));
        initialize_checkboxes($("#parameters_form"));
    },
    initialize_errata_rule_params = function() {
        var pane = $("#errata_parameters");
        if (pane.length === 0) {
            return;
        }
        KT.editable.initialize_datepicker();
        KT.editable.initialize_multiselect();
    },
    register_remove = function(form) {
        var remove_button = form.find("#remove_button");
        remove_button.unbind('click');
        remove_button.click(function(){
            var btn = $(this);
            if(btn.hasClass("disabled")){
                return;
            }
            disable(remove_button);

            form.ajaxSubmit({
                type: "DELETE",
                url: btn.data("url"),
                cache: false,
                success: function(){
                    // remove the deleted filters from the table and show the 'empty' message
                    // if all filters have been deleted
                    $('input[type="checkbox"]:checked').closest('tr').remove();
                    if ($('input[type="checkbox"]').length === 0) {
                        $('tr#empty_row').show();
                    }
                    disable(remove_button);
                },
                error: function(){
                    enable(remove_button);
                }
            });
        });
        disable(remove_button);
    },
    register_remove_filter_rule_param = function(form) {
        var remove_button = form.find("#remove_button");
        remove_button.unbind('click').click(function(){
            var btn = $(this), parameters = [];
            if(btn.hasClass("disabled")){
                return;
            }
            disable(remove_button);

            $('input.parameter_checkbox:checked').each(function() {
                parameters.push($(this).val());
            });

            $.ajax({
                type: "DELETE",
                url: btn.data("url"),
                cache: false,
                data: {'units': parameters},
                success: function(){
                    // remove the deleted parameters from the table and show the 'empty' message
                    // if all have been deleted
                    $('input[type="checkbox"]:checked').closest('tr').remove();
                    if ($('input[type="checkbox"]').length === 0) {
                        $('tr#empty_row').show();
                    }
                    disable(remove_button);
                },
                error: function(){
                    enable(remove_button);
                }
            });
        });
        disable(remove_button);
    },
    disable_version_selector = function(selector) {
        disable(selector.find('select.version_type'));
        disable(selector.find('input.input'));
        disable(selector.find('a.save_version'))
    },
    enable_version_selector = function(selector) {
        enable(selector.find('select.version_type'));
        enable(selector.find('input.input'));
        enable(selector.find('a.save_version'))
    },
    disable = function(button) {
        button.attr('disabled', 'disabled');
        button.addClass('disabled');
    },
    enable = function(button) {
        button.removeAttr('disabled');
        button.removeClass('disabled');
    },
    initialize_checkboxes = function(form) {
        var checkboxes = $('input[type="checkbox"]'),
            button = form.find("#remove_button");

        checkboxes.unbind('change').each(function(){
            $(this).change(function(){
                if($(this).is(":checked")) {
                    enable(button);
                } else if($('input[type="checkbox"]:checked').length === 0) {
                    disable(button);
                }
            });
        });
    };
    return {
        initialize : initialize
    };
}());
