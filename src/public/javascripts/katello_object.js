/**
 Copyright 2013 Red Hat, Inc.

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
    var initial_name_value,
        retrieve_label = true,

        initialize = function(){
            initial_name_value = "";
            retrieve_label = true;

            if ($(".label_input").length === 0){
                return;
            }

            disable_inputs(undefined);

            $('.create_button').mousedown(function() {retrieve_label = false;});

            $('.name_input').focusout(function(event){
                var name_input = $(this),
                    name = name_input.val(),
                    label = $(this).closest('fieldset').next('fieldset'),
                    label_input = label.find('input.label_input');

                if ((retrieve_label === true) && (name.length > 0) && (name !== initial_name_value)) {
                    // user changed the name so go fetch the label from the server
                    show_label(label, false);

                    $.ajax({
                        type: "GET",
                        url: label_input.data("url"),
                        data: {name:name},
                        cache: false,
                        success: function(data) {
                            if (data.length > 0) {
                                // locate the label input and set it to the value received
                                label_input.val(data);
                            }
                            enable_inputs(name_input);
                            show_label(label, true);
                        },
                        error: function() {
                            enable_inputs(name_input);
                            show_label(label, true);
                        }
                    });
                } else {
                    enable_inputs(name_input);
                }
            });
            $('.name_input').bind('click, focusin', function() {
                disable_inputs($(this));
                initial_name_value = $(this).val();
            })
        },
    show_label = function(label, show) {
        if (show === true) {
            label.find('input.label_input').removeClass('hidden');
            label.find('img.label_spinner').addClass('hidden');
        } else {
            label.find('input.label_input').addClass('hidden');
            label.find('img.label_spinner').removeClass('hidden');
        }
    },
    disable_inputs = function(current_name_input) {
        if (current_name_input === undefined) {
            // disable all label inputs
            $(".label_input").attr("disabled", "disabled");
        } else {
            // disable the label input associated with the current name
            current_name_input.closest('fieldset').next('fieldset').find('input.label_input').attr("disabled", "disabled");
        }
    },
    enable_inputs = function(current_name_input) {
        if (current_name_input === undefined) {
            // enable all label inputs
            $(".label_input").removeAttr("disabled");
        } else {
            // enable the label input associated with the current name
            current_name_input.closest('fieldset').next('fieldset').find('input.label_input').removeAttr("disabled");
        }
    };

    return {
        initialize: initialize
    }
})();