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
    });

    $(".edit_env").live('click', function() {
        activation_key.edit_environment($(this));
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
        //custom successCreate - calls notices update and list/panel updates from panel.js
        successCreate : function(data) {
            //panel.js functions
            list.add(data);
            panel.closePanel($('#panel'));
        },
        failCreate : function(data) {
            // enable the form submit so that the user can resolve the error and retry
            $('input[id^=provider_save]').removeAttr("disabled");
        },
        toggleFields : function() {
          	val = $('#provider_provider_type option:selected').val()
          	var fields = "#repository_url_field"; 
          	if (val == "Custom") {
          		$(fields).attr("disabled", true);			
          	}
          	else {
          		$(fields).removeAttr("disabled");
          	}
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
        select_environment : function(data) {
            // clear any previous selected environments
            data.closest("#promotion_paths").find(".selected").removeClass("selected");
            // highlight the selected environment
            data.addClass("selected");
            // save the id of the env selected
            data.closest("#promotion_paths").find("#activation_key_default_environment").attr('value', data.attr('data-env_id'));
        }
    }
})();

