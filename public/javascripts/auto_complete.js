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
        values: undefined,       //either a url, an array, or a callback of items for auto_completion
        default_text: undefined,  //default text to go into the search box if desired
        input_id: undefined,
        form_id: undefined,
        add_btn_id: undefined,
        add_text: i18n.add_plus,
        add_cb: function(t, cb){cb();}
    };
    $.extend( settings, params );
    
    var add_item_from_input = function(e) {
        var item = $("#" + settings.input_id).attr("value");
        var add_btn = $("#" + settings.add_btn_id);
        
        e.preventDefault();
        if (item.length === 0 || item === settings.default_text ||item.length === 0 ){
                return;
        }
        add_btn.addClass("working");
        add_item_base(item, true);
    },
    add_item_base = function(item, focus) {
        var input = $("#" + settings.input_id);
        var add_btn = $("#" + settings.add_btn_id);

        add_btn.addClass("working");
        add_btn.html("<img  src='images/embed/icons/spinner.gif'>");
        input.attr("disabled", "disabled");
        input.autocomplete('disable');
        input.autocomplete('close');

        settings.add_cb(item, function(){
            add_success_cleanup();
            if (focus) {
                $('#' + settings.input_id).focus();
            }
        });

    },
    add_success_cleanup = function() {
        //re-lookup all items, since a redraw may have happened
        var input = $("#" + settings.input_id);
        var add_btn = $("#" + settings.add_btn_id);
        add_btn.removeClass('working');
        if (add_btn.text() === "") {
            add_btn.html(settings.add_text);
        }
        input.val("");
        input.removeAttr('disabled');
        input.autocomplete('enable');
    },
    manually_add = function(item) {
        add_item_base(item, false);
    },
    error = function() {
        var input = $("#" + settings.input_id);
        input.addClass("error");

    };

    //initialization

    var input = $("#" + settings.input_id);
    var form = $("#" + settings.form_id);
    var add_btn = $("#" + settings.add_btn_id);
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
    
    input.autocomplete({
        source: settings.values
    });

    add_btn.click( add_item_from_input);
    form.submit(add_item_from_input);

    return {
        manually_add: manually_add,
        error: error
    };
};
