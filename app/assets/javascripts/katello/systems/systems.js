/**
 Copyright 2011-2013 Red Hat, Inc.

 This software is licensed to you under the GNU General Public
 License as published by the Free Software Foundation; either version
 2 of the License (GPLv2) or (at your option) any later version.
 There is NO WARRANTY for this software, express or implied,
 including the implied warranties of MERCHANTABILITY,
 NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
 have received a copy of GPLv2 along with this software; if not, see
 http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
*/

KT.panel.set_expand_cb(function(){
    var children = $('#panel .menu_parent');
    $.each(children, function(i, item) {
        KT.menu.hoverMenu(item, { top : '75px' });
    });

    KT.system_groups_pane.register_multiselect();

    setTimeout(function() {
        $('#subscription_filters').attr('disabled', false).trigger('liszt:updated');
    }, 500);
});

if (KT.panel_search_autocomplete !== undefined) {
    KT.panel_search_autocomplete = KT.panel_search_autocomplete.concat(["distribution.name:", "distribution.version:", "network.hostname:", "network.ipaddr:"]);
}

(function(){
    var options = { create : 'new_system' };

    if (window.env_select !== undefined) {

        // When the systems index page env selector changes, update the pre-populated attributes
        env_select.env_changed_callback = function(env_id) {
            if(env_select.envsys === true){
                $('#new').attr('data-ajax_url', KT.routes.new_system_path() + '?env_id=' + env_id);
            }
            if($("#system_content_view_id").length > 0) {
                KT.systems_page.update_content_views();
            }
            $('#system_environment_id').attr('value', env_id);
        };

        $.extend(options, { 'extra_params' :
                    [ { hash_id     : 'env_id',
                        init_func     : function(){
                            if ($.bbq) {
                                var state = $.bbq.getState('env_id');

                                if( state ){
                                    env_select.set_selected(state);
                                } else {
                                    $.bbq.pushState({ env_id : env_select.get_selected_env() });
                                }
                            }
                        }
                    }
                ]});
      }
      KT.panel.list.registerPage('systems', options);
}());

$(document).ready(function() {

    KT.panel.set_expand_cb(function() {
        KT.systems_page.system_info_setup();
        KT.subs.initialize_edit();
    });

    KT.systems_page.registerActions();
    KT.systems_page.system_group_setup();
    KT.system_groups_pane.register_events();

    // These run after the subscribe/unsubscribe forms have been submitted to update
    // the left hand list entry (which reflects the subscribed status of the system).
    $('#unsubscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left_panel').find('.active');
        var url = id.attr('data-ajax_url');
        KT.panel.list.refresh(id.attr('id'), url);
        $(this).find('input[type="submit"]').removeAttr('disabled');
    }).live('ajax:before', function(){
        $(this).find('input[type="submit"]').attr('disabled', 'disabled');
    });

    $('#subscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left_panel').find('.active');
        var url = id.attr('data-ajax_url');
        KT.panel.list.refresh(id.attr('id'), url);
        $(this).find('input[type="submit"]').removeAttr('disabled');
    }).live('ajax:before', function(){
        $(this).find('input[type="submit"]').attr('disabled', 'disabled');
    });
});

KT.systems_page = (function() {
    var system_group_widget,
    env_change = function(env_id, element) {
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
            pkg = $(".panel_action[data-id=systems_package_action]"),
            errata = $(".panel_action[data-id=systems_errata_action]"),
            system_group = $(".panel_action[data-id=systems_system_groups_action]");

        KT.panel.actions.registerAction("remove_systems",
            {  url: removeSystem.data("url"),
               method: removeSystem.data("method"),
               success_cb: function(ids){
                    $.each(ids,function(index, item){
                        list.remove("system_" + item);
                    });
               },
                valid_input_cb: function() {
                    var confirmation_text = removeSystem.find('.confirmation_text');
                    confirmation_text.html(i18n.confirm_system_remove_action(KT.panel.numSelected()));
                    return true;
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
                    pkg.find('.validation_error').hide();
                },
                valid_input_cb: function(request_action) {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        content_type_selected = $("input[name=systems_action]:checked"),
                        content_id = content_type_selected.attr('id'),
                        content_input = $.trim($('#packages_input').val()),
                        content_error = pkg.find('.validation_error'),
                        confirmation_text = pkg.find('.confirmation_text');

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

                        // update the confirmation text based on the requested action
                        var action_text = request_action.val().toLowerCase(),
                            content_type_text = content_type_selected.next('label').text().toLowerCase();

                        confirmation_text.html(i18n.confirm_package_action(action_text, content_type_text, KT.panel.numSelected()));

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
                            type: request_action.data('method'),
                            url: request_action.data('url'),
                            data: {ids:ids_selected, packages:content_array},
                            success: function() {
                                // on success, close the request confirmation dialog
                                confirm_dialog.slideUp('fast');
                            }
                        });
                    } else {
                        $.ajax({
                            cache: 'false',
                            type: request_action.data('method'),
                            url: request_action.data('url'),
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
                valid_input_cb: function(request_action) {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        errata_input = $.trim($('#errata_input').val()),
                        errata_error = errata.find('.validation_error'),
                        confirmation_text = errata.find('.confirmation_text');

                    if (errata_input.length === 0) {
                        // the errata list is empty
                        errata_error.html(i18n.validation_error_errata_list_empty);
                        valid = false;
                    }
                    if (valid) {
                        confirmation_text.html(i18n.confirm_errata_action(KT.panel.numSelected()));

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
                        type: errata.data('method'),
                        url: errata.data('url'),
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
                    enable_system_group_inputs();
                },
                disable_cb: function() {
                    disable_system_group_inputs();
                    system_group.find('.validation_error').hide();
                },
                valid_input_cb: function(request_action) {
                    // If the user hasn't provided the necessary inputs, generate an error
                    var valid = true,
                        system_groups_checked = $("#bulk_system_system_group_id").multiselect("getChecked"),
                        system_group_error = system_group.find('.validation_error'),
                        confirmation_text = system_group.find('.confirmation_text');

                    if (system_groups_checked.length === 0) {
                        system_group_error.html(i18n.validation_error_system_group_empty);
                        valid = false;
                    }

                    if (valid) {
                        system_group_error.hide();

                        if (request_action.data('action') === 'add_group') {
                            confirmation_text.html(i18n.confirm_system_group_add_action(KT.panel.numSelected()));
                        } else {
                            confirmation_text.html(i18n.confirm_system_group_remove_action(KT.panel.numSelected()));
                        }
                    } else {
                        system_group_error.show();
                    }
                    return valid;
                },
                ajax_cb: function(ids_selected, request_action, confirm_dialog) {
                    var checked = $("#bulk_system_system_group_id").multiselect("getChecked"),
                        group_ids = checked.map(function(){return this.value;}).get();

                    $.ajax({
                        cache: 'false',
                        type: request_action.data('method'),
                        url: request_action.data('url'),
                        data: {ids:ids_selected, group_ids:group_ids},
                        success: function() {
                            // on success, close the request confirmation dialog
                            confirm_dialog.slideUp('fast');
                        }
                    });
                }
            }
        );
    },
    system_info_setup = function() {
        var pane = $("#system");
        if (pane.length === 0) {
            return;
        }

        KT.env_content_view_selector.init('edit_env_view',
            'environment_path_selector', KT.available_environments, KT.current_environment_id,
            'content_view_selector', KT.available_content_views, KT.current_content_view_id,
            'env_content_view_selector_buttons');
    },
    system_group_setup = function() {
        $('#create_system_group').live('click', create_system_group);
        $('#update_system_groups').live('submit', update_system_groups);

        system_group_widget = $("#bulk_system_system_group_id").multiselect({
            noneSelectedText: i18n.select_system_groups,
            selectedList: 4,
            create: function(event, ui) {
                var html = '<div class="none_matched">'+i18n.group_does_not_exist+'<a id="create_system_group" class="st_button">'+i18n.confirm_create+'</a></div>';
                $('.ui-multiselect-checkboxes').before(html);

            },
            beforeopen: function(event, ui) {
                var none_matched = $('.none_matched');
                none_matched.hide();
            }
        }).multiselectfilter({
            autoReset: true,
            filter: function(event, matches) {
                var none_matched = $('.none_matched'),
                    filter = $('.ui-multiselect-filter > input').val();

                if (!filter.length || $(matches).filter('[title="'+filter+'"]').length) {
                    // found an exact match or the filter is empty
                    none_matched.hide();
                } else {
                    none_matched.show();
                }
            }
        });
        system_group_widget.multiselect('disable');
    },
    create_system_group = function() {
        var group = $('.ui-multiselect-filter > input').val();
        disable_system_group_inputs();
        $.ajax({
            cache: 'false',
            type: 'POST',
            url: KT.routes.system_groups_path(),
            data: {system_group:{name:group}},
            dataType: 'json',
            success: function(response) {
                // add the new group to the multiselect and select it
                var opt = $('<option />', {value: response.id, text: response.name});
                opt.appendTo(system_group_widget);
                opt.attr('selected','selected');
                system_group_widget.multiselect('refresh');
                system_group_widget.multiselect('close');
                enable_system_group_inputs();
            },
            error: function() {
                enable_system_group_inputs();
            }
        });
    },
    disable_system_group_inputs = function(){
        system_group_widget.multiselect('disable');
        $('.request_action.system_group').attr('disabled', true);
    },
    enable_system_group_inputs = function(){
        system_group_widget.multiselect('enable');
        $('.request_action.system_group').removeAttr('disabled');
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
    },
    update_content_views = function(){
        // this function will retrieve the views associated with a given environment and
        // update the views box with the results
        var url = $('.path_link.active').attr('data-content_views_url');
        if (url !== undefined) {
            $.ajax({
                type: "GET",
                url: url,
                cache: false,
                success: function(response) {
                    // update the appropriate content on the page
                    var options = '';
                    var opt_template = KT.utils.template("<option value='<%= key %>'><%= text %></option>");

                    if (response.length > 0) {
                        // create an html option list using the response
                        $.each(response, function(key, item) {
                            options += opt_template({key: item.id, text: item.name});
                        });
                        highlight_content_views(i18n.select_content_view);
                    } else {
                        // the user selected an environment that has not views, warn them
                        highlight_content_views(i18n.no_content_views_available);
                    }
                    $("#system_content_view_id").html(options);
                }
            });
        }
    },
    highlight_content_views = function(text){
        var select_input = $("#system_content_view_id"),
            highlight_text = select_input.next('span.highlight_input_text');

        select_input.addClass('highlight_input');
        if (highlight_text.length > 0) {
            highlight_text.html(text);
        } else {
            select_input.after('<span class ="highlight_input_text">' + text + '</span>');
        }
    },
    remove_content_view_highlight = function() {
        var select_input = $("#system_content_view_id");
        select_input.removeClass('highlight_input');
        select_input.next('span.highlight_input_text').remove();
    };

    return {
        env_change : env_change,
        create_system : create_system,
        registerActions : registerActions,
        update_content_views: update_content_views,
        highlight_content_views: highlight_content_views,
        system_info_setup: system_info_setup,
        system_group_setup: system_group_setup
    };
})();

KT.system_auto_attaching = (function() {

    var task_status_updater;

    $(document).ready(function() {
        KT.system_auto_attaching.setup();
        KT.system_auto_attaching.async_panel_refresh();
    });

    var async_panel_refresh = function() {
        if (auto_attach_all_button().length > 0) {
            if (task_status_updater !== undefined) {
                task_status_updater.stop();
            }
            var state = auto_attach_all_button().data("taskstate");
            if (state === "waiting" || state === "running") {
                start_updater(auto_attach_all_button().data("taskuuid"));
            }
        }
    };

    var start_updater = function(task_uuid) {
        allow_auto_attach_all_systems(false);
        auto_attach_all_button().addClass("processing");
        var timeout = 6000;

        if (task_status_updater !== undefined) {
            task_status_updater.stop();
        }

        task_status_updater = $.PeriodicalUpdater(
            KT.routes.api_task_path(task_uuid),
            {
                method: 'get',
                type: 'json',
                cache: false,
                global: false,
                minTimeout: timeout,
                maxTimeout: timeout
            },
            update_status
        );
    };

    var update_status = function(data, success, xhr, handle) {
        if (data !== "") {
            var state = data['state'];
            if (state !== "waiting" && state !== "running") {
                auto_attach_all_button().removeClass("processing");
                allow_auto_attach_all_systems(true);
                task_status_updater.stop();
                if (data['result'].length > 0) {
                    notices.displayNotice("success", window.JSON.stringify({"notices": [i18n.auto_attach_all_systems_success] }));
                }
            }
        }
    };

    var setup = function() {
        auto_attach_all_button().live("click", function() {
            auto_attach_all_systems();
        });
    };

    var auto_attach_all_systems = function() {
        var button = auto_attach_all_button();
        $.ajax({
            url: button.data("url"),
            type: button.data("method"),
            data: '',
            success: function(data) {
                start_updater(data['uuid']);
            },
            error: function(data) {
                notices.displayNotice("error", window.JSON.stringify({"notices": [i18n.auto_attach_all_systems_failure] }));
            }
        });
    };

    var allow_auto_attach_all_systems = function(allow) {
        if (allow === true) {
            auto_attach_all_button().removeAttr('disabled');
        } else {
            auto_attach_all_button().attr('disabled', 'true');
        }
    };

    var auto_attach_all_button = function() {
        return $(".panel_action #auto_attach_all_button");
    };

    return {
        setup : setup,
        auto_attach_all_systems: auto_attach_all_systems,
        auto_attach_all_button: auto_attach_all_button,
        async_panel_refresh: async_panel_refresh
    };
})();

KT.subs = (function() {
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
                    checked += 1;
                    if(!(unsubbutton.is(":visible"))){
                        fakeunsubbutton.fadeOut("fast", function(){unsubbutton.fadeIn()});
                    }
                }else{
                    checked -= 1;
                    if((unsubbutton.is(":visible")) && checked === 0){
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
    _checked = 0,  // scoped variable to hold number of checkboxes
    updateSubButtons = function() {
        var subbutton = $('#sub_submit'),
            fakesubbutton = $('#fake_sub_submit');

        if(_checked > 0 && !subbutton.is(":visible")){
            fakesubbutton.fadeOut("fast", function(){subbutton.fadeIn()});
        } else if (_checked === 0 && subbutton.is(":visible")) {
            subbutton.fadeOut("fast", function(){fakesubbutton.fadeIn()});
        }
    };

    KT.panel.set_expand_cb(function() {
        setup();
    });

    setup = function() {
        heal_system_button().live("click", function() {
           heal_system();
        });
    },
   heal_system = function() {
        var button = heal_system_button();
        $.ajax({
                url  : button.data("url"),
                type : button.data("method"),
                data : '',
                success: function(data) {
                        console.log("success");
                },
                error: function(data) {
                        notices.displayNotice("error", window.JSON.stringify({"notices": ["System cannot be healed.Please contact your system administrator"]}));
                }
        });
   },
   heal_system_button = function() {
        return $("#heal_system_button");
   },
    subSetup = function(){
        var subcheckboxes = $('#subscribe input[type="checkbox"]'),
            subbutton = $('#sub_submit');

        _checked = 0;
        subbutton.hide();

        subcheckboxes.each(function(){
            $(this).change(function(){
                var id = $(this).attr("id").substring("subscription_".length),
                    spinner,
                    direction,
                    value,
                    of_string;

                spinner = $("#spinner_" + id);
                if ($(this).is(":checked")) {
                    _checked += 1;
                    direction = "increment";
                    value = spinner.data("suggested");
                } else {
                    _checked -= 1;
                    direction = "decrement";
                    value = 0;
                }
                if (spinner.length > 0) {
                    if (spinner.attr("class") === "ui-spinner") {
                        if ((spinner.spinner("value") === 0 && value > 0) ||
                           (spinner.spinner("value") !== 0 && value === 0)) {
                            spinner.spinner("value", value);
                        }
                    } else if (spinner.attr("class") === "ui-nonspinner") {
                        spinner.val(value);
                        spinner = $("#spinner_label_" + id);
                        if (spinner.length > 0) {
                            of_string = value + spinner[0].innerHTML.substr(1);
                            spinner[0].innerHTML = of_string;
                        }
                    }
                    updateSubButtons();
                }
            });
        });
    },
    spinnerSetup = function(){
        setTimeout(function() {
            $('.ui-spinner').spinner();
        }, 1000);
        $('.ui-spinner').each(function() {
            $(this).change(function(e) {
                var id = $(this).attr("id").substring("spinner_".length),
                    checkbox = $("#subscription_" + id)[0],
                    val = e.currentTarget.value,
                    check = (val !== 0);

                if (checkbox.checked !== check) {
                    checkbox.checked = check;
                    if (check) {
                        _checked += 1;
                    } else {
                        _checked -= 1;
                    }
                    updateSubButtons();
                }
            });
            $(this).keypress(function(e) {
               if (e.which === 13) {
                   $(this).trigger("change");
               }
            });
        });
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
      $('#subscription_filters').chosen().change(function(e) {
          var children = $(this).children();
          $('#available_section').addClass('hidden');
          $('#available_spinner').removeClass('hidden');
          var i = 0;
          $.each(children, function(i, item) {
             $.ajax({
                 url: $('#matchsystem_form')[0].action + "?preference=" + item.value,
                 data: { value: item.selected },
                 type: 'PUT',
                 success: function(data) {
                     if (i === children.length-1) {
                       $('#systems_subscriptions > a').click();  // Refresh page
                     }
                 }, error: function(e) {
                     if (i === children.length-1) {
                       $('#systems_subscriptions > a').click();  // Refresh page
                     }
                 }
             });
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
    };
})();
