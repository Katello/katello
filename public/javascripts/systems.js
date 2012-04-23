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


/*
 * A small javascript file needed to load system subscription related stuff
 *
 */
KT.panel.set_expand_cb(function(){
    var children = $('#panel .third_level:first-child');

    $.each(children, function(i, item) {
        KT.menu.hoverMenu(item, { top : '75px' });
    });

    $(".multiselect").multiselect({"dividerLocation":0.5, "sortable":false});
});

KT.panel_search_autocomplete = KT.panel_search_autocomplete.concat(["distribution.name:", "distribution.version:", "network.hostname:", "network.ipaddr:", "...Any System Fact"]);

(function(){
    var options = { create : 'new_system' };

    if (window.env_select !== undefined) {

        // When the systems index page env selector changes, update the pre-populated attributes
        env_select.env_changed_callback = function(env_id) {
            if(env_select.envsys == true){
                $('#new').attr('data-ajax_url', KT.routes.new_system_path() + '?env_id=' + env_id);
            }
            $('#system_environment_id').attr('value', env_id);
        };

        $.extend(options, { 'extra_params' :
					[ { hash_id 	: 'env_id',
						init_func 	: function(){
							var state = $.bbq.getState('env_id'); 
							
							if( state ){ 
								env_select.set_selected(state); 
							} else {
								$.bbq.pushState({ env_id : env_select.get_selected_env() });
							}
						}
				  	} 
				]});
  	}
  	KT.panel.list.registerPage('systems', options);
}());

$(document).ready(function() {

  KT.panel.set_expand_cb(function() {
    KT.subs.initialize_edit();
  });

  KT.systems_page.registerActions();
  KT.systems_page.system_group_setup();

    // These run after the subscribe/unsubscribe forms have been submitted to update
    // the left hand list entry (which reflects the subscribed status of the system).
    $('#unsubscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left').find('.active');
        var url = id.attr('data-ajax_url');
        url = url.substring(0, url.length - 5);  // Strip off trailing '/edit'
        KT.panel.list.refresh(id.attr('id'), url);
        $(this).find('input[type="submit"]').removeAttr('disabled');
    }).live('ajax:before', function(){
        $(this).find('input[type="submit"]').attr('disabled', 'disabled');
    });

    $('#subscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left').find('.active');
        var url = id.attr('data-ajax_url');
        url = url.substring(0, url.length - 5);  // Strip off trailing '/edit'
        KT.panel.list.refresh(id.attr('id'), url);
        $(this).find('input[type="submit"]').removeAttr('disabled');
    }).live('ajax:before', function(){
        $(this).find('input[type="submit"]').attr('disabled', 'disabled');
    });
});

KT.systems_page = function() {
    var env_change = function(env_id, element) {
      var url = element.attr("data-url");
      window.location = url;
    },
    create_system = function(data) {
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
    registerActions = function() {
        var removeSystem = $(".panel_action[data-id=remove_systems]"),
            package = $(".panel_action[data-id=systems_package_action]"),
            errata = $(".panel_action[data-id=systems_errata_action]"),
            system_group = $(".panel_action[data-id=systems_system_groups_action]");

        KT.panel.actions.registerAction("remove_systems",
            {  url: removeSystem.attr("data-url"),
               method: removeSystem.attr("data-method"),
               success_cb: function(ids){
                    $.each(ids,function(index, item){
                        list.remove("system_" + item);
                    });
               }
            }
        );

        KT.panel.actions.registerAction("systems_package_action",
            {
                enable_cb: function() {
                    $('#packages_input').removeAttr('disabled');
                    $('#systems_action_packages').removeAttr('disabled');
                    $('#systems_action_package_groups').removeAttr('disabled');
                    $('.request_action.package').removeAttr('disabled');
                },
                disable_cb: function() {
                    $('#packages_input').attr('disabled', true);
                    $('#systems_action_packages').attr('disabled', true);
                    $('#systems_action_package_groups').attr('disabled', true);
                    $('.request_action.package').attr('disabled', true);
                    package.find('.validation_error').hide();
                },
                valid_input_cb: function() {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        content_type_selected = $("input[name=systems_action]:checked"),
                        content_id = content_type_selected.attr('id'),
                        content_input = $.trim($('#packages_input').val()),
                        content_error = package.find('.validation_error');

                    if (content_type_selected.length === 0) {
                        // an content type hasn't been selected
                        content_error.html(i18n.validation_error_select_content_type);
                        valid = false;
                    }
                    else if (content_input.length === 0) {
                        if (content_id === 'systems_action_packages') {
                            // the pkg list is empty, but the action is install or remove
                            content_error.html(i18n.validation_error_pkg_list_empty);
                            valid = false;
                        } else {
                            // user selected pkg groups
                            content_error.html(i18n.validation_error_pkg_group_list_empty);
                            valid = false;
                        }
                    }
                    else if ((content_id === 'systems_action_packages') && !KT.packages.valid_package_list_format(content_input.split(/ *, */))) {
                        // the pkg list is invalid
                        content_error.html(i18n.validation_error_pkg_name_format);
                        valid = false;
                    }
                    if (valid) {
                        content_error.hide();
                    } else {
                        content_error.show();
                    }
                    return valid;
                },
                ajax_cb: function(ids_selected, request_action, confirm_dialog) {
                    var content_type_selected = $("input[name=systems_action]:checked").attr('id'),
                        content_array = [],
                        content_string = $.trim($('#packages_input').val());

                    if (content_string.length > 0) {
                        content_array = content_string.split(/ *, */);
                    }

                    if (content_type_selected === 'systems_action_packages') {
                        $.ajax({
                            cache: 'false',
                            type: request_action.attr('data-method'),
                            url: request_action.attr('data-url'),
                            data: {ids:ids_selected, packages:content_array},
                            success: function() {
                                // on success, close the request confirmation dialog
                                confirm_dialog.slideUp('fast');
                            }
                        });
                    } else {
                        $.ajax({
                            cache: 'false',
                            type: request_action.attr('data-method'),
                            url: request_action.attr('data-url'),
                            data: {ids:ids_selected, groups:content_array},
                            success: function() {
                                // on success, close the request confirmation dialog
                                confirm_dialog.slideUp('fast');
                            }
                        });
                    }
                }
            }
        );

        KT.panel.actions.registerAction("systems_errata_action",
            {
                enable_cb: function() {
                    $('#errata_input').removeAttr('disabled');
                    $('.request_action.errata').removeAttr('disabled');
                },
                disable_cb: function() {
                    $('#errata_input').attr('disabled', true);
                    $('.request_action.errata').attr('disabled', true);
                    errata.find('.validation_error').hide();
                },
                valid_input_cb: function() {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        errata_input = $.trim($('#errata_input').val()),
                        errata_error = errata.find('.validation_error');

                    if (errata_input.length === 0) {
                        // the errata list is empty
                        errata_error.html(i18n.validation_error_errata_list_empty);
                        valid = false;
                    }
                    if (valid) {
                        errata_error.hide();
                    } else {
                        errata_error.show();
                    }
                    return valid;
                },
                ajax_cb: function(ids_selected, request_action, confirm_dialog) {
                    var errata_string = $('#errata_input').val(),
                        errata_array = errata_string.split(/ *, */);

                    $.ajax({
                        cache: 'false',
                        type: errata.attr('data-method'),
                        url: errata.attr('data-url'),
                        data: {ids:ids_selected, errata:errata_array},
                        success: function() {
                            // on success, close the request confirmation dialog
                            confirm_dialog.slideUp('fast');
                        }
                    });
                }
            }
        );

        KT.panel.actions.registerAction("systems_system_groups_action",
            {
                enable_cb: function() {
                    $('#system_group_input').removeAttr('disabled');
                    $('.request_action.system_group').removeAttr('disabled');
                },
                disable_cb: function() {
                    $('#system_group_input').attr('disabled', true);
                    $('.request_action.system_group').attr('disabled', true);
                    system_group.find('.validation_error').hide();
                },
                valid_input_cb: function() {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        system_group_input = $.trim($('#system_group_input').val()),
                        system_group_error = system_group.find('.validation_error');

                    if (system_group_input.length === 0) {
                        system_group_error.html(i18n.validation_error_system_group_name_empty);
                        valid = false;
                    }
                    if (valid) {
                        system_group_error.hide();
                    } else {
                        system_group_error.show();
                    }
                    return valid;
                },
                ajax_cb: function(ids_selected, request_action, confirm_dialog) {
                    var system_group_string = $('#system_group_input').val();

                    $.ajax({
                        cache: 'false',
                        type: request_action.attr('data-method'),
                        url: request_action.attr('data-url'),
                        data: {ids:ids_selected, system_group:system_group_string},
                        success: function() {
                            // on success, close the request confirmation dialog
                            confirm_dialog.slideUp('fast');
                        }
                    });
                }
            }
        );

        $(".request_action.package").click(function() {
            // Whenever the user selects a package/package group action, update the confirmation text
            var action_text = $(this).val().toLowerCase(),
                content_type_text = $("input[name=systems_action]:checked").next('label').text().toLowerCase(),
                option = $(this).parent().nextAll('div.options'),
                action = option.find('span.action_text'),
                content_type = option.find('span.content_type_text');

            action.html(action_text);
            content_type.html(content_type_text);
        });

        $(".request_action.system_group").click(function() {
            // Whenever the user selects to add/remove a system group, update the confirmation text
            var action_text = $(this).val().toLowerCase(),
                option = $(this).parent().nextAll('div.options'),
                action = option.find('span.action_text');

            action.html(action_text);
        });

    },
    system_group_setup = function() {
        $('#update_system_groups').live('submit', update_system_groups);
        var current_input = KT.auto_complete_box({
            values:       KT.routes.auto_complete_system_groups_path(),
            input_id:     "system_group_input"
        });
    },
    update_system_groups = function(e) {
        e.preventDefault();
        var button = $(this).find('input[type|="submit"]');
        button.attr("disabled","disabled");
        $(this).ajaxSubmit({
            success: function(data) {
                button.removeAttr('disabled');
            },
            error: function(e) {
                button.removeAttr('disabled');
            }
        });
    };
  return {
      env_change : env_change,
      create_system : create_system,
      registerActions : registerActions,
      system_group_setup: system_group_setup
  }
}();

KT.packages = function() {
    var valid_package_list_format = function(packages){
        var length = packages.length;

        for (var i = 0; i < length; i += 1){
            if( !valid_package_name(packages[i]) ){
                return false;
            }
        }
        return true;
    },
    valid_package_name = function(package_name){
        var is_match = package_name.match(/[^abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\-\.\_\+\,]+/);

        return is_match === null ? true : false;
    };
return {
        valid_package_list_format : valid_package_list_format,
        valid_package_name : valid_package_name
    }
}();

KT.subs = function() {
    var unsubSetup = function(){
        var unsubform = $('#unsubscribe');
        var unsubbutton = $('#unsub_submit');
        var fakeunsubbutton = $('#fake_unsub_submit');
        var unsubcheckboxes = $('#unsubscribe input[type="checkbox"]');
        var total = unsubcheckboxes.length;
        var checked = 0;
        unsubbutton.hide();
        unsubcheckboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    checked++;
                    if(!(unsubbutton.is(":visible"))){
                        fakeunsubbutton.fadeOut("fast", function(){unsubbutton.fadeIn()});
                    }
                }else{
                    checked--;
                    if((unsubbutton.is(":visible")) && checked == 0){
                        unsubbutton.fadeOut("fast", function(){fakeunsubbutton.fadeIn()});
                    }
                }
            });
        });
    },
    save_selected_environment = function(env_id) {
        // save the id of the env selected
        $("#system_environment_id").attr('value', env_id);
    },
    initialize_edit = function() {
       reset_env_select();
    },
    reset_env_select = function() {
    	if (window.env_select !== undefined) {
	        $('#path-expanded').hide();
	        env_select.reset_hover();
	        env_select.recalc_scroll();
       }
    },
    subSetup = function(){
        var subform = $('#subscribe');
        var subbutton = $('#sub_submit');
        var fakesubbutton = $('#fake_sub_submit');
        var subcheckboxes = $('#subscribe input[type="checkbox"]');
        var total = subcheckboxes.length;
        var checked = 0;
        var spinner;
        var of_string;
        subbutton.hide();

        subcheckboxes.each(function(){
            $(this).change(function(){
                if($(this).is(":checked")){
                    checked++;
                    spinner = $(this).parent().parent().parent().find(".ui-spinner");
                    if(spinner.length > 0){
                        if(spinner.spinner("value") == "0") {
                            spinner.spinner("increment");
                        }
                    }else{
                        $(this).parent().parent().parent().find(".ui-nonspinner").val(1);
                        spinner = $(this).parent().parent().parent().find(".ui-nonspinner-label")[0];
                        if(spinner) {
                            of_string = "1" + spinner.innerHTML.substr(1);
                            spinner.innerHTML = of_string;
                        }
                    }
                    if(!(subbutton.is(":visible"))){
                        fakesubbutton.fadeOut("fast", function(){subbutton.fadeIn()});
                    }
                }else{
                    checked--;
                    spinner = $(this).parent().parent().parent().find(".ui-spinner");
                    if(spinner.length > 0){
                        spinner.spinner("value", 0);
                    }else{
                        $(this).parent().parent().parent().find(".ui-nonspinner").val(0);
                        spinner = $(this).parent().parent().parent().find(".ui-nonspinner-label")[0];
                        if(spinner) {
                            of_string = "0" + spinner.innerHTML.substr(1);
                            spinner.innerHTML = of_string;
                        }
                    }
                    if((subbutton.is(":visible")) && checked == 0){
                        subbutton.fadeOut("fast", function(){fakesubbutton.fadeIn()});
                    }
                }
            });
        });
    },
    spinnerSetup = function(){
        setTimeout("$('.ui-spinner').spinner()",1000);
    },
    autohealSetup = function(){
        var checkboxes = $('#autoheal');
        checkboxes.each(function(){
          $(this).unbind("change");
          $(this).change(function(){
            $('#autoheal_form').ajaxSubmit({
              data: { autoheal: $(this).is(":checked") },  // Checkboxes in forms aren't included when false
              dataType: 'html',
              success: function(data) {
                notices.checkNotices();
              }, error: function(e) {
                notices.checkNotices();
              }
            });
          });
        });
    },

    matchsystemSetup = function(){
      $('#matchsystem').unbind("click");
      $('#matchsystem').change(function(e){
        $('#matchsystem_form').ajaxSubmit({
          data: { value: $(this).is(":checked") },  // Checkboxes in forms aren't included when false
          dataType: 'html',
          success: function(data) {
            notices.checkNotices();
            $('#subscriptions > a').click();
          }, error: function(e) {
            notices.checkNotices();
            $('#subscriptions > a').click();
          }
        });
      });
    };
    
    return {
        unsubSetup: unsubSetup,
        subSetup: subSetup,
        spinnerSetup: spinnerSetup,
        save_selected_environment: save_selected_environment,
        initialize_edit: initialize_edit,
        reset_env_select: reset_env_select,
        autohealSetup: autohealSetup,
        matchsystemSetup: matchsystemSetup
    }
}();
