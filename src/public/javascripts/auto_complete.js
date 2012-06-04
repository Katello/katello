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
KT.auto_complete_box = function(params) {

    var settings = {
        values: undefined, //either a url, an array, or a callback of items for auto_completion
        default_text: undefined, //default text to go into the search box if desired
        comma_separated_input: false,
        input_id: undefined,
        selected_input_id: undefined,
        form_id: undefined,
        add_btn_id: undefined,
        add_text: i18n.add_plus,
        add_cb: function(item, item_id, cb){cb();}
    };
    $.extend( settings, params );
    
    var add_item_from_input = function(e) {
        var item = $("#" + settings.input_id).attr("value"),
            item_id = $("#" + settings.selected_input_id).val(),
            add_btn = $("#" + settings.add_btn_id);
        
        e.preventDefault();
        if (item.length === 0 || item === settings.default_text){
                return;
        }
        add_btn.addClass("working");
        add_item_base(item, item_id, true);
    },
    add_item_base = function(item, item_id, focus) {
        var input = $("#" + settings.input_id),
            add_btn = $("#" + settings.add_btn_id);
        input.removeClass("input_error");
        add_btn.addClass("working");
        add_btn.html("<img  src='images/embed/icons/spinner.gif'>");
        input.attr("disabled", "disabled");
        input.autocomplete('disable');
        input.autocomplete('close');

        if (settings.comma_separated_input) {
            // convert the item string to an array
            item = split(item);
        }
        settings.add_cb(item, item_id, function(){
            reset_input();
            if (focus) {
                $('#' + settings.input_id).focus();
            }
        });
    },
    reset_input = function() {
        //re-lookup all items, since a redraw may have happened
        var input = $("#" + settings.input_id),
            add_btn = $("#" + settings.add_btn_id);
        add_btn.removeClass('working');
        if (add_btn.text() === "") {
            add_btn.html(settings.add_text);
        }
        input.removeAttr('disabled');
        input.autocomplete('enable');
    },
    manually_add = function(item, item_id) {
        add_item_base(item, item_id, false);
    },
    error = function() {
        var input = $("#" + settings.input_id);
        input.addClass("input_error");
    },
    split = function(val) {
        return val.split(/,\s*/);
    },
    extractLast = function(term) {
        return split(term).pop();
    };

    //initialization
    var input = $("#" + settings.input_id),
        form = $("#" + settings.form_id),
        add_btn = $("#" + settings.add_btn_id);

    if (settings.default_text) {
        input.val(settings.default_text);
        input.focus(function() {
            if (input.val() === settings.default_text) {
                input.val("");
            }
        });
        input.blur(function() {
            if(input.val() === "") {
                input.val(settings.default_text);
            }
        });
    }

    if (!settings.comma_separated_input) {
        input.autocomplete({
            source: settings.values,
            search: function(){
                $("#" + settings.selected_input_id).val('');
            },
            select: function (event, ui) {
                $("#" + settings.input_id).val(ui.item.value);
                $("#" + settings.selected_input_id).val(ui.item.id);
                return false;
            }
        });
    } else {
        input.autocomplete({
            source: function(request, response) {
                $.getJSON( settings.values, {
                    term: extractLast(request.term)
                }, response);
            },
            search: function () {
                // custom minLength
                var term = extractLast(this.value);
                if (term.length < 1) {
                    return false;
                }
            },
            focus: function () {
                // prevent value inserted on focus
                return false;
            },
            select: function (event, ui) {
                var terms = split(this.value);
                // remove the current input
                terms.pop();
                // add the selected item
                terms.push(ui.item.value);
                // add placeholder to get the comma-and-space at the end
                terms.push("");
                this.value = terms.join(", ");
                return false;
            }
        });
    }

    add_btn.bind('click', add_item_from_input);
    form.submit(add_item_from_input);

    return {
        manually_add: manually_add,
        error: error,
        reset_input: reset_input
    };
};


