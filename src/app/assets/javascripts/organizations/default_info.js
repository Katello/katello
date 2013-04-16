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

var KT = (KT === undefined) ? {} : KT;

KT.default_info = (function() {

    $("#new_default_info_keyname").live("keydown", function(e) {
        if (e.keyCode === 13) { // if you press enter
            $("#add_default_info_button").trigger("click");
        }
    });

    $("#apply_default_info_button").live("click", function(e) {
        var button = $(this);
        e.preventDefault();
        KT.common.customConfirm({
            message     : i18n.take_a_while_you_sure,
            yes_callback: function() {
                apply_default_info(button);
            }
        });
    });

    $('#new_default_info_keyname').live('keyup', function(e) {
        check_for_empty($(this));
    });

    $('#add_default_info_button').live('click', function(e) {
        e.preventDefault();
        add_default_info($(this));
    });

    $('.remove_default_info_button').live('click', function(e) {
        e.preventDefault();
        remove_default_info($(this));
    });

    function check_for_apply() {
        if ($("#default_info_table tr").length > 2) {
            $("#apply_default_info_button").removeAttr("disabled");
        } else {
            $("#apply_default_info_button").attr("disabled", "true");
        }
    }

    function apply_default_info($button) {
        $.ajax({
            url    : $button.data('url'),
            type   : $button.data('method'),
            success: function(data) {
                message = data.length + " " + i18n.objects_affected_successfully
                notices.displayNotice("success", window.JSON.stringify({ "notices": [message] }));
            },
            error  : function(data) {
                notices.displayNotice("error", window.JSON.stringify({ "notices": [$.parseJSON(data.responseText)["displayMessage"]] }));
            }
        });
    }

    function check_for_empty($textfield) {
        if ($textfield.val().length > 0 ) {
            $('#add_default_info_button').removeAttr("disabled");
        } else {
            $('#add_default_info_button').attr("disabled", "true");
        }
    }

    function add_default_info($button) {
        var keyname = $("#new_default_info_keyname").val();

        $.ajax({
            url     : $button.data("url"),
            type    : $button.data("method"),
            dataType: 'json',
            data    : { "keyname" : keyname },
            success : function(data) {
                add_default_info_row(data)
            }
        });
    }

    function remove_default_info($button) {
        $.ajax({
            url    : $button.data("url"),
            type   : $button.data("method"),
            success: function(data) {
                remove_default_info_row($button.data("id"));
            }
        });
    }

    function remove_default_info_row(data_id) {
        $("tr[data-id='" + data_id + "']").remove();
        check_for_apply();
    }

    function add_default_info_row(data) {
        var keyname = data["keyname"];
        var esc_keyname = escape(data["keyname"]);
        var _keyname = data["keyname"].replace(" ", "_");

        var informable_type = data["informable_type"];
        var org = data["organization"];
        var destroy_path = KT.routes.api_organization_destroy_default_info_path(org["name"], informable_type, esc_keyname);

        var new_row = "<tr class=\"primary_color\" data-id=\"default_info_" + _keyname + "\">"
            + "<td class=\"ra\">"
            + "<label for=\"default_info_" + _keyname + "\">" + keyname + "</label>"
            + "</td>"
            + "<td>"
            + "<input class=\"btn warning remove_default_info_button\" data-id=\"default_info_" + _keyname + "\" data-method=\"delete\" data-url=\"" + destroy_path + "\" type=\"submit\" value=\"" + i18n.remove + "\">"
            + "</td>"
            + "</tr>";

        $("#new_default_info_row").after(new_row);
        setTimeout(function() {$("tr[data-id='default_info_" + _keyname + "']").addClass("row_fade_in"); }, 1); // hax
        $("#new_default_info_keyname").val("");
        check_for_empty($("#new_default_info_keyname"));
        check_for_apply();
    }

})();
