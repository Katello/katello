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
        var singleSelect = activeBlock.parent().attr('data-single-selection') === "true";
        var activeBlockPanelId = activeBlock.attr('panel_id');

        if(activeBlock.hasClass('active')){
            activeBlock.removeClass('active');
            if (one_panel.selectedItems[activeBlockPanelId] !== null) {
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
            if (one_panel.selectedItems[activeBlockPanelId] === undefined) {
                var selected = [];
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
