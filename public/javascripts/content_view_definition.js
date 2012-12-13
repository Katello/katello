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
    var initialize_views = function() {
        var pane = $("#content_view_definition_views");
        if (pane.length === 0) {
            return;
        }
        $('.refresh_view').bind('click', function(event) {
            event.preventDefault();
            $.ajax({
                type: 'POST',
                url: $(this).data('url'),
                cache: false,
                success: function(content_view) {
                    // on success, the updated content view will be provided
                    replace_versions(content_view['id'], content_view['versions_details']);
                },
                error: function() {
                }
            });
        });
        initialize_views_treetable();
    },
    initialize_views_treetable = function() {
        $("#content_views").treeTable({
            expandable: true,
            initialState: "expanded",
            clickableNodeNames: true,
            onNodeShow: function(){$.sparkline_display_visible()}
        });
    },
    replace_versions = function(view_id, versions) {
        // remove the current versions
        $('.child-of-view_'+view_id).remove();

        // add in the latest versions
        var html = '', parent = $('#view_' + view_id);
        KT.utils.each(versions, function(version, key) {
            var row = '<tr class="child-of-view_' + view_id + '">';
            row += '<td style="padding-left: 37px;">' + i18n.environments(version['environments'].join(', ')) + '</td>';
            row += '<td>' + version['version'] + '</td>';
            row += '<td>' + version['published'] + '</td>';
            row += '</tr>';
            html = html.concat(row);
        });
        parent.removeClass('initialized');
        parent.after(html);
        initialize_views_treetable();
    };
    return {
        initialize_views : initialize_views
    };
}());