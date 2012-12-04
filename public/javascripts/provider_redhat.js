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

  $("#redhatSubscriptionTable").treeTable({
    expandable: true,
    initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: function(){$.sparkline_display_visible()}
  });
    KT.common.jscroll_init($('.scroll-pane'));
    KT.common.jscroll_resize($('.jspPane'));

  $("#products_table").treeTable({
    expandable: true,
    initialState: "collapsed",
    clickableNodeNames: true,
    onNodeShow: function(){$.sparkline_display_visible()}
  });


  $('#products_table input[type="checkbox"]').live('change', function() {
      KT.redhat_provider_page.checkboxChanged($(this));
  });
  //end doc ready
});


KT.redhat_provider_page = (function($) {
    var checkboxChanged = function(checkbox) {
        var name = checkbox.attr("name");
        var options = {};
        if (checkbox.attr("checked") !== undefined) {
            options[name] = "1";
        } else {
            options[name] = "0";
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
    };
    var checkboxHighlightRow = function(id){
      $('#repo-'+id).effect('highlight', {'color':'#390'}, 1000);
      $('#spinner_'+id).hide().addClass('hidden');
      $('#input_repo_'+id).show();
    };
    return {
        checkboxChanged: checkboxChanged,
        checkboxHighlightRow: checkboxHighlightRow
    }
}(jQuery));
