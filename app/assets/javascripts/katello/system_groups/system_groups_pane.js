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

KT.system_groups_pane = (function() {
    var system_groups = $("#system_groups"),
        multiselect_widget,

    add_groups = function(e){
        var checked = $("#system_group").multiselect("getChecked"),
            group_ids = checked.map(function(){return this.value;}).get();

        e.preventDefault();
        disable_inputs();

        $.ajax({
            type: "PUT",
            url: $("input#add_groups").data("url"),
            data: {group_ids:group_ids},
            cache: false,
            success: function(data) {

                // for each group that was added to the system, remove it from the multiselect
                checked.each(function(index, item){
                    var v = $(item).val(),
                        opt = $('option[value="'+v+'"]');

                    opt.remove();
                    multiselect_widget.multiselect('refresh');

                });

                // The response will include a block of html representing the list of groups successfully added.
                // Add that response to the top of the table.
                $("tr#empty_row").hide();
                $("tr#add_groups").after(data);

                enable_inputs();
            },
            error: function() {
                enable_inputs();
            }
        });
    },
    remove_groups = function() {
        var btn = $("input#remove_groups"),
            groups = [],
            checked = $("input.group_select:checked");

        checked.each(function(index, item){
            groups.push($(item).val());
        });
        if (groups.length === 0){
            return;
        }
        disable_inputs();

        $.ajax({
            type: "PUT",
            url: btn.data("url"),
            data: {group_ids:groups},
            cache: false,
            success: function(data) {
                // for each group that was removed from the system, add it to the multiselect
                checked.each(function(index, item){
                    var v = $(item).val(),
                        t = $(item).attr('name'),
                        opt = $('<option />', {value: v, text: t});

                    opt.appendTo(multiselect_widget);
                    multiselect_widget.multiselect('refresh');
                });

                checked.parents("tr").remove();
                if ($("input.group_select").length === 0) {
                    $("tr#empty_row").show();
                }
                enable_inputs();
            },
            error: function() {
                enable_inputs();
            }
        });
    },
    disable_inputs = function(){
        $("input#add_groups").attr("disabled", true);
        $("input#remove_groups").attr("disabled", true);
        $("input.group_select").attr("disabled", true);
        $("#system_group").multiselect('disable');
    },
    enable_inputs = function(){
        $("input#add_groups").removeAttr("disabled");
        $("input#remove_groups").removeAttr("disabled");
        $("input.group_select").removeAttr("disabled");
        $("#system_group").multiselect('enable');
    },
    register_events = function() {
        $("input#add_groups").live('click', add_groups);
        $("input#remove_groups").live('click', remove_groups);
    },
    register_multiselect = function() {
        multiselect_widget = $("#system_group").multiselect({
            noneSelectedText: i18n.select_system_groups,
            selectedList: 4
        }).multiselectfilter();
    };
    return {
        add_groups: add_groups,
        remove_groups: remove_groups,
        register_events: register_events,
        register_multiselect: register_multiselect
    };
})();