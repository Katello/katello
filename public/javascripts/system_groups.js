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
        KT.system_groups.details_setup();
        KT.system_groups.systems_setup();
    });


});


KT.system_groups = (function(){
    var lockedChanged = function(){
        var checkbox = $(this),
        name = $(this).attr("name"),
        options = {};
        if (checkbox.attr("checked") !== undefined) {
            options[name] = true;
        } else {
            options[name] = false;
        }
        $.ajax({
            type: "PUT",
            url: checkbox.attr("data-url"),
            data: options,
            cache: false
        });
        return false;
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
                onsuccess   :  function(data){
                    var id = $('#system_group_id');
                    list.refresh(id.val(), id.data('ajax_url'))
                }
            });
        })
    },
    systems_setup = function(){
        var pane = $("#system_group_systems");
        if (pane.length === 0){
            return;
        }

        var current_input = KT.auto_complete_box({
            values:       KT.routes.auto_complete_systems_path(),
            input_id:     "add_system_input",
            form_id:      "system_form",
            add_btn_id:   "add_system",
            add_cb:       add_system
        });

    },
    add_system = function(item, foo, bar){

        console.log(item);
        console.log(foo);
        console.log(bar);
    };

    return {
        lockedChanged: lockedChanged,
        details_setup: details_setup,
        systems_setup: systems_setup,
        add_system : add_system
    }
})();

