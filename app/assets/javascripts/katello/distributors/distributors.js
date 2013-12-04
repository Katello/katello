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

    setTimeout(function () {
        $('#subscription_filters').attr('disabled', false).trigger('liszt:updated');
    }, 500);
});

if (KT.panel_search_autocomplete !== undefined) {
    KT.panel_search_autocomplete = KT.panel_search_autocomplete.concat(["distribution.name:", "distribution.version:"]);
}

(function(){
    var options = { create : 'new_distributor' };

    if (window.env_select !== undefined) {

        env_select.env_changed_callback = function(env_id) {
            if(env_select.envsys === true){
                $('#new').attr('data-ajax_url', KT.routes.new_distributor_path() + '?env_id=' + env_id);
            }
            if($("#distributor_content_view_id").length > 0) {
                KT.distributors_page.update_content_views();
            }
            $('#distributor_environment_id').attr('value', env_id);
        };
    }
    KT.panel.list.registerPage('distributors', options);
}());

$(document).ready(function() {

    KT.panel.set_expand_cb(function() {
        KT.distributors_page.distributor_info_setup();
        KT.subs.initialize_edit();
    });

    KT.distributors_page.registerActions();

    // These run after the subscribe/unsubscribe forms have been submitted to update
    // the left hand list entry (which reflects the subscribed status of the distributor).
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

KT.distributors_page = (function() {
    var env_change = function(env_id, element) {
      var url = element.attr("data-url");
      window.location = url;
    },
    create_distributor = function(data) {
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
        var removeDistributor = $(".panel_action[data-id=remove_distributors]");

        KT.panel.actions.registerAction("remove_distributors",
            {  url: removeDistributor.data("url"),
               method: removeDistributor.data("method"),
               success_cb: function(ids){
                    $.each(ids,function(index, item){
                        list.remove("distributor_" + item);
                    });
               },
                valid_input_cb: function() {
                    var confirmation_text = removeDistributor.find('.confirmation_text');
                    confirmation_text.html(i18n.confirm_distributor_remove_action(KT.panel.numSelected()));
                    return true;
                }
            }
        );
    },
    distributor_info_setup = function() {
        var pane = $("#distributor");
        if (pane.length === 0) {
            return;
        }

        KT.env_content_view_selector.init('edit_env_view',
            'environment_path_selector', KT.available_environments, KT.current_environment_id,
            'content_view_selector', KT.available_content_views, KT.current_content_view_id,
            'env_content_view_selector_buttons');
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
                    $("#distributor_content_view_id").html(options);
                }
            });
        }
    },
    highlight_content_views = function(text){
        var select_input = $("#distributor_content_view_id"),
            highlight_text = select_input.next('span.highlight_input_text');

        select_input.addClass('highlight_input');
        if (highlight_text.length > 0) {
            highlight_text.html(text);
        } else {
            select_input.after('<span class ="highlight_input_text">' + text + '</span>');
        }
    },
    remove_content_view_highlight = function() {
        var select_input = $("#distributor_content_view_id");
        select_input.removeClass('highlight_input');
        select_input.next('span.highlight_input_text').remove();
    };

  return {
      env_change : env_change,
      create_distributor : create_distributor,
      registerActions : registerActions,
      update_content_views: update_content_views,
      highlight_content_views: highlight_content_views,
      distributor_info_setup: distributor_info_setup
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
        $("#distributor_environment_id").attr('value', env_id);
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

                if($(this).is(":checked")) {
                    _checked += 1;
                    direction = "increment";
                    value = 1;
                } else {
                    _checked -= 1;
                    direction = "decrement";
                    value = 0;
                }
                spinner = $("#spinner_" + id);
                if(spinner.length > 0) {
                    if (spinner.attr("class") === "ui-spinner") {
                        if((spinner.spinner("value") === 0 && direction === "increment") ||
                           (spinner.spinner("value") !== 0 && direction === "decrement")) {
                            spinner.spinner(direction);
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

    downloadSetup = function() {
        $('#download_manifest').live('click', function(e) {
            e.preventDefault();  //stop the browser from following
            var id = $('.left_panel').find('.active');
            id = id.attr('id').substring("distributor_".length);
            var filename = $('#distributor_download_filename').val();
            var download_url = KT.routes.download_distributor_path(id) + "?filename=" + filename;
            window.location.href = download_url;
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
    };

    return {
        unsubSetup: unsubSetup,
        subSetup: subSetup,
        downloadSetup: downloadSetup,
        spinnerSetup: spinnerSetup,
        save_selected_environment: save_selected_environment,
        initialize_edit: initialize_edit,
        reset_env_select: reset_env_select
    };
})();
