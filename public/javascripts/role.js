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

    $('#save_role_button').live('click',roles_page.create_new_role);
    $('div[id^="closed_"]').live('click', roles_page.show_permission);
    $('#add_permission').live('click',roles_page.add_permission);

    $('div[id^=cancel_button_]').live('click',roles_page.cancel_permission);
    $('div[id=delete_permission]').live('click',roles_page.remove_permission);

	$('input[data_type=tags]:radio:checked').live("change", roles_page.toggle_available);
	$('input[data_type=verbs]:radio:checked').live("change", roles_page.toggle_available);

	$('select[data_type=types]').live("change", roles_page.update_verbs_and_scopes);

	$('div[id=save_permission]').live("click", roles_page.form_submit);
});


var roles_page = function() {
    //Re-creates new buttons that might have been added
    var reset_buttons = function() {
        $('input[data_type=tags]:radio:checked').trigger("change");
        $('input[data_type=verbs]:radio:checked').trigger("change");
    },
    show_permission = function(event) {
        $(this).hide();
        $(this).siblings("div[id^=opened_]").show();
    },
    remove_permission = function () {
        var role_id = $(this).attr("data_role_id");
        var perm_id = $(this).attr("data_perm_id");

        $.ajax({
            type: "PUT",
            url: "/roles/" + role_id,
            data: { "role":{ "permissions_attributes": {"0":
                                                {"id": perm_id,
                                                "_destroy":1} }}},
            cache: false
        });

        $(this).closest(".permission").remove();
        $("#permissions :hidden[value=" + perm_id+ "]").remove();
    },
    add_permission = function() {
        var button = $(this);

        if (button.hasClass("disabled")) {return false;}
        if ($('.new_permission_save').length  > 0) {return false;}

        button.addClass("disabled");

        $.ajax({
            type: "GET",
            url: button.attr("data_url"),
            data: {"role_id":button.attr("data_id")},
            cache: false,
            success: function(data) {
                button.removeClass("disabled");
                $(data).insertBefore("#add_permission");
            },
            error: function(data) {button.removeClass("disabled");},
            dataType: "html"
        });

    },
    cancel_permission = function() {
        var button = $(this);
        if (button.hasClass("disabled")){return false;}
        var parent = button.parents("div[id^=permission_]");

        if(button.attr("data_is_new") == "true"){
            parent.remove();
        }
        else {
            button.addClass("disabled");
            $.ajax({
                type: "GET",
                url: button.attr("data_url"),
                data: {"role_id":button.attr("data_role_id"), "perm_id":button.attr("data_perm_id")},
                cache: false,
                success: function(data) {
                 button.removeClass("disabled");
                 parent.replaceWith(data);
                },
                 error: function(){button.removeClass("disabled");},
                dataType: "html"
            });            
        }
    },
    form_submit = function(event){
        var button = $(this);
        if (button.hasClass("disabled")){return false;}
        button.addClass("disabled");
        // we want to submit the form using Ajax (prevent page refresh)
        event.preventDefault();
        // store reference to the form
        var form = $(this).closest("form");
        // grab the url from the form element
        var url = form.attr('action');
        var method = form.attr('method');
        // prepare the form data to send
        var dataToSend = form.serialize();

        var on_success = function(dataReceived){
            button.removeClass("disabled");
            var perm_div = form.closest("div[id^=permission_]");
            perm_div.replaceWith(dataReceived);
            reset_buttons();
        };

        $.ajax({
            type: method,
            url: url,
            data: dataToSend,
            cache: false,
            success: on_success,
            error: function(){button.removeClass("disabled");},
            dataType: "html"
        });        
    },
    create_new_role = function (){
        var button = $(this);
        if (button.hasClass("disabled")) {return false;}
        button.addClass("disabled");

        $.ajax({
            type: "POST",
            url: "/roles/",
            data: { "role":{"name":$('#role_name_field').val()}},
            cache: false,
            success: function(data) {
                  list.add(data);
                  panel.closePanel($('#panel'));
                },
            error: function(){button.removeClass("disabled");}
        });
    },
    update_verbs_and_scopes = function() {
        var verb_box = $(this).closest("div[id^=permission_]").find('select[data_type=verbs]');
        var scope_box = $(this).closest("div[id^=permission_]").find('select[data_type=tags]');
        var resource_type = $('option:selected',$(this)).val();
        $.ajax({
            type: "GET",
            url: "/roles/resource_type/" + resource_type  + "/verbs_and_scopes",
            data: {},
            dataType: 'json',
            cache: false,
            success: function(json){
                    //remove all the existing options
                    $('option',verb_box).remove();
                    $('option',scope_box).remove();
                    //add new options
                    $.each(json.verbs, function(index, name) {
                        var optionName = name;
                        var optionValue = name;
                        $('<option/>').attr('value',optionValue).text(optionName).appendTo(verb_box);
                    });
                    $.each(json.scopes, function(index, scope) {
                        var optionName = scope.display_name;
                        var optionValue = scope.name;
                        $('<option/>').attr('value',optionValue).text(optionName).appendTo(scope_box);
                    });                
            },
            error: function(){}
        });
    },
    toggle_available = function () {
          var type = $(this).attr("data_type");
          var select_box = $(this).closest("div[id^=permission_]").find('select[data_type='+type + ']');
          if ($(this).val() == "true") {
            select_box.attr("disabled", true);
          }
          else {
            select_box.removeAttr("disabled");
          }
    };


    return {
        form_submit: form_submit,
        cancel_permission: cancel_permission,
        add_permission: add_permission,
        remove_permission: remove_permission,
        show_permission: show_permission,
        reset_buttons: reset_buttons,
        create_new_role: create_new_role,
        update_verbs_and_scopes: update_verbs_and_scopes,
        toggle_available: toggle_available
    }
}();

