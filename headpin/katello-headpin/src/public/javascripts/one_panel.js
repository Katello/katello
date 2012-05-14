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

var one_panel = {
  selectedItems: {},
  setup: function () {
    $('.block').each(function() {
        if ($(this).attr("data-hover-text")) {
            $(this).linkHover({"somethingMore":$(this).attr("data-hover-text")});
        }

    });

    $('.block').live('click', function(e)
    {
        var activeBlock = $(this);

        var activeBlockId = activeBlock.attr('id');
        var singleSelect = activeBlock.parent().attr('data-single-selection') == "true";
        var activeBlockPanelId = activeBlock.attr('panel_id');

        if(activeBlock.hasClass('active')){
            activeBlock.removeClass('active');
            if (one_panel.selectedItems[activeBlockPanelId] != null) {
                var index = $.inArray(activeBlockId, one_panel.selectedItems[activeBlockPanelId]);
                if(index > -1) {
                    one_panel.selectedItems[activeBlockPanelId].splice(index,1);
                }
            }
        }
        else {
            if(singleSelect) {
                $(this).parent().find('.block').removeClass('active');
            }
            activeBlock.addClass('active');
            if (one_panel.selectedItems[activeBlockPanelId] == null) {
                var selected = new Array();
                selected.push(activeBlockId);
                one_panel.selectedItems[activeBlockPanelId] = selected;
            }
            else {
                if(singleSelect) {
                    one_panel.selectedItems[activeBlockPanelId]=[activeBlockId];
                }
                else {
                    one_panel.selectedItems[activeBlockPanelId].push(activeBlockId);
                }
            }
        }
        return false;
    });
  }
};


$(document).ready(function() {
    one_panel.setup();
});
