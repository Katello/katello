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

KT.object = KT.object || {};

// The KT Object label will handle the interaction where a user enters a
// name and upon completion, we want to retrieve a 'default' label from
// the server generated off of that name.
KT.object.label = (function(){
    var label_input,
        create_button,
        initialize = function(){
            label_input = $(".label_input");
            if (label_input.length === 0){
                return;
            }
            create_button = $(".create_button");

            disable_inputs(undefined);

            $('.name_input').bind('focusout', function(){
                var name_input = $(this);
                if (name_input.val().length > 0) {
                    // user entered a name so go fetch the label from the server
                    disable_inputs(name_input);
                    $.ajax({
                        type: "GET",
                        url: label_input.data("url"),
                        data: {name:name_input.val()},
                        cache: false,
                        success: function(data) {
                            if (data.length > 0) {
                                // locate the label input and set it to the value received
                                name_input.closest('fieldset').next('fieldset').find('input.label_input').val(data);
                                enable_inputs(name_input);
                            }
                        },
                        error: function() {
                        }
                    });
                }
            });
            $('.name_input').bind('click', function() {
                disable_inputs($(this));
            })
        },
    disable_inputs = function(current_name_input) {
        if (current_name_input === undefined) {
            // disable all label inputs
            label_input.attr("disabled", "disabled");
        } else {
            // disable the label input associated with the current name
            current_name_input.closest('fieldset').next('fieldset').find('input.label_input').attr("disabled", "disabled");
        }
        create_button.attr("disabled", "disabled");
    },
    enable_inputs = function(current_name_input) {
        if (current_name_input === undefined) {
            // enable all label inputs
            label_input.removeAttr("disabled");
        } else {
            // enable the label input associated with the current name
            current_name_input.closest('fieldset').next('fieldset').find('input.label_input').removeAttr("disabled");
        }
        create_button.removeAttr("disabled");
    };

    return {
        initialize: initialize
    }
})();