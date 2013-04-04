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

    $.editable.addInputType('password', {
        element : function(settings, original) {
            var input=$('<input type="password">');
            if(settings.width!='none') {
                input.width(settings.width);
            }
            if(settings.height!='none') {
                input.height(settings.height);
            }
            input.attr('autocomplete','off');
            $(this).append(input);
            return(input);
        }
    });

    // Create a custom input type for checkboxes
    $.editable.addInputType("checkbox", {
        element : function(settings, original) {
            var input = $('<input type="checkbox">');
            $(this).append(input);

            // Update <input>'s value when clicked
            $(input).click(function() {
                //var value = $(input).attr("checked") ? i18n.checkbox_yes : i18n.checkbox_no;
                var value = $(input).attr("checked") ? true : false;
                $(input).val(value);
            });
            return(input);
        },
        content : function(string, settings, original) {
            var checked = string.indexOf(i18n.checkbox_yes)!= -1 ? 1 : 0;
            var input = $(':input:first', this);
            $(input).attr("checked", checked);
            var value = $(input).attr("checked") ? i18n.checkbox_yes : i18n.checkbox_no;
            //var value = $(input).attr("checked") ? true : false;

            $(input).val(value);
        }
    });

    $.editable.addInputType('number', {
        element  :   function(settings, original){
            var width = settings.width ? settings.width : '40',
                input = jQuery('<input type="number" ' +
                    'min="' + settings.min + '"' +
                    'max="' + settings.max + '"' +
                    'value="' + settings.value +
                    '" style="width:' + width + 'px;">');
            $(this).append(input);
            if (settings.unlimited !== undefined) {
                var label = jQuery('&nbsp; <label><input type="checkbox" value=""/>&nbsp; ' + i18n.unlimited + '</label>');
                $(this).append(label);
                var unlimited = label.find("input");
                $(unlimited).bind('click', function(){
                    if($(unlimited).is(":checked")){
                        $(input).val('');
                        $(input).attr("disabled", true);
                    } else {
                        $(input).val('');
                        $(input).removeAttr('disabled');
                    }
                });
            }
            $(original).css('background-image', 'none');
            return(input);
        },

        content : function(string, settings, original) {
            var text_input = $('input', this).first();
            text_input.val(string);
            if (settings.unlimited != undefined) {
                var check_input = $('input', this).last();
                if (string === settings.unlimited || string === i18n.unlimited) {
                    text_input.val('');
                    check_input.attr('checked', 'checked');
                    text_input.attr("disabled", true);
                } else {
                    check_input.removeAttr('checked');
                    text_input.removeAttr('disabled');
                }
            }
        },

        submit  : function(settings, original) {
            if (settings.unlimited != undefined) {
                var text_input = $('input', this).first();
                if (text_input.val() === '')
                    text_input.val(settings.unlimited);
            }
        }
    });

    $.editable.addInputType("multiselect", {
        element: function (settings, original) {
            var select = $('<select multiple="multiple" />');

            if (settings.width != 'none') { select.width(settings.width); }
            if (settings.size) { select.attr('size', settings.size); }

            $(this).append(select);
            return (select);
        },
        content: function (data, settings, original) {
            /* If it is string assume it is json. */
            if (String == data.constructor) {
                eval('var json = ' + data);
            } else {
                /* Otherwise assume it is a hash already. */
                var json = data;
            }
            for (var key in json) {
                if (!json.hasOwnProperty(key)) {
                    continue;
                }
                if ('selected' == key) {
                    continue;
                }
                var option = $('<option />').val(key).append(json[key]);
                $('select', this).append(option);
            }

            if ($(this).val() == json['selected'] ||
                $(this).html() == $.trim(original.revert)) {
                $(this).attr('selected', 'selected');
            }

            /* Loop option again to set selected. IE needed this... */
            $('select', this).children().each(function () {
                if (json.selected) {
                    var option = $(this);
                    $.each(json.selected, function (index, value) {
                        if (option.val() == value) {
                            option.attr('selected', 'selected');
                        }
                    });
                } else {
                    if (original.revert.indexOf($(this).html()) != -1)
                        $(this).attr('selected', 'selected');
                }
            });
        }
    });

    $.editable.addInputType( 'datepicker', {
        /* create input element */
        element: function( settings, original ) {
            var form = $( this ), input = $( '<input data-change="false"/>' );
            if (settings.width != 'none') { input.width(settings.width); }
            if (settings.height != 'none') { input.height(settings.height); }
            input.attr( 'autocomplete','off' );
            form.append( input );
            return input;
        },

        content : function(string, settings, original) {
            $(':input:first', this).val($.trim(string));
        },

        /* attach jquery.ui.datepicker to the input element */
        plugin: function( settings, original ) {
            var form = this, input = form.find( "input" );
            settings.onblur = 'nothing';

            datepicker = {
                // keep track of date selection state
                onSelect: function() {
                    input.attr('data-change', 'true');
                },
                // reset form if we lose focus and date was not selected
                onClose: function() {
                    if ($(this).attr('data-change') == 'false') {
                        original.reset( form );
                    }
                }
            };
            input.datepicker(datepicker).keyup(function(e) {
                if (e.keyCode == 8 || e.keyCode == 46) {
                    $.datepicker._clearDate(this)
                }
            });
        }
    });

    $.editable.addInputType( 'timepicker', {
        /* create input element */
        element: function( settings, original ) {
            var form = $( this ), input = $( '<input data-change="false"/>' );
            if (settings.width != 'none') { input.width(settings.width); }
            if (settings.height != 'none') { input.height(settings.height); }
            input.attr( 'autocomplete','off' );
            form.append( input );
            return input;
        },

        plugin: function( settings, original ) {
            var form = this, input = form.find( "input" );
            settings.onblur = 'ignore';
            input.timepickr({convention: 12})
                .click();
        }
    });
});
