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

    KT.panel.set_expand_cb(function() {
        activation_key.reset_env_select();
    });

    $('#new_activation_key').live('submit', function(e) {
        e.preventDefault();
        activation_key.create_key($(this));
    });

    $('#remove_key').live('click', function(e) {
        e.preventDefault();
        activation_key.delete_key($(this));
    });

    $('#save_key').live('submit', function(e) {
        e.preventDefault();

        var cancel_button = $('input[id^=cancel_key]');

        activation_key.disable_save();
        cancel_button.attr("disabled", "disabled");

        $(this).ajaxSubmit({
         success: function(data) {
             activation_key.enable_save();
             cancel_button.removeAttr('disabled');
         }, error: function(e) {
             activation_key.enable_save();
             cancel_button.removeAttr('disabled');
         }});
    });

    $('#update_subscriptions').live('submit', function(e) {
        alert("TODO: submit clicked...");
       e.preventDefault();
       var button = $(this).find('input[type|="submit"]');
       button.attr("disabled","disabled");
       $('#sub_form').ajaxSubmit({
         success: function(data) {
               button.removeAttr('disabled');
         }, error: function(e) {
               button.removeAttr('disabled');
         }});
    });

    //Set the callback on the environment selector
    env_select.click_callback = function(env_id) {
        activation_key.save_selected_environment(env_id);
        activation_key.get_system_templates();
        activation_key.get_products();
    };

    $('#activation_key_system_template_id').live('change', function() {
        activation_key.highlight_system_templates(false);
    });
});

var activation_key = (function() {
    return {
        reset_env_select: function() {
            $('#path-expanded').hide();
            env_select.reset_hover();
            env_select.recalc_scroll();
        },
        create_key : function(data) {
            var button = data.find('input[type|="submit"]');
            button.attr("disabled","disabled");
            data.ajaxSubmit({
                success: function(data) {
                    list.add(data);
                    KT.panel.closePanel($('#panel'));
                    KT.panel.select_item(list.last_child().attr("id"));
                },
                error: function(e) {
                    button.removeAttr('disabled');
                }
            });                       
        },
        delete_key : function(data) {
            var answer = confirm(data.attr('data-confirm-text'));
            if (answer) {
                $.ajax({
                    type: "DELETE",
                    url: data.attr('data-url'),
                    cache: false,
                    success: function() {
                        KT.panel.closeSubPanel($('#subpanel'));
                        KT.panel.closePanel($('#panel'));
                        list.remove(data.attr("data-id").replace(/ /g, '_'));
                    }
                });
            }
        },
        get_system_templates : function() {
            // this function will retrieve the system templates associated with a given environment and
            // update the page content, as appropriate
            var url = $('.path_link.active').attr('data-templates_url');

            activation_key.disable_save();
            $.ajax({
                type: "GET",
                url: url,
                cache: false,
                success: function(response) {
                    // update the appropriate content on the page
                    var options = '';

                    // create an html option list using the response
                    options += '<option value="">' + i18n.noTemplate + '</option>';
                    for (var i = 0; i < response.length; i++) {
                        options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
                    }

                    // add the options to the system template select... this select exists on an insert form
                    // or as part of the environment edit dialog
                    $("#activation_key_system_template_id").html(options);

                    activation_key.highlight_system_templates(true);
                    activation_key.enable_save();
                },
                error: function(data) {
                    activation_key.enable_save();
                }
            });
        },
        get_products : function() {
            // this function will retrieve the products associated with a given environment and
            // update the products box with the results
            var url = $('.path_link.active').attr('data-products_url');
            if (url !== undefined) {
                activation_key.disable_save();
                $.ajax({
                    type: "GET",
                    url: url,
                    cache: false,
                    success: function(response) {
                        $('.productsbox').html(response);
                        activation_key.enable_save();
                    },
                    error: function(data) {
                        activation_key.enable_save();
                    }
                });

            }
        },
        save_selected_environment : function(env_id) {
            // save the id of the env selected
            $("#activation_key_environment_id").attr('value', env_id);
        },
        disable_save : function() {
            $('input[id^=save_key]').attr("disabled","disabled");
        },
        enable_save : function() {
            $('input[id^=save_key]').removeAttr('disabled');
        },
        highlight_system_templates : function(add_highlight) {
            var select_input = $('#activation_key_system_template_id');
            if (add_highlight) {
                if( !select_input.next('span').hasClass('highlight_input_text')) {
                    select_input.addClass('highlight_input');
                    select_input.after('<span class ="highlight_input_text">' + i18n.update_template + '</span>');
                }
            } else {
                select_input.removeClass('highlight_input');
                $('.highlight_input_text').remove();
            }
        }
    }
})();

KT.activation_key = function() {
    var availableSubSetup = function(){
        var subbutton = $('#sub_submit');
        var fakesubbutton = $('#fake_sub_submit');
        var subcheckboxes = $('input[type="checkbox"]');
        var checked = 0;
        subbutton.hide();

        subcheckboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    checked++;
                    if(!(subbutton.is(":visible"))){
                        fakesubbutton.fadeOut("fast", function(){subbutton.fadeIn()});
                    }
                }else{
                    checked--;
                    if((subbutton.is(":visible")) && checked == 0){
                        subbutton.fadeOut("fast", function(){fakesubbutton.fadeIn()});
                    }
                }
            });
        });
    };
    return {
        availableSubSetup: availableSubSetup
    }
}();
