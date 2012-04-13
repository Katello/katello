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
	KT.menu.hoverMenu('#panel .third_level:first-child', { top : '75px' });
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
            package_error = package.find('.validation_error'),
            package_group = $(".panel_action[data-id=systems_package_group_action]"),
            package_group_error = package_group.find('.validation_error'),
            errata = $(".panel_action[data-id=systems_errata_action]"),
            errata_error = errata.find('.validation_error');

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
                valid_input_cb: function() {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        selected_action = $("input[name=package_action]:checked"),
                        action_id = selected_action.attr('id'),
                        packages_input = $.trim($('#packages_input').val());

                    if (selected_action.length === 0) {
                        // an action hasn't been selected
                        package_error.html(i18n.validation_error_select_action);
                        valid = false;
                    }
                    else if ((action_id !== 'package_action_update_packages') && (packages_input.length === 0)) {
                        // the pkg list is empty, but the action is install or remove
                        package_error.html(i18n.validation_error_pkg_list_empty);
                        valid = false;
                    }
                    else if (!KT.packages.valid_package_list_format(packages_input.split(/ *, */))) {
                        // the pkg list is invalid
                        package_error.html(i18n.validation_error_pkg_name_format);
                        valid = false;
                    }
                    if (valid) {
                        package_error.html('');
                    }
                    return valid;
                },
                ajax_cb: function(ids_selected, confirm_dialog) {
                    var action_selected = $("input[name=package_action]:checked"),
                        package_array = [],
                        package_string = $.trim($('#packages_input').val());

                    if (package_string.length > 0) {
                        package_array = package_string.split(/ *, */);
                    }
                    $.ajax({
                        cache: 'false',
                        type: package.attr('data-method'),
                        url: action_selected.attr('data-url'),
                        data: {ids:ids_selected, packages:package_array},
                        success: function() {
                            // on success, close the request confirmation dialog
                            confirm_dialog.slideUp('fast');
                        }
                    });
                }
            }
        );

        KT.panel.actions.registerAction("systems_package_group_action",
            {
                valid_input_cb: function() {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        selected_action = $("input[name=package_group_action]:checked"),
                        action_id = selected_action.attr('id'),
                        package_group_input = $.trim($('#package_groups_input').val());

                    if (selected_action.length === 0) {
                        // an action hasn't been selected
                        package_group_error.html(i18n.validation_error_select_action);
                        valid = false;
                    }
                    else if (package_group_input.length === 0) {
                        // the pkg group list is empty
                        package_group_error.html(i18n.validation_error_pkg_group_list_empty);
                        valid = false;
                    }
                    if (valid) {
                        package_group_error.html('');
                    }
                    return valid;
                },
                ajax_cb: function(ids_selected, confirm_dialog) {
                    var action_selected = $("input[name=package_group_action]:checked");
                        group_string = $('#package_groups_input').val(),
                        group_array = group_string.split(/ *, */);

                    $.ajax({
                        cache: 'false',
                        type: package_group.attr('data-method'),
                        url: action_selected.attr('data-url'),
                        data: {ids:ids_selected, groups:group_array},
                        success: function() {
                            // on success, close the request confirmation dialog
                            confirm_dialog.slideUp('fast');
                        }
                    });
                }
            }
        );

        KT.panel.actions.registerAction("systems_errata_action",
            {
                valid_input_cb: function() {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        errata_input = $.trim($('#errata_input').val());

                    if (errata_input.length === 0) {
                        // the errata list is empty
                        errata_error.html(i18n.validation_error_errata_list_empty);
                        valid = false;
                    }
                    if (valid) {
                        errata_error.html('');
                    }
                    return valid;
                },
                ajax_cb: function(ids_selected, confirm_dialog) {
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

        $(".radio_option").click(function() {
            // Whenever the user selects a radio button, update the action value in the confirmation text
            var label_text = $(this).next('label').text().toLowerCase(),
                option_action = $(this).nextAll('div.options').find('span.action_text');

            option_action.html(label_text);
        });

    };
  return {
      env_change : env_change,
      create_system : create_system,
      registerActions : registerActions
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
