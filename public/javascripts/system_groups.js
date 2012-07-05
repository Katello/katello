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


KT.panel.list.registerPage('system_groups', { create : 'new_system_group' });

$(document).ready(function() {
    KT.panel.set_expand_cb(function(){
        var children = $('#panel .menu_parent');
        $.each(children, function(i, item) {
            KT.menu.hoverMenu(item, { top : '75px' });
        });

        KT.system_groups.init();
        KT.system_groups.new_setup();
        KT.system_groups.details_setup();
    });
});


KT.sg_table = (function(){
    var add_system = function(html){
        var tbody =  $("#systems_table").find("tbody");
        tbody.prepend(html);
        tbody.find(".empty_row").hide();
        recalc_rows();
        KT.system_groups.refresh_list_item();
    },
    remove_system = function(ids){
        var table = $("#systems_table"),
            rows;
        $.each(ids, function(index, value){
            table.find("tr[data-id=" + value +"]").remove();
        });
        //show the empty message if there are no entries
        rows = table.find('tbody').find('tr').not('.empty_row');
        if(rows.length === 0){
            table.find(".empty_row").show();
        }
        recalc_rows();
        KT.system_groups.refresh_list_item();
    },
    recalc_rows = function(){
        /*
         * ensures that there are minimum number of rows in the table
         * for aesthetics
         */
        var min_rows = 12,
            tbody = $("#systems_table").find("tbody"),
            rows,
            missing;

        tbody.find('.stub').remove();
        rows = tbody.find('tr').not('.empty_row');
        missing = min_rows - rows.length;
        if (missing > 0){
            for(var i = 0; i < missing; i++){
                tbody.append("<tr class='stub'><td><br></td><td></td></tr>");
            }
        }
        rows = tbody.find('tr').not('.empty_row').not('.stub');
        var alt = 1;
        rows.each(function(index, value){
            if(alt % 2 == 0){
                $(value).addClass('alt')
            }
            else {
                $(value).removeClass('alt')
            }
            alt++;
        });

    };

    return {
        add_system: add_system,
        remove_system: remove_system,
        recalc_rows: recalc_rows
    };
}());

KT.system_groups = (function(){
    var current_system_input,
        current_max_systems = undefined,
        systems_deletable = false,
    lockedChanged = function(){
        var checkbox = $(this),
        name = $(this).attr("name"),
        options = {};
        if (checkbox.attr("checked") !== undefined) {
            options[name] = true;
        } else {
            options[name] = false;
        }
        $.ajax({
            type: "POST",
            url: checkbox.attr("data-url"),
            data: options,
            cache: false,
            success:function(){
                refresh_list_item();
            }
        });
        return false;
    },
    refresh_list_item = function(){
        var id = $('#system_group_id');
        list.refresh(id.val(), id.data('ajax_url'))
    },
    quota_setup = function() {
        // quota_setup is used for both the 'new' and 'edit' panes.  While the logic is nearly the same
        // there are slight differences, since the 'edit' uses inline editing, but the 'new' does not.
        var unlimited = '-1',
            initial_max = undefined;

        if ($('system_group_new').length > 0) {
            // user is creating a group
            initial_max = $('#system_group_max_systems').val();
        } else {
            // user is editing a group
            initial_max = $('#system_group_max_systems').html();
        }
        current_max_systems = initial_max.length === 0 ? unlimited : initial_max;

        $('input.unlimited_members').unbind('click');
        $('input.unlimited_members').bind('click', function(){
            var max_systems_element = $('.limit'),
                max_systems = $('#system_group_max_systems');

            if($(this).is(":checked")){
                // user checked unlimited
                max_systems_element.hide();
                max_systems.val(unlimited);

                if (max_systems.hasClass('editable')) {
                    // user is editing an existing group
                    if (max_systems.val() !== current_max_systems) {
                        // user has changed the value since toggling unlimited on/off/on, so send request to server to set max_systems to unlimited
                        $.ajax({
                            type: "PUT",
                            url: max_systems.data("url"),
                            data: {system_group:{max_systems:unlimited}},
                            cache: false,
                            success: function(data) {
                                max_systems.html(i18n.clickToEdit); // reset the jeditable input
                                current_max_systems = unlimited;
                            },
                            error: function() {
                            }
                        });
                    }
                }
            } else {
                // user unchecked unlimited
                max_systems.val('');
                max_systems_element.show();

                if (max_systems.hasClass('editable')) {
                    // user is editing an existing group, send a click event to jeditable to open, so the user doesn't need to
                    max_systems.click();
                }
            }
        });
    },
    init = function(){
        $('.pane_action.remove').bind('click', prompt_to_destroy_group);
    },
    prompt_to_destroy_group = function(e) {
        e.preventDefault();
        KT.common.customConfirm({
            message: i18n.delete_system_group_confirm,
            yes_callback: function(){
                if (systems_deletable) {
                    // User selected "Yes", ask if they also want to delete the systems
                    prompt_to_destroy_systems();
                } else {
                    // User selected "No", they only want to delete the group
                    destroy_group();
                }
            }
        });
        return false;
    },
    prompt_to_destroy_systems = function() {
        KT.common.customConfirm({
            message: i18n.delete_systems_confirm,
            warning_message: i18n.delete_systems_warning,
            yes_callback: function(){
                // User selected "Yes"
                destroy_systems_and_group();
            },
            no_callback: function(){
                // User selected "No"
                destroy_group();
            },
            no_text: i18n.delete_system_group_continue,
            include_cancel: true
        });
        return false;
    },
    destroy_systems_and_group = function() {
        var id = $('#system_group_id').attr('name');
        $.ajax({
            type: "DELETE",
            url: KT.routes.destroy_systems_system_group_path(id),
            cache: false,
            success: function(data) {
                eval(data);
            }
        });
    },
    destroy_group = function() {
        var id = $('#system_group_id').attr('name');
        $.ajax({
            type: "DELETE",
            url: KT.routes.system_group_path(id),
            cache: false,
            success: function(data) {
                eval(data);
            }
        });
    },
    new_setup = function(){
        var pane = $("#system_group_new");
        if (pane.length === 0){
            return;
        }
        quota_setup();
    },
    details_setup = function(){
        var pane = $("#system_group_edit");
        if (pane.length === 0){
            return;
        }
        pane.find('#system_group_locked').bind('change', KT.system_groups.lockedChanged);
        pane.find(".edit_name").each(function(){
            $(this).editable($(this).data("url"), {
                type        :  'text',
                width       :  250,
                method      :  'PUT',
                name        :  $(this).attr('name'),
                cancel      :  i18n.cancel,
                submit      :  i18n.save,
                indicator   :  i18n.saving,
                tooltip     :  i18n.clickToEdit,
                placeholder :  i18n.clickToEdit,
                submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
                onsuccess   :  refresh_list_item
            });
        });
        pane.find(".edit_max_systems").each(function(){
            $(this).editable($(this).data("url"), {
                type        :  'text',
                width       :  250,
                method      :  'PUT',
                name        :  $(this).attr('name'),
                cancel      :  i18n.cancel,
                submit      :  i18n.save,
                indicator   :  i18n.saving,
                tooltip     :  i18n.clickToEdit,
                placeholder :  i18n.clickToEdit,
                submitdata  :  $.extend({ authenticity_token: AUTH_TOKEN }, KT.common.getSearchParams()),
                onsuccess   :  function(data){
                    $(this).html(data);
                    current_max_systems = data;
                },
                onresetcomplete :  function(settings, element){
                    // This event is invoked on cancel, esc and click outside of the element.
                    // When this occurs, if the user hasn't changed the value, reset to 'unlimited', hiding
                    // the limit element.
                    if ($(element).html() === i18n.clickToEdit) {
                        $('.limit').hide();
                        $('input.unlimited_members').attr('checked', 'checked');
                    }
                }
            });
        });
        quota_setup();
    },
    systems_setup = function(systems_deletable_perm){
        var pane = $("#system_group_systems");
        if (pane.length === 0){
            return;
        }
        systems_deletable = systems_deletable_perm;

        KT.sg_table.recalc_rows();
        $('#remove_systems').click(function(){
            var sys_ids = $('.system_checkbox:checked').map(function(){
                return $(this).data('id');
            }).get();
            if(sys_ids.length > 0){
                remove_systems(sys_ids, $(this));
            }
        });

        current_system_input = KT.auto_complete_box({
            values:       KT.routes.auto_complete_systems_path(),
            input_id:     "add_system_input",
            form_id:      "system_form",
            add_btn_id:   "add_system",
            selected_input_id: 'add_system_input_id',
            add_cb:       add_system
        });
    },
    add_system = function(string, item_id, cb){
        var grp_id = $("#system_group_systems").data('id'),
        add_funct = function(id){
            if(id){
                submit_change(grp_id, [id], true,
                    function(content){
                        KT.sg_table.add_system(content);
                        $("#add_system_input").val('');
                        cb();
                    },
                    function() {
                        // error_cb - handle scenario where error is returned from the server during 'add'
                        // reset the autocomplete input (e.g. remove the spinner, re-add add button..etc)
                        current_system_input.reset_input();
                        current_system_input.error();
                        cb();
                    });
            }
            else {
                current_system_input.error();
                cb();
            }
        };
        if (item_id) {
            add_funct(item_id);
        }
        else {
            //User did not select from the list, so we must search
            $.get(KT.routes.auto_complete_systems_path(), {term:string}, function(data){
                var found = false;
                $.each(data, function(index, element){
                    console.log(element.label);
                    if (element.label === string){
                        found = element.id;

                        return false;
                    }
                });
                add_funct(found);
            });
        }

    },
    remove_systems = function(sys_ids, btn){
        var grp_id = $("#system_group_systems").data('id'),
            cleanup;

        btn.attr('disabled', 'true');
        $('.system_checkbox').attr('disabled', 'true');

        cleanup = function(){
            btn.removeAttr('disabled');
            $('.system_checkbox').removeAttr('disabled');
        };

        submit_change(grp_id, sys_ids, false,
            function(){
                KT.sg_table.remove_system(sys_ids);
                cleanup();
            },
            function(){
                cleanup();
            });
    },
    submit_change = function(grp_id, sys_ids, add, cb, error_cb){
      var url = add ? KT.routes.add_systems_system_group_path(grp_id) :
                        KT.routes.remove_systems_system_group_path(grp_id);
      $.post(url, {'system_ids':sys_ids}, cb).error(error_cb);
    };

    return {
        lockedChanged: lockedChanged,
        init: init,
        new_setup: new_setup,
        details_setup: details_setup,
        systems_setup: systems_setup,
        add_system : add_system,
        refresh_list_item: refresh_list_item
    }
})();

