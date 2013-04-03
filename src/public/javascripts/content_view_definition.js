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
    $('a.remove.disabled').tipsy({ fade:true, gravity:'s', delayIn:500, html:true, className:'content-tipsy',
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

        initialize_refresh();
        initialize_views_treetable();
        start_updater();
    },
    initialize_refresh = function() {
        $('.refresh_action').unbind('click');
        $('.refresh_action').bind('click', function(event) {
            event.preventDefault();
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
                    start_updater();
                },
                error: function() {
                    KT.panel.panelAjax('', $('#content_view_definition_views').data('views_url'), $('#panel'), false);
                }
            });
        });
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
            clickableNodeNames: true,
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
            initialize_refresh();
        }

        if($('.view_version[data-pending_task_id]').length === 0) {
            status_updater.stop();
        }
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
        $('.inclusion').unbind('change');
        $('.inclusion').change(function(){
            $('#update_form').ajaxSubmit({
                type: "PUT",
                cache: false
            });
        });

        $('.filter_method').unbind('change');
        $('.filter_method').change(function() {
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

        initialize_common_rule_params();
        initialize_errata_rule_params();
    },
    initialize_common_rule_params = function() {
        $('#add_rule').unbind('click');
        $('#add_rule').click(function() {
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
                    },
                    error: function() {
                    }
                });
            }
        });
        register_remove($("#parameters_form"));
        initialize_checkboxes($("#parameters_form"));
    },
    initialize_errata_rule_params = function() {
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
            disable_button(remove_button);

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
                    disable_button(remove_button);
                },
                error: function(){
                    enable_button(remove_button);
                }
            });
        });
        disable_button(remove_button);
    },
    disable_button = function(button) {
        button.attr('disabled', 'disabled');
        button.addClass('disabled');
    },
    enable_button = function(button) {
        button.removeAttr('disabled');
        button.removeClass('disabled');
    },
    initialize_checkboxes = function(form) {
        var checkboxes = $('input[type="checkbox"]'),
            button = form.find("#remove_button");

        checkboxes.unbind('change');
        checkboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")) {
                    enable_button(button);
                } else if($('input[type="checkbox"]:checked').length === 0) {
                    disable_button(button);
                }
            });
        });
    };
    return {
        initialize : initialize
    };
}());
