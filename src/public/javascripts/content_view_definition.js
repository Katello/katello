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
    KT.object.label.initialize();
    KT.content_view_definition.initialize_views();
});

KT.content_view_definition = (function(){
    var status_updater,

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
        initialize_views : initialize_views
    };
}());