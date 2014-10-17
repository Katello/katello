/**
 Copyright 2014 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

$(document).ready(function() {
    var spinner = '<i class="icon-spinner inline-icon icon-spin"></i>';

    KT.common.jscroll_init($('.scroll-pane'));
    KT.common.jscroll_resize($('.jspPane'));



    $("#content_tabs").tabs({
        cache: true,
        load: function(event, ui) {
            KT.redhat_provider_page.init_tab($(ui.panel));
        }
    });

    $("#content_tabs > .ui-tabs-panel").append(spinner);

    $("#content_tabs").delegate('.repo_enable', 'change', function() {
        KT.redhat_provider_page.repoChange($(this), false);
    });

    $("#content_tabs").delegate('.repo_set_refresh', 'click', function(){
        var icon = $(this),
            row = icon.parents('.repo_set').first(),
            expanderArea;

        if(!icon.hasClass('disabled')){
            expanderArea = row.find('.expander_area');
            console.log(expanderArea);
            KT.redhat_provider_page.repoSetRefresh(expanderArea);
        }
    });
});


KT.redhat_provider_page = (function($) {
    var repoChange = function(checkbox) {

        var name = checkbox.attr("name"),
            options = {},
            url = checkbox.attr("data-url"),
            id = checkbox.attr("value"),
            set_checkbox = checkbox.parents(".repo_set").find('.repo_set_enable');

        if (checkbox.attr("checked") !== undefined) {
            options['repo'] = "1";
        } else {
            options['repo'] = "0";
        }

        options['content_id'] = checkbox.attr("data-content-id");
        options['releasever'] = checkbox.attr("data-releasever");
        options['basearch'] = checkbox.attr("data-basearch");

        $(checkbox).hide();
        $('#spinner_'+id).removeClass('hidden').show();
        checkbox.parent().parent().siblings().first().find('.errors').remove();
        $.ajax({
            type: "PUT",
            url: url,
            data: options,
            cache: false,
            success: function(data, textStatus, jqXHR){
              KT.redhat_provider_page.checkboxHighlightRow(checkbox.attr("data-pulp-id"));
              if(data['can_disable_repo_set']){
                set_checkbox.removeAttr('disabled');
              }
              else {
                set_checkbox.attr('disabled','disabled');
              }
            },
            error: function(data) {
                checkbox.parent().parent().siblings().first().append(data.responseText);
                $(checkbox).removeClass('hidden').show().attr('checked', false);
                $('#spinner_'+id).addClass('hidden').hide();
            }
        });
        return false;
    },
    repoSetRefresh = function(expanderArea) {
        var url = expanderArea.data('url'),
            content_id = expanderArea.data('content-id');
        refresh_repo_set(url, content_id);
    },
    disable_repo_set = function(url, content_id){
        var row = $('#repo_set_' + content_id);
        hide_repos(content_id);
        row.find('.repo_set_enable').hide();
        row.find('.repo_set_spinner').show();
        row.addClass("disable");
        row.find('.repo_set_refresh').addClass('disabled');
        $.ajax({
            type: "PUT",
            url: url,
            data: {content_id:content_id},
            cache: false,
            success: function(data){
                var checkbox = row.find('.repo_set_enable');
                row.find('table').replaceWith('<table style="display: none;"> </table>');
                checkbox.show();
                if (checkbox.data('orphaned')) {
                    checkbox.attr("disabled", "disabled");
                }
                row.find('.repo_set_spinner').hide();
                row.find('.expander').removeClass('disabled').hide();
                row.find('.repo_set_refresh').removeClass('disabled').hide();
            },
            error: function(){
                row.removeClass("disable");
                row.find('.repo_set_enable').show();
                row.find('.repo_set_spinner').hide();
                row.find('.repo_set_refresh').removeClass('disabled');
            }
        });
    },
    refresh_repo_set = function(url, content_id){
        var row = $('#repo_set_' + content_id);
        row.addClass("disable");
        row.find('.expander').hide();
        row.find('.repo_set_spinner').show();
        $.ajax({
            type: "GET",
            url: url,
            data: {content_id:content_id},
            cache: false,
            success: function(data){
                row.find('table').replaceWith(data);
                row.removeClass("disable");
                row.find('.repo_set_spinner').hide();
                row.find('.expander').show();
                row.find('table').show();
            },
            error: function(){
                row.removeClass("disable");
                row.find('.expander').show();
                row.find('.repo_set_spinner').hide();
            }
        });
    },
    checkboxHighlightRow = function(id){
      $('#repo-'+id).effect('highlight', {'color':'#390'}, 1000);
      $('#spinner_'+id).hide().addClass('hidden');
      $('#input_repo_'+id).show();
    },
    on_node_show = function(a, b, c){
        $.sparkline_display_visible();
    },
    hide_repos = function(content_id){
        var row = $('#repo_set_' + content_id);
        if(row.hasClass('expanded')){
            row.find('.expander_area').click();
        }
    },
    show_repos = function(content_id){
        var row = $('#repo_set_' + content_id);
        if(row.hasClass('collapsed')){
            row.find('.expander_area').click();
        }
    },
    init_tab = function(panel) {
        panel.find(".tree_table").treeTable({
            expandable: true,
            initialState: "collapsed",
            clickableNodeNames: true,
            onNodeShow: KT.redhat_provider_page.on_node_show
        });

        panel.find(".content_table").delegate('.expander_area', 'click', function(){
            var area = $(this),
                row = area.parents('tr').first();
            if(row.hasClass("collapsed")){
                KT.redhat_provider_page.repoSetRefresh(area);
                row.removeClass("collapsed").addClass('expanded');
            } else {
                area.parent().find('table').hide();
                row.addClass("collapsed").removeClass('expanded');
            }
        });

    };

    return {
        repoChange: repoChange,
        checkboxHighlightRow: checkboxHighlightRow,
        on_node_show: on_node_show,
        repoSetRefresh: repoSetRefresh,
        hide_repos: hide_repos,
        init_tab: init_tab
    };
}(jQuery));
