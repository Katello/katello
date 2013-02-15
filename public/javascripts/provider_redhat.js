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

$(document).ready(function() {


    KT.common.jscroll_init($('.scroll-pane'));
    KT.common.jscroll_resize($('.jspPane'));

    $("#content_tabs").tabs();

  $(".tree_table").treeTable({
    expandable: true,
    initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: KT.redhat_provider_page.on_node_show
  });


  $("#content_tabs").delegate('.repo_enable', 'change', function() {
        KT.redhat_provider_page.repoChange($(this));
    });
  //end doc ready
});


KT.redhat_provider_page = (function($) {
    var repoChange = function(checkbox) {
        var name = checkbox.attr("name");
        var options = {};
        if (checkbox.attr("checked") !== undefined) {
            options['repo'] = "1";
        } else {
            options['repo'] = "0";
        }
        var url = checkbox.attr("data-url");
        var id = checkbox.attr("value");
        $(checkbox).hide();
        $('#spinner_'+id).removeClass('hidden').show();
        $.ajax({
            type: "PUT",
            url: url,
            data: options,
            cache: false,
            success: function(data, textStatus, jqXHR){
              KT.redhat_provider_page.checkboxHighlightRow(data);
            }
        });
        return false;
    },
    checkboxHighlightRow = function(id){
      $('#repo-'+id).effect('highlight', {'color':'#390'}, 1000);
      $('#spinner_'+id).hide().addClass('hidden');
      $('#input_repo_'+id).show();
    },
    on_node_show = function(a, b, c){
        //$(this).hide();
        $.sparkline_display_visible();
    },
    should_show = function(blacklist, name){

    };

    return {
        repoChange: repoChange,
        checkboxHighlightRow: checkboxHighlightRow,
        on_node_show: on_node_show
    }
}(jQuery));
