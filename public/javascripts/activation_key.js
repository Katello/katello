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

KT.panel.list.registerPage('activation_keys', { create : 'new_activation_key' });
KT.panel.set_expand_cb(function() {
    var children = $('#panel .menu_parent');
    $.each(children, function(i, item) {
        KT.menu.hoverMenu(item, { top : '75px' });
    });
    KT.system_groups_pane.register_multiselect();
});

$(document).ready(function() {

    KT.panel.set_expand_cb(function() {
        KT.activation_key.initialize_new();
        KT.activation_key.initialize_edit();

        if( $('#subscription_form').length > 0 ){
            KT.activation_key.subscription_setup();
        }
    });

    $('#save_key').live('submit', function(e) {
        e.preventDefault();
        KT.activation_key.save_key($(this));
    });

    $('#cancel_key').live('click', function(e) {
        e.preventDefault();
        KT.activation_key.cancel_key($(this));
    });

    //Set the callback on the environment selector
    env_select.click_callback = function(env_id) {
        KT.activation_key.save_selected_environment(env_id);
        KT.activation_key.get_system_templates();
        KT.activation_key.get_products();
    };

    $('#activation_key_system_template_id').live('change', function() {
        KT.activation_key.highlight_system_templates(false);
    });

    $('.clickable.product_family').live('click', function() {
        KT.activation_key.toggle_family($(this));
    });

    // the parent (product family) was checked, so check all children
    $('.family_checkbox').live('click', function() {
        KT.activation_key.toggle_family_checkboxes($(this), this.checked);
    });

    // a child was checked, so update the parent (product family), if needed
    $('#subscription_form input[type="checkbox"]').live('click', function() {
        KT.activation_key.toggle_parent_checkbox($(this));
    });

     $('input[id^=filter]').live('change, keyup', function(){
         // if the user has cleared the filter box, locate all parents and if a parent is collapsed, hide the children
         if ($.trim($(this).val()).length == 0) {
             var parents = $('tr[data-family_begin]');
             parents.each(function(){
                 // if the parent is collapsed, hide the children
                 var arrow = $(this).find('a img');
                 if(arrow.attr("src").indexOf("collapsed") !== -1){
                     var family = $(this).attr('data-family_begin');
                     $('tr[data-in_family="'+family+'"]').slideToggle();
                 }
             });
         }
     });
    
    KT.system_groups_pane.register_events();
});

KT.activation_key = (function($) {
    var subscription_setup = function(){
        var subbutton = $('#subscription_submit_button');
        var fakesubbutton = $('#fake_subscription_submit_button');
        var subcheckboxes = $('#subscription_form input[type="checkbox"]');
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

        //subbutton.unbind('click').click(disable_submit);
    },
    initialize_new = function() {
        $('#usage_limit_checkbox').live('click', function() {
            KT.activation_key.toggle_usage_limit($(this));
        });
    },
    initialize_edit = function() {
        reset_env_select();
        enable_buttons();
        highlight_system_templates(false);
    },
    reset_env_select = function() {
        $('#path-expanded').hide();
        env_select.reset_hover();
        env_select.recalc_scroll();
    },
    save_key = function(data) {
        disable_buttons();

        data.ajaxSubmit({
         success: function(data) {
             highlight_system_templates(false);
             enable_buttons();
         }, error: function(e) {
             highlight_system_templates(false);
             enable_buttons();
         }});
    },
    cancel_key = function(data) {
        var url = $('#cancel_key').attr('data-url');
        if (url !== undefined) {
            disable_buttons();

            $.ajax({
                type: "GET",
                url: url,
                cache: false,
                success: function(response) {
                    $('.panel-content').html(response);
                    initialize_edit();
                },
                error: function(data) {
                    initialize_edit();
                }
            });
        }
    },
    toggle_family = function(data) {
        // user clicked a product family
        var family = data.closest('tr').attr('data-family_begin');

        // show/hide the elements that are part of the family
        $('tr[data-in_family="'+family+'"]').slideToggle();

        // toggle the expand/collapse arrow
        var arrow = data.find('img');
        if(arrow.attr("src").indexOf("collapsed") === -1){
            arrow.attr("src", "images/embed/icons/expander-collapsed.png");
        } else {
            arrow.attr("src", "images/embed/icons/expander-expanded.png");
        }
    },
    toggle_usage_limit = function(checkbox) {
        var tb = $("#activation_key_usage_limit");
        if (checkbox.is(":checked")) {
            tb.val('');
            tb.attr("disabled", true);
        } else {
            tb.val('');
            tb.removeAttr('disabled');
        }
    },
    toggle_family_checkboxes = function(data, checked) {
        var family = data.closest('tr'),
            family_name = family.attr('data-family_begin');
        family.siblings('tr[data-in_family="'+family_name+'"]').find('input:checkbox').attr('checked', checked);
    },
    toggle_parent_checkbox = function(data) {
        // if all children are checked, the parent should be checked... otherwise, it should be unchecked...
        // so toggle the parent checkbox, if needed...

        // check to see if the child is evan part of a product family...
        var sub = data.closest('tr'),
            in_family = sub.attr('data-in_family');
        if (in_family !== undefined) {
            // locate the family
            var family = sub.prevAll('tr[data-family_begin="'+in_family+'"]');
            if (family !== undefined) {
                // retrieve the checkboxes for the family and siblings
                var family_cbx = family.find('input:checkbox'),
                    sibling_cbxs = family.siblings('tr[data-in_family="'+in_family+'"]').find('input:checkbox'),
                    total = sibling_cbxs.length,
                    num_checked = 0;

                sibling_cbxs.each( function() { if (this.checked) num_checked++; });
                if (total == num_checked) {
                    family_cbx.attr('checked', true);
                }
                else if (num_checked > 0) {
                    family_cbx.attr('checked', false);
                }
                else {
                    family_cbx.attr('checked', false);
                }
            }
        }
    },
    get_system_templates = function() {
        // this function will retrieve the system templates associated with a given environment and
        // update the page content, as appropriate
        var url = $('.path_link.active').attr('data-templates_url');

        disable_buttons();
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

                if (response.length > 0) {
                    highlight_system_templates(true);
                }
                enable_buttons();
            },
            error: function(data) {
                enable_buttons();
            }
        });
    },
    get_products = function() {
        // this function will retrieve the products associated with a given environment and
        // update the products box with the results
        var url = $('.path_link.active').attr('data-products_url');
        if (url !== undefined) {
            disable_buttons();
            $.ajax({
                type: "GET",
                url: url,
                cache: false,
                success: function(response) {
                    $('.productsbox').html(response);
                    enable_buttons();
                },
                error: function(data) {
                    enable_buttons();
                }
            });
        }
    },
    save_selected_environment = function(env_id) {
        // save the id of the env selected
        $("#activation_key_environment_id").attr('value', env_id);
    },
    disable_buttons = function() {
        $('#cancel_key').attr("disabled","disabled");
        $('input[id^=save_key]').attr("disabled","disabled");
    },
    enable_buttons = function() {
        $('#cancel_key').removeAttr('disabled');
        $('input[id^=save_key]').removeAttr('disabled');
    },
    highlight_system_templates = function(add_highlight) {
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
    };
    return {
        subscription_setup: subscription_setup,
        initialize_new: initialize_new,
        initialize_edit: initialize_edit,
        reset_env_select: reset_env_select,
        save_key: save_key,
        cancel_key: cancel_key,
        toggle_family: toggle_family,
        toggle_usage_limit: toggle_usage_limit,
        toggle_family_checkboxes: toggle_family_checkboxes,
        toggle_parent_checkbox: toggle_parent_checkbox,
        get_system_templates: get_system_templates,
        get_products: get_products,
        save_selected_environment: save_selected_environment,
        disable_buttons: disable_buttons,
        enable_buttons: enable_buttons,
        highlight_system_templates: highlight_system_templates
    }
}(jQuery));

