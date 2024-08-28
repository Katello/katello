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

            $('.create_button').on("mousedown", function() {retrieve_label = false;});

            $('.name_input').on("blur", function(event){
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
            $('.name_input').on('click, focusin', function() {
                disable_inputs($(this));
                initial_name_value = $(this).val();
            });
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
    };
})();