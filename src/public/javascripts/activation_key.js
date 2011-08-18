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

    $('#new_activation_key').live('submit', function(e) {
        e.preventDefault();
        activation_key.create_key($(this));
    });

    $('#remove_key').live('click', function(e) {
        e.preventDefault();
        activation_key.delete_key($(this));
    });

    $('.edit_env_setup').live('click', function(e) {
        e.preventDefault();
        activation_key.edit_environment_setup($(this));
    });

    $('.select_env').live('click', function() {
        activation_key.select_environment($(this));
        activation_key.get_system_templates($(this), true);
    });

    $('#save_env').live('submit', function(e) {
        e.preventDefault();
        var button = $('input[id^=save_env]');
        button.attr("disabled","disabled");

        $(this).ajaxSubmit({
         success: function(data) {
             button.removeAttr('disabled');
             activation_key.update_activation_key_pane();
             // close dialog
             activation_key.close_environment_dialog();

         }, error: function(e) {
             button.removeAttr('disabled');
             // leave the dialog open
         }});
    });

    $('#update_subscriptions').live('submit', function(e) {
       e.preventDefault();
       var button = $(this).find('input[type|="submit"]');
       button.attr("disabled","disabled");
       $(this).ajaxSubmit({
         success: function(data) {
               button.removeAttr('disabled');
         }, error: function(e) {
               button.removeAttr('disabled');
         }});
    });

    // Initialize the environment edit dialog
    $('#environment_edit_dialog').dialog({
        resizable: false,
        autoOpen: false,
        height: 300,
        width: 650,
        modal: true,
        title: i18n.edit_environment
    });
});

var activation_key = (function() {
    return {
        create_key : function(data) {
            var button = data.find('input[type|="submit"]');
            button.attr("disabled","disabled");
            data.ajaxSubmit({
                success: function(data) {
                    list.add(data);
                    panel.closePanel($('#panel'));
                    panel.select_item(list.last_child().attr("id"));
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
                        panel.closeSubPanel($('#subpanel'));
                        panel.closePanel($('#panel'));
                        list.remove(data.attr("data-id").replace(/ /g, '_'));
                    }
                });
            }
        },
        edit_environment_setup : function(data) {
            // this function will retrieve the environment paths that the user may select an env from
            // and display them for selection in a dialog
            $.ajax({
                type: "GET",
                url: data.attr("data-env_url"),
                cache: false,
                success: function(response) {
                    $('#environment_edit_dialog').html(response).dialog('open');
                    // hide the system template select.  this select will only be shown if user selects an env
                    $("#force_edit_system_template").hide();
                },
                error: function(data) {
                }
            });
        },
        update_activation_key_pane : function() {
            // this function will update the environment and system template details on the main pane
            // using the values saved in the environment edit dialog

            // update the environment
            var env_id = $('#activation_key_environment_id').val();
            // starting from the promotion paths
            var paths = $('.promotion_paths');
            // clear the previously selected env
            var old_env = paths.find('.selected');
            old_env.removeClass('selected');

            // if the new env is on the same path as the old, highlight it.. otherwise, hide the current path,
            // locate the new path, show it and highlight the new env on that path
            var path = old_env.closest('.edit_env_setup');
            var new_env = path.find("a[data-env_id='"+env_id+"']");
            if (new_env.length < 1) {
                // unable to locate the new env on the current path...
                path.hide();
                new_env = paths.find("a[data-env_id='"+env_id+"']");
                path = new_env.closest('.edit_env_setup');
                path.show();
            }
            // highlight the newly chosen environment
            new_env.addClass('selected');
            // save the id of the env selected
            $('#environment_id').attr('value', env_id);

            // update the system template (name and options)
            var system_template_name = $("select[name='activation_key[system_template_id]'] option:selected").html();
            activation_key.reset_jeditable_select(system_template_name);
        },
        close_environment_dialog : function() {
            $('#environment_edit_dialog').dialog('close');
        },
        get_system_templates : function(data, on_edit) {
            // this function will retrieve the system templates associated with a given environment and
            // update the page content, as appropriate
            $.ajax({
                type: "GET",
                url: data.attr("data-templates_url"),
                cache: false,
                success: function(response) {
                    // update the appropriate content on the page
                    var options_json = '';
                    var options = '';

                    // create an html option list using the response
                    options += '<option value="">' + i18n.noTemplate + '</option>';
                    for (var i = 0; i < response.length; i++) {
                        options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
                    }

                    // add the options to the system template select... this select exists on an insert form
                    // or as part of the environment edit dialog
                    $("#activation_key_system_template_id").html(options);

                    if (on_edit) {
                        // this request was for an activation key edit, so do edit-specific work...

                        // show the select in the environment edit dialog
                        $("#force_edit_system_template").show();

                        // build list of options based on the response
                        options_json = '{';
                        // add an empty option
                        options_json += '"":"' + i18n.noTemplate + '"';
                        for (var i = 0; i < response.length; i++) {
                            options_json += ',"' + response[i].id + '":"' + response[i].name + '"';
                        }
                        options_json += '}';

                        // save the options in the hidden input field, for later use
                        $("input[id^=system_templates_temp]").val(options_json);
                    }
                },
                error: function(data) {
                }
            });
        },
        reset_jeditable_select : function(system_template_name) {
            // this function will reset the jeditable select used for system templates.  this is necessary
            // whenever the environment is updated.  this will ensure that the system templates associated
            // with the new environment are properly editable... this reset assumes that we have already retrieved
            // the system templates and stored them at system_templates_temp
            $(".edit_system_template").html(system_template_name);
            $('.edit_system_template').each(function() {
                $(this).editable('destroy');
            })
            $('.edit_system_template').each(function() {
                $(this).editable($(this).attr('data-url'), {
                    type        :  'select',
                    width       :  440,
                    method      :  'PUT',
                    name        :  $(this).attr('name'),
                    cancel      :  i18n.cancel,
                    submit      :  i18n.save,
                    indicator   :  i18n.saving,
                    tooltip     :  i18n.tooltip,
                    placeholder :  i18n.noTemplate,
                    style       :  "inherit",
                    data        :  $('input[id^=system_templates_temp]').attr("value"),
                    onsuccess   :  function(data) {
                        $(".edit_system_template").html(data);
                    },
                    onerror     :  function(settings, original, xhr) {
                        original.reset();
                        $("#notification").replaceWith(xhr.responseText);
                    }
                });
            })
        },
        select_environment : function(data) {
            var path = data.closest('.promotion_paths');

            // clear any previous selected environments
            path.find(".selected").removeClass("selected");
            // highlight the selected environment
            data.addClass("selected");
            // save the id of the env selected
            path.find("#activation_key_environment_id").attr('value', data.attr('data-env_id'));
        }
    }
})();

