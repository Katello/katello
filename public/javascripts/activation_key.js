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
        var button = $(this).find('input[type|="submit"]');
        button.attr("disabled","disabled");
        $(this).ajaxSubmit({
            success: function(data) {
                list.add(data);
                panel.closePanel($('#panel'));
                panel.select_item(list.last_child().attr("id"));
            },
            error: function(e) {
                button.removeAttr('disabled');
            }
        });
    });

    $(".remove_key").live('click', function() {
        var button = $(this);

        var answer = confirm(button.attr('data-confirm-text'));
        if (answer) {
            $.ajax({
                type: "DELETE",
                url: button.attr('data-url'),
                cache: false,
                success: function() {
                    panel.closeSubPanel($('#subpanel'));
                    panel.closePanel($('#panel'));
                    list.remove(button.attr("data-id").replace(/ /g, '_'));
                }
            });
        }
    });
    $(".multiselect").multiselect({"dividerLocation":0.5, "sortable":false})
});

var activation_key = (function() {
    return {
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
        }
    }
})();

