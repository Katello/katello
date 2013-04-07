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

    setTimeout("$('#subscription_filters').attr('disabled', false).trigger('liszt:updated');", 500);
});

KT.panel_search_autocomplete = KT.panel_search_autocomplete.concat(["distribution.name:", "distribution.version:", "network.hostname:", "network.ipaddr:"]);

(function(){
    var options = { create : 'new_distributor' };

    if (window.env_select !== undefined) {

        // When the env selector changes, update the pre-populated attributes
        env_select.env_changed_callback = function(env_id) {
            if(env_select.envsys == true){
                $('#new').attr('data-ajax_url', KT.routes.new_distributor_path() + '?env_id=' + env_id);
            }
            $('#distributor_environment_id').attr('value', env_id);
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
    KT.panel.list.registerPage('distributors', options);
}());

$(document).ready(function() {

    KT.panel.set_expand_cb(function() {
        KT.subs.initialize_edit();
    });

    KT.distributors_page.registerActions();

    // These run after the subscribe/unsubscribe forms have been submitted to update
    // the left hand list entry (which reflects the subscribed status of the distributor).
    $('#unsubscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left').find('.active');
        var url = id.attr('data-ajax_url');
        KT.panel.list.refresh(id.attr('id'), url);
        $(this).find('input[type="submit"]').removeAttr('disabled');
    }).live('ajax:before', function(){
        $(this).find('input[type="submit"]').attr('disabled', 'disabled');
    });

    $('#subscribe').live('ajax:complete', function(evt, data, status, xhr){
        var id = $('.left').find('.active');
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
    };

  return {
      env_change : env_change,
      create_distributor : create_distributor,
      registerActions : registerActions
  }
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
                    _checked++;
                    direction = "increment";
                    value = 1;
                } else {
                    _checked--;
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
            var id = $('.left').find('.active');
            id = id.attr('id').substring("distributor_".length);
            var filename = $('#distributor_download_filename').val();
            var download_url = KT.routes.download_distributor_path(id) + "?filename=" + filename;
            window.location.href = download_url;
        });
    },

    spinnerSetup = function(){
        setTimeout("$('.ui-spinner').spinner()",1000);
        $('.ui-spinner').each(function() {
            $(this).change(function(e) {
                var id = $(this).attr("id").substring("spinner_".length),
                    checkbox = $("#subscription_" + id)[0],
                    val = e.currentTarget.value,
                    check = (val != 0);

                if (checkbox.checked != check) {
                    checkbox.checked = check;
                    if (check) {
                        _checked++;
                    } else {
                        _checked--;
                    }
                    updateSubButtons();
                }
            });
            $(this).keypress(function(e) {
               if (e.which == 13) {
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
    }
})();
