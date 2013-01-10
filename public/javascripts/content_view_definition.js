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

KT.panel.list.registerPage('content_view_definitions', { create : 'new_content_view_definition' });

KT.panel.set_expand_cb(function() {
    $('a.remove.disabled').tipsy({ fade:true, gravity:'s', delayIn:500, html:true, className:'content-tipsy',
        title:function() { return $('.hidden-text.hidden').html();} });

    KT.object.label.initialize();
    KT.content_view_definition.initialize();
    KT.content_view_definition.initialize_views();
    KT.content_view_definition.initialize_composite_content();
    KT.content_view_definition.initialize_create();
});

KT.content_view_definition = (function(){
    var status_updater,

    initialize = function() {
        $("#view_definitions").treeTable({
            expandable: true,
            initialState: "expanded",
            clickableNodeNames: true,
            onNodeShow: function(){$.sparkline_display_visible()}
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
        })
    },
    initialize_composite_content = function() {
        var pane = $("#composite_definition_content");
        if (pane.length === 0) {
            return;
        }
        $("#update_component_views").click(function(){
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
    },
    initialize_views = function() {
        var pane = $("#content_view_definition_views");
        if (pane.length === 0) {
            return;
        }
        initialize_refresh();
        initialize_views_treetable();
        startUpdater();
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
                    startUpdater();
                },
                error: function() {
                    KT.panel.panelAjax('', $('#content_view_definition_views').data('views_url'), $('#panel'), false);
                }
            });
        });
    },
    initialize_views_treetable = function() {
        $("#content_views").treeTable({
            expandable: true,
            initialState: "expanded",
            clickableNodeNames: true,
            onNodeShow: function(){$.sparkline_display_visible()}
        });
    },
    startUpdater = function () {
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
            }, updateStatus);
        }
    },
    updateStatus = function(data) {
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
        initialize_views             : initialize_views
    };
}());