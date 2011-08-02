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

    $(".remove_key").live('click', function() {
        activation_key.delete_key($(this));
    });

    $(".select_env").live('click', function() {
        activation_key.select_environment($(this));
        activation_key.get_system_templates($(this), false);
    });

    $(".edit_env").live('click', function() {
        activation_key.edit_environment($(this));
        activation_key.get_system_templates($(this), true);
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
        edit_environment : function(data) {
            $.ajax({
                type: "PUT",
                url: data.attr("data-url"),
                data: { "activation_key":{ "environment_id": data.attr("data-env_id") } },
                cache: false,
                success: function(response) {
                    activation_key.select_environment(data);
                },
                error: function (data) {
                }
            });
        },
        get_system_templates : function(data, on_edit) {
            $.ajax({
                type: "GET",
                url: data.attr("data-templates_url"),
                cache: false,
                success: function(response) {
                    // update the appropriate content on the page
                    if (on_edit) {
                        // this request was for an activation key edit

                        // build list of options based on the response
                        var options = '{';
                        // add an empty option
                        options += '"":""';
                        for (var i = 0; i < response.length; i++) {
                            options += ',"' + response[i].id + '":"' + response[i].name + '"';
                        }
                        options += '}';

                        // save the options in the hidden input field
                        $("input[id^=system_templates]").val(options);
                        var current_template = $(".edit_system_template").html();

                        if (current_template != i18n.clickToEdit) {
                            // the key currently has a system template assigned; therefore, reset jeditable and
                            // inform the user that an update is needed.
                            $(".edit_system_template").html("");
                            activation_key.reset_jeditable_select(i18n.updatedNeededClickToEdit,
                                    current_template + ": " + i18n.updateNeededClickToEdit);
                        }
                    } else {
                        // this request was for an activation key create
                        var options = '';
                        // add an empty option
                        options += '<option value=""></option>';
                        for (var i = 0; i < response.length; i++) {
                            options += '<option value="' + response[i].id + '">' + response[i].name + '</option>';
                        }
                        $("#activation_key_system_template").html(options);
                    }
                },
                error: function(data) {
                }
            });
        },
        reset_jeditable_select : function(tooltip, placeholder) {
            $('.edit_system_template').each(function() {
                var button = $(this);
                $(this).editable('destroy');
            })
            $('.edit_system_template').each(function() {
                var button = $(this);
                $(this).editable(button.attr('data-url'), {
                    type        :  'select',
                    width       :  440,
                    method      :  'PUT',
                    name        :  $(this).attr('name'),
                    cancel      :  i18n.cancel,
                    submit      :  i18n.save,
                    indicator   :  i18n.saving,
                    tooltip     :  tooltip,
                    placeholder :  placeholder,
                    style       :  "inherit",
                    data        :  $('input[id^=system_templates]').attr("value"),
                    onsuccess   :  function(data) {
                        $(".edit_system_template").html(data);
                        activation_key.reset_jeditable_select(i18n.clickToEdit, i18n.clickToEdit)
                    },
                    onerror     :  function(settings, original, xhr) {
                        original.reset();
                        $("#notification").replaceWith(xhr.responseText);
                    }
                });
            })
        },
        select_environment : function(data) {
            // clear any previous selected environments
            data.closest("#promotion_paths").find(".selected").removeClass("selected");
            // highlight the selected environment
            data.addClass("selected");
            // save the id of the env selected
            data.closest("#promotion_paths").find("#activation_key_environment").attr('value', data.attr('data-env_id'));
        }
    }
})();

